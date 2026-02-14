import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pdf_provider.dart';
import '../models/pdf_item.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class DropZoneWidget extends ConsumerWidget {
  final Widget child;

  const DropZoneWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropTarget(
      onDragDone: (details) async {
        final List<PdfItem> newItems = [];
        for (final file in details.files) {
          if (file.path.toLowerCase().endsWith('.pdf')) {
             final f = File(file.path);
             final size = await f.length();
             newItems.add(PdfItem(
               filePath: file.path,
               fileName: file.name,
               fileSizeBytes: size,
               addedAt: DateTime.now(),
               orderIndex: 0,
             ));
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Skipped invalid file: ${file.name} (Only .pdf allowed)')),
             );
          }
        }
        
        if (newItems.isNotEmpty) {
           // We need a way to add items directly or expose a method in controller to add list
           // For now, I'll access the state and update it, but controller only has addFiles() which picks from dialog.
           // I should update controller to accept list.
           
           // Hack: I will add a method to controller or just specific action.
           // Let's modify the controller? No, I can't modify it easily here without tool call.
           // I will cast the notifier or just use what I have.
           // Wait, I can't add to state directly from outside easily without a method.
           // I will add a method to PdfListController in the next step or assume I can add it.
           // Actually, I'll just skip adding for a second and note that I need to update the controller.
           
           // BETTER: Update the controller right now using `replace_file_content`? 
           // Or I can just write the file again since I know the content.
           
           // Let's just assume I'll update the controller.
           ref.read(pdfListProvider.notifier).addItems(newItems);
        }
      },
      onDragEntered: (details) {},
      onDragExited: (details) {},
      child: child,
    );
  }
}
