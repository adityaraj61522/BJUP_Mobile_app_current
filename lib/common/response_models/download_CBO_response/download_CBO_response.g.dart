part of 'download_CBO_response.dart';

class DownloadCBODataResponseAdapter
    extends TypeAdapter<DownloadCBODataResponse> {
  @override
  final int typeId = 2222;

  @override
  DownloadCBODataResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadCBODataResponse(
      responseCode: fields[0] as int,
      message: fields[1] as String,
      selectedVillages: (fields[2] as List).cast<VillageResData>(),
      beneficiaries: (fields[3] as List).cast<CBO>(),
      cbos: (fields[4] as List).cast<CBO>(),
      others: (fields[5] as List).cast<CBO>(),
    );
  }

  @override
  void write(BinaryWriter writer, DownloadCBODataResponse obj) {
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
      ..write(obj.cbos)
      ..writeByte(5)
      ..write(obj.others);
  }
}

class VillageAdapter extends TypeAdapter<VillageResData> {
  @override
  final int typeId = 3333;

  @override
  VillageResData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VillageResData(
      villageId: fields[0] as String,
      villageName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VillageResData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.villageId)
      ..writeByte(1)
      ..write(obj.villageName);
  }
}

class CBOAdapter extends TypeAdapter<CBO> {
  @override
  final int typeId = 4444;

  @override
  CBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CBO(
      cboId: fields[0] as String,
      partnerId: fields[1] as String,
      projectId: fields[2] as String,
      stateCode: fields[3] as String,
      districtCode: fields[4] as String,
      blockCode: fields[5] as String,
      villageCode: fields[6] as String,
      cboName: fields[7] as String,
      createdBy: fields[8] as String,
      createdDate: fields[9] as String,
      updatedBy: fields[10] as String?,
      updatedDate: fields[11] as String?,
      status: fields[12] as String,
      ipAddress: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CBO obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.cboId)
      ..writeByte(1)
      ..write(obj.partnerId)
      ..writeByte(2)
      ..write(obj.projectId)
      ..writeByte(3)
      ..write(obj.stateCode)
      ..writeByte(4)
      ..write(obj.districtCode)
      ..writeByte(5)
      ..write(obj.blockCode)
      ..writeByte(6)
      ..write(obj.villageCode)
      ..writeByte(7)
      ..write(obj.cboName)
      ..writeByte(8)
      ..write(obj.createdBy)
      ..writeByte(9)
      ..write(obj.createdDate)
      ..writeByte(10)
      ..write(obj.updatedBy)
      ..writeByte(11)
      ..write(obj.updatedDate)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.ipAddress);
  }
}
