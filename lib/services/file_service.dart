import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/pdf_item.dart';
import '../models/project_backup.dart';

class FileService {
  Future<List<PdfItem>> pickPdfFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'bmp'],
      allowMultiple: true,
    );

    if (result != null) {
      List<PdfItem> items = [];
      for (var file in result.files) {
        if (file.path != null) {
          final f = File(file.path!);
          final size = await f.length();
          final ext = p.extension(file.path!).toLowerCase();
          final isImage = ['.jpg', '.jpeg', '.png', '.bmp'].contains(ext);
          
          final item = PdfItem(
            filePath: file.path!,
            fileName: file.name,
            fileSizeBytes: size,
            addedAt: DateTime.now(),
            orderIndex: 0, 
            type: isImage ? PdfItemType.image : PdfItemType.pdf,
          );
          items.add(item);
        }
      }
      return items;
    }
    return [];
  }

  Future<String?> saveMergedPdf(List<int> bytes, String defaultName) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Merged PDF',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputFile != null) {
      // Ensure extension
      if (!outputFile.toLowerCase().endsWith('.pdf')) {
        outputFile += '.pdf';
      }
      
      final file = File(outputFile);
      await file.writeAsBytes(bytes);
      return outputFile;
    }
    return null;
  }

  Future<String?> exportProject(ProjectBackup backup) async {
    final jsonStr = jsonEncode(backup.toMap());
    
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Project Backup',
      fileName: '${backup.projectName}_backup.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (outputFile != null) {
       if (!outputFile.toLowerCase().endsWith('.json')) {
        outputFile += '.json';
      }
      final file = File(outputFile);
      await file.writeAsString(jsonStr);
      return outputFile;
    }
    return null;
  }

  Future<ProjectBackup?> importProject() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonStr = await file.readAsString();
      final map = jsonDecode(jsonStr);
      return ProjectBackup.fromMap(map);
    }
    return null;
  }
}
