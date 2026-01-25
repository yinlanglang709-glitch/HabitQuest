class Habit {
  final String id;
  final String userId;
  final String title;
  final String notes;
  final String icon;
  final String color;
  final int streak;
  final String createdAt;
  final bool isArchived;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.notes,
    required this.icon,
    required this.color,
    required this.streak,
    required this.createdAt,
    required this.isArchived,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'notes': notes,
    'icon': icon,
    'color': color,
    'streak': streak,
    'created_at': createdAt,
    'is_archived': isArchived ? 1 : 0,
  };

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? notes,
    String? icon,
    String? color,
    int? streak,
    String? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      streak: streak ?? this.streak,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  static Habit fromMap(Map<String, dynamic> map) {
    final rawArchived = map['is_archived'];
    final isArchived = rawArchived == 1 ||
        rawArchived == true ||
        rawArchived == '1' ||
        rawArchived == 'true';
    return Habit(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      notes: map['notes'] ?? '',
      icon: map['icon'] ?? 'sun',
      color: map['color'] ?? 'blue',
      streak: map['streak'] ?? 0,
      createdAt: map['created_at'] ?? '',
      isArchived: isArchived,
    );
  }
}
