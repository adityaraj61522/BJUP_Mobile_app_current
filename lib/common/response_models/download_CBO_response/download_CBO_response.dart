import 'package:hive/hive.dart';

part 'download_CBO_response.g.dart';

@HiveType(typeId: 2222)
class DownloadCBODataResponse extends HiveObject {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<VillageResData> selectedVillages;

  @HiveField(3)
  final List<CBO> beneficiaries;

  @HiveField(4)
  final List<CBO> cbos;

  @HiveField(5)
  final List<CBO> others;

  DownloadCBODataResponse({
    required this.responseCode,
    required this.message,
    required this.selectedVillages,
    required this.beneficiaries,
    required this.cbos,
    required this.others,
  });

  factory DownloadCBODataResponse.fromMap(Map<String, dynamic> json) {
    return DownloadCBODataResponse(
      responseCode: json['response_code'] ?? 0,
      message: json['message'] ?? '',
      selectedVillages: (json['data']['selected_villages'] as List?)
              ?.map((v) => VillageResData.fromMap(v))
              .toList() ??
          [],
      beneficiaries: (json['data']['benificiary'] as List?)
              ?.map((b) => CBO.fromMap(b))
              .toList() ??
          [],
      cbos:
          (json['data']['cbo'] as List?)?.map((c) => CBO.fromMap(c)).toList() ??
              [],
      others: (json['data']['others'] as List?)
              ?.map((o) => CBO.fromMap(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'message': message,
      'data': {
        'selected_villages': selectedVillages.map((v) => v.toJson()).toList(),
        'benificiary': beneficiaries.map((b) => b.toJson()).toList(),
        'cbo': cbos.map((c) => c.toJson()).toList(),
        'others': others.map((o) => o.toJson()).toList(),
      },
    };
  }
}

@HiveType(typeId: 3333)
class VillageResData extends HiveObject {
  @HiveField(0)
  final String villageId;

  @HiveField(1)
  final String villageName;

  VillageResData({
    required this.villageId,
    required this.villageName,
  });

  factory VillageResData.fromMap(Map<String, dynamic> json) {
    return VillageResData(
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

@HiveType(typeId: 4444)
class CBO extends HiveObject {
  @HiveField(0)
  final String cboId;

  @HiveField(1)
  final String partnerId;

  @HiveField(2)
  final String projectId;

  @HiveField(3)
  final String stateCode;

  @HiveField(4)
  final String districtCode;

  @HiveField(5)
  final String blockCode;

  @HiveField(6)
  final String villageCode;

  @HiveField(7)
  final String cboName;

  @HiveField(8)
  final String createdBy;

  @HiveField(9)
  final String createdDate;

  @HiveField(10)
  final String? updatedBy;

  @HiveField(11)
  final String? updatedDate;

  @HiveField(12)
  final String status;

  @HiveField(13)
  final String ipAddress;

  CBO({
    required this.cboId,
    required this.partnerId,
    required this.projectId,
    required this.stateCode,
    required this.districtCode,
    required this.blockCode,
    required this.villageCode,
    required this.cboName,
    required this.createdBy,
    required this.createdDate,
    this.updatedBy,
    this.updatedDate,
    required this.status,
    required this.ipAddress,
  });

  factory CBO.fromMap(Map<String, dynamic> json) {
    return CBO(
      cboId: json['cboid'] ?? '',
      partnerId: json['partnerid'] ?? '',
      projectId: json['projectid'] ?? '',
      stateCode: json['statecode'] ?? '',
      districtCode: json['districtcode'] ?? '',
      blockCode: json['blockcode'] ?? '',
      villageCode: json['villagecode'] ?? '',
      cboName: json['cboname'] ?? '',
      createdBy: json['createdby'] ?? '',
      createdDate: json['createddate'] ?? '',
      updatedBy: json['updatedby'],
      updatedDate: json['updateddate'],
      status: json['cstatus'] ?? '',
      ipAddress: json['ipaddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cboid': cboId,
      'partnerid': partnerId,
      'projectid': projectId,
      'statecode': stateCode,
      'districtcode': districtCode,
      'blockcode': blockCode,
      'villagecode': villageCode,
      'cboname': cboName,
      'createdby': createdBy,
      'createddate': createdDate,
      'updatedby': updatedBy,
      'updateddate': updatedDate,
      'cstatus': status,
      'ipaddress': ipAddress,
    };
  }
}
