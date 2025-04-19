part of 'get_village_list_response.dart';

class GetVillageListResponseAdapter
    extends TypeAdapter<GetVillageListResponse> {
  @override
  final int typeId = 222;

  @override
  GetVillageListResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GetVillageListResponse(
      responseCode: fields[0] as int,
      message: fields[1] as String,
      villages: (fields[2] as List).cast<VillagesList>(),
      interviewTypes: (fields[3] as List).cast<InterviewTypeList>(),
    );
  }

  @override
  void write(BinaryWriter writer, GetVillageListResponse obj) {
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

class VillagesListAdapter extends TypeAdapter<VillagesList> {
  @override
  final int typeId = 223;

  @override
  VillagesList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VillagesList(
      villageId: fields[0] as String,
      villageName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VillagesList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.villageId)
      ..writeByte(1)
      ..write(obj.villageName);
  }
}

class InterviewTypeListAdapter extends TypeAdapter<InterviewTypeList> {
  @override
  final int typeId = 70;

  @override
  InterviewTypeList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewTypeList(
      id: fields[0] as String,
      type: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewTypeList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type);
  }
}
