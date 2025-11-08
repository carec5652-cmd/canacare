// Publication Model
// نموذج بيانات المنشورات
class PublicationModel {
  final String id;
  final String title;
  final String content;
  final String? coverImageUrl;
  final String authorId; // Admin who created it
  final String? authorName;
  final List<String> tags;
  final String visibility; // 'public', 'doctors_only', 'staff_only'
  final DateTime createdAt;
  final DateTime? updatedAt;

  PublicationModel({
    required this.id,
    required this.title,
    required this.content,
    this.coverImageUrl,
    required this.authorId,
    this.authorName,
    this.tags = const [],
    this.visibility = 'public',
    required this.createdAt,
    this.updatedAt,
  });

  // From Firestore
  factory PublicationModel.fromMap(Map<String, dynamic> map, String id) {
    return PublicationModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'],
      tags: List<String>.from(map['tags'] ?? []),
      visibility: map['visibility'] ?? 'public',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'coverImageUrl': coverImageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'tags': tags,
      'visibility': visibility,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  PublicationModel copyWith({
    String? title,
    String? content,
    String? coverImageUrl,
    String? authorName,
    List<String>? tags,
    String? visibility,
    DateTime? updatedAt,
  }) {
    return PublicationModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      authorId: authorId,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

