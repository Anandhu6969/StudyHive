import 'material_item.dart';

class Bookmark {
  final int? id;
  final int materialId;
  final MaterialItem? material;

  Bookmark({
    this.id,
    required this.materialId,
    this.material,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    // If the json is a MaterialItem itself (returned directly from backend /Bookmarks)
    if (json.containsKey('title') || json.containsKey('subject')) {
      final material = MaterialItem.fromJson(json);
      return Bookmark(
        id: material.id,
        materialId: material.id,
        material: material,
      );
    }

    return Bookmark(
      id: json['id'],
      materialId: json['materialId'] ?? 0,
      material: json['material'] != null
          ? MaterialItem.fromJson(json['material'])
          : null,
    );
  }
}
