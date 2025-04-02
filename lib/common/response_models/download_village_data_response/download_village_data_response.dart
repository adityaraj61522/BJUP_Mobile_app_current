import 'package:hive/hive.dart';

part 'download_village_data_response.g.dart';

@HiveType(typeId: 22)
class DownloadVillageDataResponse extends HiveObject {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<Village> villages;

  @HiveField(3)
  final List<InterviewType> interviewTypes;

  DownloadVillageDataResponse({
    required this.responseCode,
    required this.message,
    required this.villages,
    required this.interviewTypes,
  });

  factory DownloadVillageDataResponse.fromMap(Map<String, dynamic> json) {
    return DownloadVillageDataResponse(
      responseCode: json['response_code'] ?? 0,
      message: json['message'] ?? '',
      villages: (json['data']['villages'] as List?)
              ?.map((v) => Village.fromMap(v))
              .toList() ??
          [],
      interviewTypes: (json['data']['interview_type'] as List?)
              ?.map((i) => InterviewType.fromMap(i))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'message': message,
      'data': {
        'villages': villages.map((v) => v.toJson()).toList(),
        'interview_type': interviewTypes.map((i) => i.toJson()).toList(),
      },
    };
  }
}

@HiveType(typeId: 33)
class Village extends HiveObject {
  @HiveField(0)
  final String villageId;

  @HiveField(1)
  final String villageName;

  Village({
    required this.villageId,
    required this.villageName,
  });

  factory Village.fromMap(Map<String, dynamic> json) {
    return Village(
      villageId: json['village_id'] ?? '',
      villageName: json['village_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'village_id': villageId,
      'village_name': villageName,
    };
  }
}

@HiveType(typeId: 44)
class InterviewType extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  InterviewType({
    required this.id,
    required this.type,
  });

  factory InterviewType.fromMap(Map<String, dynamic> json) {
    return InterviewType(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}
