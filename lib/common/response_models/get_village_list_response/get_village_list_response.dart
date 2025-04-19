import 'package:hive/hive.dart';

part 'get_village_list_response.g.dart';

@HiveType(typeId: 222)
class GetVillageListResponse extends HiveObject {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<VillagesList> villages;

  @HiveField(3)
  final List<InterviewTypeList> interviewTypes;

  GetVillageListResponse({
    required this.responseCode,
    required this.message,
    required this.villages,
    required this.interviewTypes,
  });

  factory GetVillageListResponse.fromMap(Map<String, dynamic> json) {
    return GetVillageListResponse(
      responseCode: json['response_code'] ?? 0,
      message: json['message'] ?? '',
      villages: (json['data']['villages'] as List?)
              ?.map((v) => VillagesList.fromMap(v))
              .toList() ??
          [],
      interviewTypes: (json['data']['interview_type'] as List?)
              ?.map((i) => InterviewTypeList.fromMap(i))
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

@HiveType(typeId: 333)
class VillagesList extends HiveObject {
  @HiveField(0)
  final String villageId;

  @HiveField(1)
  final String villageName;

  VillagesList({
    required this.villageId,
    required this.villageName,
  });

  factory VillagesList.fromMap(Map<String, dynamic> json) {
    return VillagesList(
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

@HiveType(typeId: 444)
class InterviewTypeList extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  InterviewTypeList({
    required this.id,
    required this.type,
  });

  factory InterviewTypeList.fromMap(Map<String, dynamic> json) {
    return InterviewTypeList(
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
