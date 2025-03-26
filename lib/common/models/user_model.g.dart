part of 'user_model.dart';

// Generated code - do not modify by hand

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      userId: fields[0] as String,
      animatorId: fields[1] as String,
      accessTypes: (fields[2] as List).cast<String>(),
      userTypeId: fields[3] as int,
      userTypeLabel: fields[4] as String,
      userAccess: fields[5] as Map<String, dynamic>,
      projects: (fields[6] as List).map((e) => e as Project).toList(),
      office: fields[7] as Map<String, dynamic>,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.animatorId)
      ..writeByte(2)
      ..write(obj.accessTypes)
      ..writeByte(3)
      ..write(obj.userTypeId)
      ..writeByte(4)
      ..write(obj.userTypeLabel)
      ..writeByte(5)
      ..write(obj.userAccess)
      ..writeByte(6)
      ..write(obj.projects)
      ..writeByte(7)
      ..write(obj.office);
  }
}

class UserAccessAdapter extends TypeAdapter<UserAccess> {
  @override
  final int typeId = 2;

  @override
  UserAccess read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAccess(
      observationReport: fields[0] as int,
      attendance: fields[1] as int,
      projectMonitoring: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserAccess obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.observationReport)
      ..writeByte(1)
      ..write(obj.attendance)
      ..writeByte(2)
      ..write(obj.projectMonitoring);
  }
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 3;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      projectId: fields[0] as String,
      projectTitle: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.projectTitle);
  }
}

class OfficeAdapter extends TypeAdapter<Office> {
  @override
  final int typeId = 4;

  @override
  Office read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Office(
      id: fields[0] as String,
      officeTitle: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Office obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.officeTitle);
  }
}
