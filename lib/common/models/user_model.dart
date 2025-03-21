import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String animatorId;

  @HiveField(2)
  final List<String> accessTypes;

  @HiveField(3)
  final int userTypeId;

  @HiveField(4)
  final String userTypeLabel;

  @HiveField(5)
  final Map<String, dynamic> userAccess;

  @HiveField(6)
  final List<Map<String, dynamic>> projects;

  @HiveField(7)
  final Map<String, dynamic> office;

  UserModel({
    required this.userId,
    required this.animatorId,
    required this.accessTypes,
    required this.userTypeId,
    required this.userTypeLabel,
    required this.userAccess,
    required this.projects,
    required this.office,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userid']?.toString() ?? '',
      animatorId: json['animator_id']?.toString() ?? '',
      accessTypes: (json['access_type'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          [],
      userTypeId: int.tryParse(json['user_type_id']?.toString() ?? '') ?? 0,
      userTypeLabel: json['user_type_label']?.toString() ?? '',
      userAccess: json['user_access'] as Map<String, dynamic>? ?? {},
      projects: (json['projects'] as List?)
              ?.map((x) => x as Map<String, dynamic>)
              .toList() ??
          [],
      office: json['office'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'animator_id': animatorId,
      'access_type': accessTypes.join(','),
      'user_type_id': userTypeId,
      'user_type_label': userTypeLabel,
      'user_access': userAccess,
      'projects': projects,
      'office': office,
    };
  }

  // Helper methods
  bool hasAccess(String accessType) => accessTypes.contains(accessType);

  bool hasFeatureAccess(String feature) {
    final features = {
      'observation_report': userAccess['observatin_report'] == 1,
      'attendance': userAccess['attendance'] == 1,
      'project_monitoring': userAccess['project_monitoring'] == 1,
    };
    return features[feature] ?? false;
  }

  String get projectTitle =>
      projects.isNotEmpty ? projects.first['project_title'] ?? '' : '';
  String get officeTitle => office['office_title'] ?? '';
}

@HiveType(typeId: 2)
class UserAccess extends HiveObject {
  @HiveField(0)
  final int observationReport;

  @HiveField(1)
  final int attendance;

  @HiveField(2)
  final int projectMonitoring;

  UserAccess({
    required this.observationReport,
    required this.attendance,
    required this.projectMonitoring,
  });

  factory UserAccess.fromJson(Map<String, dynamic> json) {
    return UserAccess(
      observationReport:
          int.tryParse(json['observatin_report']?.toString() ?? '0') ?? 0,
      attendance: int.tryParse(json['attendance']?.toString() ?? '0') ?? 0,
      projectMonitoring:
          int.tryParse(json['project_monitoring']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'observatin_report': observationReport,
      'attendance': attendance,
      'project_monitoring': projectMonitoring,
    };
  }
}

@HiveType(typeId: 3)
class Project extends HiveObject {
  @HiveField(0)
  final String projectId;

  @HiveField(1)
  final String projectTitle;

  Project({
    required this.projectId,
    required this.projectTitle,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id']?.toString() ?? '',
      projectTitle: json['project_title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_title': projectTitle,
    };
  }
}

@HiveType(typeId: 4)
class Office extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String officeTitle;

  Office({
    required this.id,
    required this.officeTitle,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id']?.toString() ?? '',
      officeTitle: json['office_title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'office_title': officeTitle,
    };
  }
}
