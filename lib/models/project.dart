import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Proyek portofolio yang disinkronkan dengan API Django REST Framework.
///
/// Field mengikuti `ProjectSerializer` backend: id, title, description, tags,
/// link, thumbnail, star_count, is_starred, starred_by_names.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.tags,
    this.id,
    this.link,
    this.thumbnail,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID dari server; tidak ikut dikirim pada body POST/PUT.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;

  /// Tag dipisahkan koma, mis. "Flutter, Django".
  final String tags;

  /// URL proyek dan thumbnail bersifat opsional (null atau kosong).
  final String? link;
  final String? thumbnail;

  /// Hanya-baca dari server, jadi tidak ikut dikirim.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  /// Daftar tag hasil pemisahan `tags` berdasarkan koma (tidak diserialisasi).
  List<String> get tagList =>
      tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
