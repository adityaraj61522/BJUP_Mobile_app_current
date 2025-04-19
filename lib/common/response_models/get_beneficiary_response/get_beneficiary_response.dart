import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:hive/hive.dart';

part 'get_beneficiary_response.g.dart';

@HiveType(typeId: 170)
class GetBeneficeryResponse extends HiveObject {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<VillagesList> selectedVillages;

  @HiveField(3)
  final List<BeneficiaryData> beneficiaries;

  @HiveField(4)
  final List<CBOData> cbo;

  @HiveField(5)
  final List<CBOData> others;

  GetBeneficeryResponse({
    required this.responseCode,
    required this.message,
    required this.selectedVillages,
    required this.beneficiaries,
    required this.cbo,
    required this.others,
  });

  factory GetBeneficeryResponse.fromMap(Map<String, dynamic> json) {
    return GetBeneficeryResponse(
      responseCode: json['response_code'] ?? 0,
      message: json['message'] ?? '',
      selectedVillages: (json['data']['selected_villages'] as List?)
              ?.map((v) => VillagesList.fromMap(v))
              .toList() ??
          [],
      beneficiaries: (json['data']['benificiary'] as List?)
              ?.map((b) => BeneficiaryData.fromMap(b))
              .toList() ??
          [],
      cbo: (json['data']['cbo'] as List?)
              ?.map((c) => CBOData.fromMap(c))
              .toList() ??
          [],
      others: (json['data']['others'] as List?)
              ?.map((o) => CBOData.fromMap(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'response_code': responseCode,
        'message': message,
        'data': {
          'selected_villages': selectedVillages.map((v) => v.toJson()).toList(),
          'benificiary': beneficiaries.map((b) => b.toJson()).toList(),
          'cbo': cbo.map((c) => c.toJson()).toList(),
          'others': others.map((o) => o.toJson()).toList(),
        },
      };
}

@HiveType(typeId: 23)
class SelectedVillagesData extends HiveObject {
  @HiveField(0)
  final String villageId;

  @HiveField(1)
  final String villageName;

  SelectedVillagesData({
    required this.villageId,
    required this.villageName,
  });

  factory SelectedVillagesData.fromMap(Map<String, dynamic> json) =>
      SelectedVillagesData(
        villageId: json['village_id'] ?? '',
        villageName: json['village_name'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'village_id': villageId,
        'village_name': villageName,
      };
}

@HiveType(typeId: 24)
class BeneficiaryData extends HiveObject {
  @HiveField(0)
  final String beneficiaryId;

  @HiveField(1)
  final String villageCode;

  @HiveField(2)
  final String panchayat;

  @HiveField(3)
  final String blockCode;

  @HiveField(4)
  final String districtCode;

  @HiveField(5)
  final String stateCode;

  @HiveField(6)
  final String hof;

  @HiveField(7)
  final String? beneficiaryName;

  @HiveField(8)
  final String guardian;

  @HiveField(9)
  final String sex;

  @HiveField(10)
  final String? hhname;

  @HiveField(11)
  final String? hhgender;

  @HiveField(12)
  final String age;

  @HiveField(13)
  final String malebelow18;

  @HiveField(14)
  final String maleabove18;

  @HiveField(15)
  final String femalebelow18;

  @HiveField(16)
  final String femaleabove18;

  @HiveField(17)
  final String socialGroup;

  @HiveField(18)
  final String? category;

  @HiveField(19)
  final String? idtype;

  @HiveField(20)
  final String? idname;

  @HiveField(21)
  final String disability;

  @HiveField(22)
  final String projectId;

  @HiveField(23)
  final String partnerId;

  @HiveField(24)
  final String createdBy;

  @HiveField(25)
  final String createdDate;

  @HiveField(26)
  final String ipAddress;

  @HiveField(27)
  final String cStatus;

  @HiveField(28)
  final String? bstatus;

  BeneficiaryData({
    required this.beneficiaryId,
    required this.villageCode,
    required this.panchayat,
    required this.blockCode,
    required this.districtCode,
    required this.stateCode,
    required this.hof,
    required this.beneficiaryName,
    required this.guardian,
    required this.sex,
    required this.hhname,
    required this.hhgender,
    required this.age,
    required this.malebelow18,
    required this.maleabove18,
    required this.femalebelow18,
    required this.femaleabove18,
    required this.socialGroup,
    required this.category,
    required this.idtype,
    required this.idname,
    required this.disability,
    required this.projectId,
    required this.partnerId,
    required this.createdBy,
    required this.createdDate,
    required this.ipAddress,
    required this.cStatus,
    required this.bstatus,
  });

  factory BeneficiaryData.fromMap(Map<String, dynamic> json) => BeneficiaryData(
        beneficiaryId: json['beneficiaryid'] ?? '',
        villageCode: json['villagecode'] ?? '',
        panchayat: json['Panchayat'] ?? '',
        blockCode: json['blockcode'] ?? '',
        districtCode: json['districtcode'] ?? '',
        stateCode: json['statecode'] ?? '',
        hof: json['hof'] ?? '',
        beneficiaryName: json['benificiary_name'],
        guardian: json['guardian'] ?? '',
        sex: json['sex'] ?? '',
        hhname: json['hhname'],
        hhgender: json['hhgender'],
        age: json['age'] ?? '',
        malebelow18: json['malebelow18'] ?? '',
        maleabove18: json['maleabove18'] ?? '',
        femalebelow18: json['femalebelow18'] ?? '',
        femaleabove18: json['femaleabove18'] ?? '',
        socialGroup: json['socialgroup'] ?? '',
        category: json['category'],
        idtype: json['idtype'],
        idname: json['idname'],
        disability: json['disability'] ?? '',
        projectId: json['projectid'] ?? '',
        partnerId: json['partnerid'] ?? '',
        createdBy: json['createdby'] ?? '',
        createdDate: json['createddate'] ?? '',
        ipAddress: json['ipaddress'] ?? '',
        cStatus: json['cStatus'] ?? '',
        bstatus: json['bstatus'],
      );

  Map<String, dynamic> toJson() => {
        'beneficiaryid': beneficiaryId,
        'villagecode': villageCode,
        'Panchayat': panchayat,
        'blockcode': blockCode,
        'districtcode': districtCode,
        'statecode': stateCode,
        'hof': hof,
        'benificiary_name': beneficiaryName,
        'guardian': guardian,
        'sex': sex,
        'hhname': hhname,
        'hhgender': hhgender,
        'age': age,
        'malebelow18': malebelow18,
        'maleabove18': maleabove18,
        'femalebelow18': femalebelow18,
        'femaleabove18': femaleabove18,
        'socialgroup': socialGroup,
        'category': category,
        'idtype': idtype,
        'idname': idname,
        'disability': disability,
        'projectid': projectId,
        'partnerid': partnerId,
        'createdby': createdBy,
        'createddate': createdDate,
        'ipaddress': ipAddress,
        'cStatus': cStatus,
        'bstatus': bstatus,
      };
}

@HiveType(typeId: 25)
class CBOData extends HiveObject {
  @HiveField(0)
  final String cboid;

  @HiveField(1)
  final String partnerid;

  @HiveField(2)
  final String projectid;

  @HiveField(3)
  final String statecode;

  @HiveField(4)
  final String districtcode;

  @HiveField(5)
  final String blockcode;

  @HiveField(6)
  final String villagecode;

  @HiveField(7)
  final String cboname;

  @HiveField(8)
  final String cbotype;

  @HiveField(9)
  final String formationdate;

  @HiveField(10)
  final String noofmembers;

  @HiveField(11)
  final String noofmembersfemale;

  @HiveField(12)
  final String cbocontact;

  @HiveField(13)
  final String cboregno;

  @HiveField(14)
  final String noofmeeting;

  @HiveField(15)
  final String createdby;

  @HiveField(16)
  final String createddate;

  @HiveField(17)
  final String? updatedby;

  @HiveField(18)
  final String? updateddate;

  @HiveField(19)
  final String cstatus;

  @HiveField(20)
  final String ipaddress;

  CBOData({
    required this.cboid,
    required this.partnerid,
    required this.projectid,
    required this.statecode,
    required this.districtcode,
    required this.blockcode,
    required this.villagecode,
    required this.cboname,
    required this.cbotype,
    required this.formationdate,
    required this.noofmembers,
    required this.noofmembersfemale,
    required this.cbocontact,
    required this.cboregno,
    required this.noofmeeting,
    required this.createdby,
    required this.createddate,
    required this.updatedby,
    required this.updateddate,
    required this.cstatus,
    required this.ipaddress,
  });

  factory CBOData.fromMap(Map<String, dynamic> json) => CBOData(
        cboid: json['cboid'] ?? '',
        partnerid: json['partnerid'] ?? '',
        projectid: json['projectid'] ?? '',
        statecode: json['statecode'] ?? '',
        districtcode: json['districtcode'] ?? '',
        blockcode: json['blockcode'] ?? '',
        villagecode: json['villagecode'] ?? '',
        cboname: json['cboname'] ?? '',
        cbotype: json['cbotype'] ?? '',
        formationdate: json['formationdate'] ?? '',
        noofmembers: json['noofmembers'] ?? '',
        noofmembersfemale: json['noofmembersfemale'] ?? '',
        cbocontact: json['cbocontact'] ?? '',
        cboregno: json['cboregno'] ?? '',
        noofmeeting: json['noofmeeting'] ?? '',
        createdby: json['createdby'] ?? '',
        createddate: json['createddate'] ?? '',
        updatedby: json['updatedby'],
        updateddate: json['updateddate'],
        cstatus: json['cstatus'] ?? '',
        ipaddress: json['ipaddress'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'cboid': cboid,
        'partnerid': partnerid,
        'projectid': projectid,
        'statecode': statecode,
        'districtcode': districtcode,
        'blockcode': blockcode,
        'villagecode': villagecode,
        'cboname': cboname,
        'cbotype': cbotype,
        'formationdate': formationdate,
        'noofmembers': noofmembers,
        'noofmembersfemale': noofmembersfemale,
        'cbocontact': cbocontact,
        'cboregno': cboregno,
        'noofmeeting': noofmeeting,
        'createdby': createdby,
        'createddate': createddate,
        'updatedby': updatedby,
        'updateddate': updateddate,
        'cstatus': cstatus,
        'ipaddress': ipaddress,
      };
}
