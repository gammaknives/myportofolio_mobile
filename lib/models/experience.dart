import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

const Map<String, String> experienceCategories = {
  'internship': 'Internship',
  'research': 'Research',
  'volunteer': 'Volunteer',
  'part-time': 'Part-Time',
  'full-time': 'Full-Time',
  'freelance': 'Freelance',
};

@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    this.category = 'full-time',
    this.endedAt,
    this.id,
    this.categoryDisplay = '',
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;

  @JsonKey(defaultValue: 'full-time')
  final String category;

  final DateTime? endedAt;

  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  bool get isOngoing => endedAt == null;

  String get categoryLabel => categoryDisplay.isNotEmpty
      ? categoryDisplay
      : (experienceCategories[category] ?? category);

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}
