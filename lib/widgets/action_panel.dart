import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pdf_provider.dart';
import '../models/page_size_option.dart';

class ActionPanel extends ConsumerStatefulWidget {
  const ActionPanel({super.key});

  @override
  ConsumerState<ActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends ConsumerState<ActionPanel> {
  bool _isMerging = false;

  @override
  Widget build(BuildContext context) {
    final pdfItems = ref.watch(pdfListProvider);
    final totalSize = pdfItems.fold<int>(0, (sum, item) => sum + item.fileSizeBytes);

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Files:', '${pdfItems.length}'),
          _buildInfoRow('Total Size:', _formatBytes(totalSize)),
          
          const Divider(height: 32),
          Text('Page Size / Output', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final currentSize = ref.watch(pageSizeProvider);
              return DropdownButton<PageSizeOption>(
                value: currentSize,
                isExpanded: true,
                items: PageSizeOption.values.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(pageSizeProvider.notifier).set(val);
                  }
                },
              );
            },
          ),
          
          const Spacer(),
          
          if (_isMerging)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton.icon(
              onPressed: pdfItems.length < 2 ? null : _handleMerge,
              icon: const Icon(Icons.merge_type),
              label: const Text('Merge PDFs'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: pdfItems.isEmpty ? null : () {
              ref.read(pdfListProvider.notifier).clearAll();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _handleMerge() async {
    setState(() => _isMerging = true);
    
    try {
      final notifier = ref.read(pdfListProvider.notifier);
      final defaultName = 'merged_${DateTime.now().millisecondsSinceEpoch}';
      
      final savedPath = await notifier.mergeAndSave(defaultName);
      
      if (mounted) {
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully saved to: $savedPath'),
              action: SnackBarAction(
                label: 'Open Folder',
                onPressed: () {
                  // TODO: Implement open folder logic if url_launcher supports file:// or Process.run explorer
                },
              ),
            ),
          );
        } else {
           // Cancelled
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error merging: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isMerging = false);
    }
  }
}
