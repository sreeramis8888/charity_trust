class NotificationModel {
  final String id;
  final String subject;
  final String content;
  final String? image;
  final String? link;
  final DateTime createdAt;
  final bool isRead;
  final String tag;
  final List<String> typeList;

  NotificationModel({
    required this.id,
    required this.subject,
    required this.content,
    this.image,
    this.link,
    required this.createdAt,
    this.isRead = false,
    required this.tag,
    this.typeList = const [],
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    // Check if current user has read this notification
    bool isRead = false;
    final users = json['users'] as List<dynamic>?;
    
    if (users != null && users.isNotEmpty) {
      if (currentUserId != null && currentUserId.isNotEmpty) {
        // Find the entry for the current user
        for (var userEntry in users) {
          final userId = userEntry['user'];
          if (userId == currentUserId) {
            isRead = userEntry['read'] ?? false;
            print('DEBUG: Found user $currentUserId in notification, isRead: $isRead');
            break;
          }
        }
        if (!isRead) {
          print('DEBUG: User $currentUserId not found in users list. Available users: ${users.map((u) => u['user']).toList()}');
        }
      } else {
        // Fallback to first user if no current user ID provided
        print('DEBUG: No currentUserId provided, using first user. CurrentUserId: $currentUserId');
        isRead = users.first['read'] ?? false;
      }
    }

    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      image: json['image'],
      link: json['link'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: isRead,
      tag: json['tag'] ?? 'general',
      typeList: List<String>.from(json['type'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'subject': subject,
      'content': content,
      'image': image,
      'link': link,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'tag': tag,
      'type': typeList,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? subject,
    String? content,
    String? image,
    String? link,
    DateTime? createdAt,
    bool? isRead,
    String? tag,
    List<String>? typeList,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      image: image ?? this.image,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      tag: tag ?? this.tag,
      typeList: typeList ?? this.typeList,
    );
  }
}
