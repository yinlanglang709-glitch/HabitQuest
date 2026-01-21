class UserSettings {
  final bool isDarkMode;
  final String accentColor;

  UserSettings({required this.isDarkMode, required this.accentColor});

  Map<String, dynamic> toMap() => {
    'id': 1,
    'is_dark_mode': isDarkMode ? 1 : 0,
    'accent_color': accentColor,
  };

  UserSettings copyWith({bool? isDarkMode, String? accentColor}) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  static UserSettings fromMap(Map<String, dynamic> map) => UserSettings(
    isDarkMode: map['is_dark_mode'] == 1,
    accentColor: map['accent_color'] ?? 'blue',
  );
}