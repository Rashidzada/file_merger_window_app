import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_merger_tool/models/pdf_item.dart';
import 'package:pdf_merger_tool/models/project_backup.dart';

void main() {
  group('PdfItem Serialization', () {
    test('should serialize and deserialize correctly', () {
      final item = PdfItem(
        id: '123',
        filePath: 'C:/test.pdf',
        fileName: 'test.pdf',
        fileSizeBytes: 1024,
        addedAt: DateTime(2023, 1, 1),
        orderIndex: 0,
        pageCount: 5,
      );

      final map = item.toMap();
      final newItem = PdfItem.fromMap(map);

      expect(newItem.id, item.id);
      expect(newItem.filePath, item.filePath);
      expect(newItem.pageCount, 5);
      expect(newItem.addedAt, item.addedAt);
    });
  });

  group('ProjectBackup Serialization', () {
    test('should backup and restore project list', () {
      final items = [
        PdfItem(
          filePath: 'C:/1.pdf',
          fileName: '1.pdf',
          fileSizeBytes: 100,
          addedAt: DateTime.now(),
          orderIndex: 0,
        ),
        PdfItem(
          filePath: 'C:/2.pdf',
          fileName: '2.pdf',
          fileSizeBytes: 200,
          addedAt: DateTime.now(),
          orderIndex: 1,
        ),
      ];

      final backup = ProjectBackup(
        projectName: 'My Project',
        createdAt: DateTime.now(),
        items: items,
      );

      final map = backup.toMap();
      final restored = ProjectBackup.fromMap(map);

      expect(restored.projectName, 'My Project');
      expect(restored.items.length, 2);
      expect(restored.items[0].fileName, '1.pdf');
    });
  });
}
