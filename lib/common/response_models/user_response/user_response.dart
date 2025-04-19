import 'package:hive/hive.dart';

part 'user_response.g.dart';

@HiveType(typeId: 1)
class UserLoginResponse extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String? mobileNo;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String animatorId;

  @HiveField(5)
  final List<String> accessTypes;

  @HiveField(6)
  final int userTypeId;

  @HiveField(7)
  final String userTypeLabel;

  @HiveField(8)
  final UserAccessData userAccess;

  @HiveField(9)
  final List<ProjectList> projects;

  @HiveField(10)
  final OfficeData office;

  @HiveField(11)
  final String? plan;

  UserLoginResponse({
    required this.userId,
    required this.username,
    this.mobileNo,
    required this.email,
    required this.animatorId,
    required this.accessTypes,
    required this.userTypeId,
    required this.userTypeLabel,
    required this.userAccess,
    required this.projects,
    required this.office,
    this.plan,
  });

  factory UserLoginResponse.fromMap(Map<String, dynamic> json) {
    return UserLoginResponse(
      userId: json['userid'] ?? '',
      username: json['username'] ?? '',
      mobileNo: json['mobileno'],
      email: json['email'] ?? '',
      animatorId: json['animator_id'] ?? '',
      accessTypes: (json['access_type'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          [],
      userTypeId: int.tryParse(json['user_type_id']?.toString() ?? '') ?? 0,
      userTypeLabel: json['user_type_label']?.toString() ?? '',
      userAccess: UserAccessData.fromMap(json['user_access'] ?? {}),
      projects: (json['projects'] as List<dynamic>?)
              ?.map((x) => ProjectList.fromMap(x))
              .toList() ??
          [],
      office: OfficeData.fromMap(json['office'] ?? {}),
      plan: json['plan'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'userid': userId,
      'username': username,
      'mobileno': mobileNo,
      'email': email,
      'animator_id': animatorId,
      'access_type': accessTypes.join(','),
      'user_type_id': userTypeId,
      'user_type_label': userTypeLabel,
      'user_access': userAccess.toJson(),
      'projects': projects.map((p) => p.toMap()).toList(),
      'office': office.toJson(),
      'plan': plan,
    };
  }

  bool hasAccess(String accessType) => accessTypes.contains(accessType);

  bool hasFeatureAccess(String feature) {
    final features = {
      'observation_report': userAccess.observationReport == 1,
      'attendance': userAccess.attendance == 1,
      'project_monitoring': userAccess.projectMonitoring == 1,
    };
    return features[feature] ?? false;
  }

  String get projectTitle =>
      projects.isNotEmpty ? projects.first.projectTitle : '';
}

@HiveType(typeId: 2)
class UserAccessData extends HiveObject {
  @HiveField(0)
  final int observationReport;

  @HiveField(1)
  final int attendance;

  @HiveField(2)
  final int projectMonitoring;

  UserAccessData({
    required this.observationReport,
    required this.attendance,
    required this.projectMonitoring,
  });

  factory UserAccessData.fromMap(Map<String, dynamic> json) {
    return UserAccessData(
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

@HiveType(typeId: 6)
class ProjectList extends HiveObject {
  @HiveField(0)
  final String projectId;

  @HiveField(1)
  final String projectTitle;

  ProjectList({
    required this.projectId,
    required this.projectTitle,
  });

  factory ProjectList.fromMap(Map<String, dynamic> json) {
    return ProjectList(
      projectId: json['project_id']?.toString() ?? '',
      projectTitle: json['project_title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'project_title': projectTitle,
    };
  }
}

@HiveType(typeId: 7)
class OfficeData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String officeTitle;

  OfficeData({
    required this.id,
    required this.officeTitle,
  });

  factory OfficeData.fromMap(Map<String, dynamic> json) {
    return OfficeData(
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
