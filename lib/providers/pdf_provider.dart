import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pdf_item.dart';
import '../models/project_backup.dart';
import '../models/page_size_option.dart';
import '../services/file_service.dart';
import '../services/pdf_service.dart';

final fileServiceProvider = Provider((ref) => FileService());
final pdfServiceProvider = Provider((ref) => PdfService());

final pageSizeProvider = NotifierProvider<PageSizeNotifier, PageSizeOption>(() {
  return PageSizeNotifier();
});

class PageSizeNotifier extends Notifier<PageSizeOption> {
  @override
  PageSizeOption build() => PageSizeOption.original;

  void set(PageSizeOption option) {
    state = option;
  }
}

final pdfListProvider = NotifierProvider<PdfListController, List<PdfItem>>(() {
  return PdfListController();
});

class PdfListController extends Notifier<List<PdfItem>> {
  
  @override
  List<PdfItem> build() {
    return [];
  }

  Future<void> addFiles() async {
    final fileService = ref.read(fileServiceProvider);
    final newItems = await fileService.pickPdfFiles();
    if (newItems.isNotEmpty) {
      addItems(newItems);
    }
  }

  void addItems(List<PdfItem> newItems) {
    state = [
      ...state,
      ...newItems.map((e) => e.copyWith(orderIndex: state.length + newItems.indexOf(e))),
    ];
    _updateIndices();
  }

  void removeFile(String id) {
    state = state.where((item) => item.id != id).toList();
    _updateIndices();
  }

  void clearAll() {
    state = [];
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = [...state];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = items;
    _updateIndices();
  }

  void _updateIndices() {
    state = [
      for (int i = 0; i < state.length; i++) state[i].copyWith(orderIndex: i)
    ];
  }

  Future<String?> mergeAndSave(String defaultName) async {
    if (state.length < 2) return null;

    final pdfService = ref.read(pdfServiceProvider);
    final fileService = ref.read(fileServiceProvider);
    final pageSize = ref.read(pageSizeProvider);

    // Extract paths in order
    final paths = state.map((e) => e.filePath).toList();
    
    // Merge
    final bytes = await pdfService.mergePdfs(paths, pageSize: pageSize);
    
    // Save
    return await fileService.saveMergedPdf(bytes, defaultName);
  }

  Future<String?> exportBackup() async {
     final fileService = ref.read(fileServiceProvider);
     final backup = ProjectBackup(
       projectName: 'PDF_Merge_Project',
       createdAt: DateTime.now(),
       items: state,
     );
     return await fileService.exportProject(backup);
  }

  Future<List<String>?> importBackup() async {
    final fileService = ref.read(fileServiceProvider);
    final backup = await fileService.importProject();
    if (backup != null) {
      List<String> missingPaths = [];
      List<PdfItem> validItems = [];

      for (var item in backup.items) {
        validItems.add(item);
      }
      state = validItems;
      return missingPaths;
    }
    return null;
  }
}
