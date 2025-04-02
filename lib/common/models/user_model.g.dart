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
      username: fields[1] as String,
      mobileNo: fields[2] as String?,
      email: fields[3] as String,
      animatorId: fields[4] as String,
      accessTypes: (fields[5] as List).cast<String>(),
      userTypeId: fields[6] as int,
      userTypeLabel: fields[7] as String,
      userAccess: fields[8] as UserAccess,
      projects: (fields[9] as List).map((e) => e as Project).toList(),
      office: fields[10] as Office,
      plan: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.mobileNo)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.animatorId)
      ..writeByte(5)
      ..write(obj.accessTypes)
      ..writeByte(6)
      ..write(obj.userTypeId)
      ..writeByte(7)
      ..write(obj.userTypeLabel)
      ..writeByte(8)
      ..write(obj.userAccess)
      ..writeByte(9)
      ..write(obj.projects)
      ..writeByte(10)
      ..write(obj.office)
      ..writeByte(11)
      ..write(obj.plan);
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
