import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pdf_provider.dart';
import '../widgets/drop_zone.dart';
import '../widgets/pdf_list_item.dart';
import '../widgets/action_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfItems = ref.watch(pdfListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Merger Tool'),
        actions: [
          IconButton(
            tooltip: 'Import Backup',
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final missing = await ref.read(pdfListProvider.notifier).importBackup();
              if (missing != null && missing.isNotEmpty) {
                 // Show warning
              }
            },
          ),
          IconButton(
            tooltip: 'Export Backup',
            icon: const Icon(Icons.save_as),
            onPressed: () async {
              await ref.read(pdfListProvider.notifier).exportBackup();
            },
          ),
           IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
               showAboutDialog(
                 context: context,
                 applicationName: 'PDF Merger Tool',
                 applicationVersion: '1.0.0',
                 applicationLegalese: 'Copyright © 2026 Rashid Zada\nFull Stack Developer (Since 2020)\nEmail: rashidzada6@gmail.com',
                 children: [
                   const Text('A simple offline tool to merge PDF files.'),
                   const SizedBox(height: 10),
                   const Text('Privacy: Files are processed locally and never leave your computer.'),
                 ],
               );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side: List and Drag Zone
          Expanded(
            flex: 3,
            child: DropZoneWidget(
              child: Column(
                children: [
                  // Add Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DottedBorderContainer(
                      onTap: () {
                        ref.read(pdfListProvider.notifier).addFiles();
                      },
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 48, color: Colors.teal),
                            SizedBox(height: 8),
                            Text('Click to Add PDFs or Drag & Drop Here', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // List
                  Expanded(
                    child: pdfItems.isEmpty
                        ? const Center(child: Text('No files selected', style: TextStyle(color: Colors.grey)))
                        : ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            onReorder: (oldIndex, newIndex) {
                              ref.read(pdfListProvider.notifier).reorder(oldIndex, newIndex);
                            },
                            itemCount: pdfItems.length,
                            itemBuilder: (context, index) {
                              final item = pdfItems[index];
                              return PdfListItem(
                                key: ValueKey(item.id),
                                item: item,
                                index: index,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Side: Action Panel
          const ActionPanel(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 30,
        color: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          'Ready', // TODO: connect to status state if needed
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const DottedBorderContainer({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.teal.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal, style: BorderStyle.solid, width: 2), // Dashed border needs external package or custom painter, using solid for now
        ),
        child: child,
      ),
    );
  }
}
