part of 'download_village_data_response.dart';

class DownloadVillageDataResponseAdapter
    extends TypeAdapter<DownloadVillageDataResponse> {
  @override
  final int typeId = 222;

  @override
  DownloadVillageDataResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadVillageDataResponse(
      responseCode: fields[0] as int,
      message: fields[1] as String,
      villages: (fields[2] as List).cast<Village>(),
      interviewTypes: (fields[3] as List).cast<InterviewType>(),
    );
  }

  @override
  void write(BinaryWriter writer, DownloadVillageDataResponse obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.responseCode)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.villages)
      ..writeByte(3)
      ..write(obj.interviewTypes);
  }
}

class VillageResAdapter extends TypeAdapter<Village> {
  @override
  final int typeId = 223;

  @override
  Village read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Village(
      villageId: fields[0] as String,
      villageName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Village obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.villageId)
      ..writeByte(1)
      ..write(obj.villageName);
  }
}

class InterviewTypeAdapter extends TypeAdapter<InterviewType> {
  @override
  final int typeId = 70;

  @override
  InterviewType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewType(
      id: fields[0] as String,
      type: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewType obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type);
  }
}
