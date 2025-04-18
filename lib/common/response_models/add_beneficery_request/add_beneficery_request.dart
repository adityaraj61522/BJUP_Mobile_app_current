import 'dart:convert';

class BeneficiaryRequest {
  String villagecode;
  String panchayat;
  String blockcode;
  String districtcode;
  String statecode;
  String hhname;
  String hhgender;
  String hof;
  String guardian;
  String sex;
  String age;
  String socialgroup;
  String disability;
  String category;
  String idname;
  String idtype;
  String projectid;
  String partnerid;

  BeneficiaryRequest({
    required this.villagecode,
    required this.panchayat,
    required this.blockcode,
    required this.districtcode,
    required this.statecode,
    required this.hhname,
    required this.hhgender,
    required this.hof,
    required this.guardian,
    required this.sex,
    required this.age,
    required this.socialgroup,
    required this.disability,
    required this.category,
    required this.idname,
    required this.idtype,
    required this.projectid,
    required this.partnerid,
  });

  // To convert the Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'villagecode': villagecode,
      'panchayat': panchayat,
      'blockcode': blockcode,
      'districtcode': districtcode,
      'statecode': statecode,
      'hhname': hhname,
      'hhgender': hhgender,
      'hof': hof,
      'guardian': guardian,
      'sex': sex,
      'age': age,
      'socialgroup': socialgroup,
      'disability': disability,
      'category': category,
      'idname': idname,
      'idtype': idtype,
      'projectid': projectid,
      'partnerid': partnerid,
    };
  }

  // To create a Dart object from JSON
  factory BeneficiaryRequest.fromJson(Map<String, dynamic> json) {
    return BeneficiaryRequest(
      villagecode: json['villagecode'],
      panchayat: json['panchayat'],
      blockcode: json['blockcode'],
      districtcode: json['districtcode'],
      statecode: json['statecode'],
      hhname: json['hhname'],
      hhgender: json['hhgender'],
      hof: json['hof'],
      guardian: json['guardian'],
      sex: json['sex'],
      age: json['age'],
      socialgroup: json['socialgroup'],
      disability: json['disability'],
      category: json['category'],
      idname: json['idname'],
      idtype: json['idtype'],
      projectid: json['projectid'],
      partnerid: json['partnerid'],
    );
  }

  // You can also provide a method to encode the object to a JSON string
  String toJsonString() {
    return json.encode(this.toJson());
  }

  // Method to create a BeneficiaryRequest from a JSON string
  factory BeneficiaryRequest.fromJsonString(String jsonString) {
    return BeneficiaryRequest.fromJson(json.decode(jsonString));
  }
}
