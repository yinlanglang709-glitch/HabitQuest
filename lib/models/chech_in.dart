class CheckIn {
  final String id;
  final String habitId;
  final String date;
  final String notes;
  final String timestamp;

  CheckIn({
    required this.id,
    required this.habitId,
    required this.date,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'habit_id': habitId,
    'check_date': date,
    'notes': notes,
    'timestamp': timestamp,
  };

  static CheckIn fromMap(Map<String, dynamic> map) => CheckIn(
    id: map['id'],
    habitId: map['habit_id'],
    date: map['check_date'],
    notes: map['notes'] ?? '',
    timestamp: map['timestamp'] ?? '',
  );
}