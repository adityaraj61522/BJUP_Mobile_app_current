class VillageDetailResponse {
  final int responseCode;
  final String message;
  final VillageDetailData data;

  VillageDetailResponse({
    required this.responseCode,
    required this.message,
    required this.data,
  });

  factory VillageDetailResponse.fromJson(Map<String, dynamic> json) {
    return VillageDetailResponse(
      responseCode: json['response_code'],
      message: json['message'],
      data: VillageDetailData.fromJson(json['data']),
    );
  }
}

class VillageDetailData {
  final VillageInfo villageInfo;

  VillageDetailData({required this.villageInfo});

  factory VillageDetailData.fromJson(Map<String, dynamic> json) {
    return VillageDetailData(
      villageInfo: VillageInfo.fromJson(json['village_info']),
    );
  }
}

class VillageInfo {
  final String villageCode;
  final String villageCodeIgsss;
  final String blockCode;
  final String districtCode;
  final String stateCode;
  final String panchayat;
  final String name;
  final String cStatus;

  VillageInfo({
    required this.villageCode,
    required this.villageCodeIgsss,
    required this.blockCode,
    required this.districtCode,
    required this.stateCode,
    required this.panchayat,
    required this.name,
    required this.cStatus,
  });

  factory VillageInfo.fromJson(Map<String, dynamic> json) {
    return VillageInfo(
      villageCode: json['villagecode'],
      villageCodeIgsss: json['villagecode_igsss'],
      blockCode: json['blockcode'],
      districtCode: json['districtcode'],
      stateCode: json['statecode'],
      panchayat: json['Panchayat'],
      name: json['name'],
      cStatus: json['cStatus'],
    );
  }
}
