import 'pdf_item.dart';

class ProjectBackup {
  final String projectName;
  final DateTime createdAt;
  final List<PdfItem> items;

  ProjectBackup({
    required this.projectName,
    required this.createdAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectName': projectName,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory ProjectBackup.fromMap(Map<String, dynamic> map) {
    return ProjectBackup(
      projectName: map['projectName'] ?? 'Untitled Project',
      createdAt: DateTime.parse(map['createdAt']),
      items: List<PdfItem>.from(
        (map['items'] as List<dynamic>).map((x) => PdfItem.fromMap(x)),
      ),
    );
  }
}
