part of 'user_response.dart';

// Generated code - do not modify by hand

class UserLoginResponseAdapter extends TypeAdapter<UserLoginResponse> {
  @override
  final int typeId = 1;

  @override
  UserLoginResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLoginResponse(
      userId: fields[0] as String,
      username: fields[1] as String,
      mobileNo: fields[2] as String?,
      email: fields[3] as String,
      animatorId: fields[4] as String,
      accessTypes: (fields[5] as List).cast<String>(),
      userTypeId: fields[6] as int,
      userTypeLabel: fields[7] as String,
      userAccess: fields[8] as UserAccessData,
      projects: (fields[9] as List).map((e) => e as ProjectList).toList(),
      office: fields[10] as OfficeData,
      plan: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserLoginResponse obj) {
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

class UserAccessDataAdapter extends TypeAdapter<UserAccessData> {
  @override
  final int typeId = 2;

  @override
  UserAccessData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAccessData(
      observationReport: fields[0] as int,
      attendance: fields[1] as int,
      projectMonitoring: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserAccessData obj) {
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

class ProjectListAdapter extends TypeAdapter<ProjectList> {
  @override
  final int typeId = 3;

  @override
  ProjectList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectList(
      projectId: fields[0] as String,
      projectTitle: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.projectTitle);
  }
}

class OfficeDataAdapter extends TypeAdapter<OfficeData> {
  @override
  final int typeId = 4;

  @override
  OfficeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfficeData(
      id: fields[0] as String,
      officeTitle: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfficeData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.officeTitle);
  }
}
