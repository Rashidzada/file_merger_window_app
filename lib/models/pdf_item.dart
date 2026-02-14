import 'package:uuid/uuid.dart';

enum PdfItemType { pdf, image }

class PdfItem {
  final String id;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final DateTime addedAt;
  final int orderIndex;
  final int? pageCount;
  final PdfItemType type;

  PdfItem({
    String? id,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.addedAt,
    required this.orderIndex,
    this.pageCount,
    this.type = PdfItemType.pdf,
  }) : id = id ?? const Uuid().v4();

  // CopyWith for immutability updates
  PdfItem copyWith({
    String? id,
    String? filePath,
    String? fileName,
    int? fileSizeBytes,
    DateTime? addedAt,
    int? orderIndex,
    int? pageCount,
    PdfItemType? type,
  }) {
    return PdfItem(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      addedAt: addedAt ?? this.addedAt,
      orderIndex: orderIndex ?? this.orderIndex,
      pageCount: pageCount ?? this.pageCount,
      type: type ?? this.type,
    );
  }

  // To Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'addedAt': addedAt.toIso8601String(),
      'orderIndex': orderIndex,
      'pageCount': pageCount,
      'type': type.index,
    };
  }

  // From Map for JSON deserialization
  factory PdfItem.fromMap(Map<String, dynamic> map) {
    return PdfItem(
      id: map['id'],
      filePath: map['filePath'],
      fileName: map['fileName'],
      fileSizeBytes: map['fileSizeBytes'],
      addedAt: DateTime.parse(map['addedAt']),
      orderIndex: map['orderIndex'],
      pageCount: map['pageCount'],
      type: map['type'] != null ? PdfItemType.values[map['type']] : PdfItemType.pdf,
    );
  }
}
