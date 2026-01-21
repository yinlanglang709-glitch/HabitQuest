class Habit {
  final String id;
  final String userId;
  final String title;
  final String notes;
  final String icon;
  final String color;
  final int streak;
  final String createdAt;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.notes,
    required this.icon,
    required this.color,
    required this.streak,
    required this.createdAt,
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
    );
  }

  static Habit fromMap(Map<String, dynamic> map) => Habit(
    id: map['id'],
    userId: map['user_id'],
    title: map['title'],
    notes: map['notes'] ?? '',
    icon: map['icon'] ?? 'sun',
    color: map['color'] ?? 'blue',
    streak: map['streak'] ?? 0,
    createdAt: map['created_at'] ?? '',
  );
}