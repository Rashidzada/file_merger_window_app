import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as p;

import '../models/page_size_option.dart';

class PdfService {
  /// Merges a list of PDF files into a single PDF document.
  /// Returns the bytes of the merged PDF.
  /// Throws exceptions if files are invalid or inaccessible.
  Future<List<int>> mergePdfs(List<String> filePaths, {Function(String)? onProgress, PageSizeOption pageSize = PageSizeOption.original}) async {
    // Create a new PDF document.
    final PdfDocument outputDocument = PdfDocument();

    try {
      for (int i = 0; i < filePaths.length; i++) {
        final path = filePaths[i];
        if (onProgress != null) {
          onProgress('Merging file ${i + 1} of ${filePaths.length}: ${p.basename(path)}');
        }

        final File file = File(path);
        if (!await file.exists()) {
          throw Exception('File not found: $path');
        }

        final ext = p.extension(path).toLowerCase();
        final isImage = ['.jpg', '.jpeg', '.png', '.bmp'].contains(ext);

        if (isImage) {
           final imageBytes = await file.readAsBytes();
           PdfImage image;
           if (ext == '.png') {
             image = PdfBitmap(imageBytes);
           } else {
             image = PdfBitmap(imageBytes); // Syncfusion PdfBitmap handles jpg/png/bmp usually
           }

           // Determine page size
           Rect? bounds;
           Size size;
           
           if (pageSize == PageSizeOption.a4) {
             outputDocument.pageSettings.size = PdfPageSize.a4;
             size = PdfPageSize.a4;
           } else if (pageSize == PageSizeOption.letter) {
             outputDocument.pageSettings.size = PdfPageSize.letter;
             size = PdfPageSize.letter;
           } else {
             // Original - separate logic usually, but for images we need a page size.
             // We can use image size or A4 default if "Original" means "Fit Image"
             size = Size(image.physicalDimension.width, image.physicalDimension.height);
             outputDocument.pageSettings.size = size;
           }

           // Add page
           final PdfPage page = outputDocument.pages.add();
           
           // Draw image
           if (pageSize == PageSizeOption.original) {
              page.graphics.drawImage(image, Rect.fromLTWH(0, 0, size.width, size.height));
           } else {
              // Fit to page (contain)
              // Calculate aspect ratios
              double imageAspect = image.physicalDimension.width / image.physicalDimension.height;
              double pageAspect = size.width / size.height;
              
              double w, h;
              if (imageAspect > pageAspect) {
                 w = size.width;
                 h = size.width / imageAspect;
              } else {
                 h = size.height;
                 w = size.height * imageAspect;
              }
              
              // Center it
              double x = (size.width - w) / 2;
              double y = (size.height - h) / 2;
              
              page.graphics.drawImage(image, Rect.fromLTWH(x, y, w, h));
           }

        } else {
           // PDF Handling
           final List<int> fileBytes = await file.readAsBytes();
           final PdfDocument inputDocument = PdfDocument(inputBytes: fileBytes);

           for(int pageIndex = 0; pageIndex < inputDocument.pages.count; pageIndex++) {
              PdfTemplate template = inputDocument.pages[pageIndex].createTemplate();
              
              Size finalPageSize;
              if (pageSize == PageSizeOption.a4) {
                 finalPageSize = PdfPageSize.a4;
              } else if (pageSize == PageSizeOption.letter) {
                 finalPageSize = PdfPageSize.letter;
              } else {
                 // Original - use template size
                 finalPageSize = template.size;
              }
              
              // We need to set section settings for mixed sizes if using "Original"
              // But Syncfusion usually shares settings per section. 
              // Simplest approach: Add page, if size differs, we might need a section? 
              // Actually PdfDocument.pages.add() uses document default.
              // To support variable page sizes in one doc with Syncfusion, we might need sections.
              // For now, let's assume we just set the page size if we can, or scale content.
              
              // If we are forcing A4/Letter, we create A4/Letter page.
              // If Original, we try to match input.
              
              PdfPage page;
              if (pageSize != PageSizeOption.original) {
                  // Force size via Section if needed or just add and hoping defaults work?
                  // Syncfusion: "PdfSection section = document.sections.add(); section.pageSettings.size = ..."
                  // To keep it simple, we'll try adding a page and drawing.
                  
                  // However, global setting affects new pages.
                  outputDocument.pageSettings.size = finalPageSize;
                  page = outputDocument.pages.add();
                  
                  // Draw template scaled to fit
                  Size contentSize = template.size;
                  
                  // Calculate scale "Fit"
                  double contentAspect = contentSize.width / contentSize.height;
                  double pageAspect = finalPageSize.width / finalPageSize.height;
                  
                  double w, h;
                  if (contentAspect > pageAspect) {
                     w = finalPageSize.width;
                     h = finalPageSize.width / contentAspect;
                  } else {
                     h = finalPageSize.height;
                     w = finalPageSize.height * contentAspect;
                  }
                  
                  double x = (finalPageSize.width - w) / 2;
                  double y = (finalPageSize.height - h) / 2;
                  
                  page.graphics.drawPdfTemplate(template, Offset(x, y), Size(w, h));
                  
              } else {
                  // Original Size
                  // We need to create a section for this page if its size differs from previous?
                  // Or just set pageSettings before adding?
                  outputDocument.pageSettings.size = template.size;
                  outputDocument.pageSettings.margins.all = 0; // Reset margins for original
                  page = outputDocument.pages.add();
                  page.graphics.drawPdfTemplate(template, Offset.zero);
              }
           }
           inputDocument.dispose();
        }
      }
      
      List<int> bytes = await outputDocument.save();
      outputDocument.dispose();
      return bytes;
      
    } catch (e) {
      outputDocument.dispose();
      rethrow;
    }
  }
}
