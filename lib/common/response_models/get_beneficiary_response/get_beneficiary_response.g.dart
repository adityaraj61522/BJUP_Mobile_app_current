part of 'get_beneficiary_response.dart';

class GetBeneficeryResponseAdapter extends TypeAdapter<GetBeneficeryResponse> {
  @override
  final int typeId = 170;

  @override
  GetBeneficeryResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = Map.fromEntries(
      List.generate(
        numOfFields,
        (_) => MapEntry(reader.readByte(), reader.read()),
      ),
    );
    return GetBeneficeryResponse(
      responseCode: fields[0] as int,
      message: fields[1] as String,
      selectedVillages: (fields[2] as List).cast<VillagesList>(),
      beneficiaries: (fields[3] as List).cast<BeneficiaryData>(),
      cbo: (fields[4] as List).cast<CBOData>(),
      others: (fields[5] as List).cast<CBOData>(),
      institute: (fields[6] as List).cast<CBOData>(),
    );
  }

  @override
  void write(BinaryWriter writer, GetBeneficeryResponse obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.responseCode)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.selectedVillages)
      ..writeByte(3)
      ..write(obj.beneficiaries)
      ..writeByte(4)
      ..write(obj.cbo)
      ..writeByte(5)
      ..write(obj.others)
      ..writeByte(6)
      ..write(obj.institute);
  }
}

class SelectedVillagesDataAdapter extends TypeAdapter<SelectedVillagesData> {
  @override
  final int typeId = 23;

  @override
  SelectedVillagesData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = Map.fromEntries(
      List.generate(
        numOfFields,
        (_) => MapEntry(reader.readByte(), reader.read()),
      ),
    );
    return SelectedVillagesData(
      villageId: fields[0] as String,
      villageName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SelectedVillagesData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.villageId)
      ..writeByte(1)
      ..write(obj.villageName);
  }
}

class BeneficiaryDataAdapter extends TypeAdapter<BeneficiaryData> {
  @override
  final int typeId = 24;

  @override
  BeneficiaryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = Map.fromEntries(
      List.generate(
        numOfFields,
        (_) => MapEntry(reader.readByte(), reader.read()),
      ),
    );
    return BeneficiaryData(
      beneficiaryId: fields[0] as String,
      villageCode: fields[1] as String,
      panchayat: fields[2] as String,
      blockCode: fields[3] as String,
      districtCode: fields[4] as String,
      stateCode: fields[5] as String,
      hof: fields[6] as String,
      beneficiaryName: fields[7] as String?,
      guardian: fields[8] as String,
      sex: fields[9] as String,
      hhname: fields[10] as String?,
      hhgender: fields[11] as String?,
      age: fields[12] as String,
      malebelow18: fields[13] as String,
      maleabove18: fields[14] as String,
      femalebelow18: fields[15] as String,
      femaleabove18: fields[16] as String,
      socialGroup: fields[17] as String,
      category: fields[18] as String?,
      idtype: fields[19] as String?,
      idname: fields[20] as String?,
      disability: fields[21] as String,
      projectId: fields[22] as String,
      partnerId: fields[23] as String,
      createdBy: fields[24] as String,
      createdDate: fields[25] as String,
      ipAddress: fields[26] as String,
      cStatus: fields[27] as String,
      bstatus: fields[28] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BeneficiaryData obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.beneficiaryId)
      ..writeByte(1)
      ..write(obj.villageCode)
      ..writeByte(2)
      ..write(obj.panchayat)
      ..writeByte(3)
      ..write(obj.blockCode)
      ..writeByte(4)
      ..write(obj.districtCode)
      ..writeByte(5)
      ..write(obj.stateCode)
      ..writeByte(6)
      ..write(obj.hof)
      ..writeByte(7)
      ..write(obj.beneficiaryName)
      ..writeByte(8)
      ..write(obj.guardian)
      ..writeByte(9)
      ..write(obj.sex)
      ..writeByte(10)
      ..write(obj.hhname)
      ..writeByte(11)
      ..write(obj.hhgender)
      ..writeByte(12)
      ..write(obj.age)
      ..writeByte(13)
      ..write(obj.malebelow18)
      ..writeByte(14)
      ..write(obj.maleabove18)
      ..writeByte(15)
      ..write(obj.femalebelow18)
      ..writeByte(16)
      ..write(obj.femaleabove18)
      ..writeByte(17)
      ..write(obj.socialGroup)
      ..writeByte(18)
      ..write(obj.category)
      ..writeByte(19)
      ..write(obj.idtype)
      ..writeByte(20)
      ..write(obj.idname)
      ..writeByte(21)
      ..write(obj.disability)
      ..writeByte(22)
      ..write(obj.projectId)
      ..writeByte(23)
      ..write(obj.partnerId)
      ..writeByte(24)
      ..write(obj.createdBy)
      ..writeByte(25)
      ..write(obj.createdDate)
      ..writeByte(26)
      ..write(obj.ipAddress)
      ..writeByte(27)
      ..write(obj.cStatus)
      ..writeByte(28)
      ..write(obj.bstatus);
  }
}

class CBODataAdapter extends TypeAdapter<CBOData> {
  @override
  final int typeId = 25;

  @override
  CBOData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = Map.fromEntries(
      List.generate(
        numOfFields,
        (_) => MapEntry(reader.readByte(), reader.read()),
      ),
    );
    return CBOData(
      cboid: fields[0] as String,
      partnerid: fields[1] as String,
      projectid: fields[2] as String,
      statecode: fields[3] as String,
      districtcode: fields[4] as String,
      blockcode: fields[5] as String,
      villagecode: fields[6] as String,
      cboname: fields[7] as String,
      cbotype: fields[8] as String,
      formationdate: fields[9] as String,
      noofmembers: fields[10] as String,
      noofmembersfemale: fields[11] as String,
      cbocontact: fields[12] as String,
      cboregno: fields[13] as String,
      noofmeeting: fields[14] as String,
      createdby: fields[15] as String,
      createddate: fields[16] as String,
      updatedby: fields[17] as String?,
      updateddate: fields[18] as String?,
      cstatus: fields[19] as String,
      ipaddress: fields[20] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CBOData obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.cboid)
      ..writeByte(1)
      ..write(obj.partnerid)
      ..writeByte(2)
      ..write(obj.projectid)
      ..writeByte(3)
      ..write(obj.statecode)
      ..writeByte(4)
      ..write(obj.districtcode)
      ..writeByte(5)
      ..write(obj.blockcode)
      ..writeByte(6)
      ..write(obj.villagecode)
      ..writeByte(7)
      ..write(obj.cboname)
      ..writeByte(8)
      ..write(obj.cbotype)
      ..writeByte(9)
      ..write(obj.formationdate)
      ..writeByte(10)
      ..write(obj.noofmembers)
      ..writeByte(11)
      ..write(obj.noofmembersfemale)
      ..writeByte(12)
      ..write(obj.cbocontact)
      ..writeByte(13)
      ..write(obj.cboregno)
      ..writeByte(14)
      ..write(obj.noofmeeting)
      ..writeByte(15)
      ..write(obj.createdby)
      ..writeByte(16)
      ..write(obj.createddate)
      ..writeByte(17)
      ..write(obj.updatedby)
      ..writeByte(18)
      ..write(obj.updateddate)
      ..writeByte(19)
      ..write(obj.cstatus)
      ..writeByte(20)
      ..write(obj.ipaddress);
  }
}
