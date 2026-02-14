import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pdf_item.dart';
import '../providers/pdf_provider.dart';
import '../providers/pdf_provider.dart';
import 'package:intl/intl.dart';
import 'pdf_thumbnail.dart';

class PdfListItem extends ConsumerWidget {
  final PdfItem item;
  final int index;

  const PdfListItem({super.key, required this.item, required this.index});

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: PdfThumbnail(
            filePath: item.filePath,
            type: item.type,
          ),
        ),
        title: Text(item.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.filePath, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
            Text('${_formatBytes(item.fileSizeBytes)} • Added: ${DateFormat('HH:mm').format(item.addedAt)}', style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             IconButton(
               icon: const Icon(Icons.delete, color: Colors.grey),
               onPressed: () {
                 ref.read(pdfListProvider.notifier).removeFile(item.id);
               },
             ),
             // Handler for reorder is usually automatic in ReorderableListView, but we can add handle here if needed.
             ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
             ),
          ],
        ),
      ),
    );
  }
}
