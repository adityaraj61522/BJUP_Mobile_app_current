part of 'attendence_record_model.dart';

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 78; // Must match the typeId in your @HiveType annotation

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = Map.fromEntries(
      List.generate(
        numOfFields,
        (_) => MapEntry(reader.readByte(), reader.read()),
      ),
    );
    return AttendanceRecord(
      attendenceIndex: fields[0] as int?,
      inDateTime: fields[1] as String?,
      outDateTime: fields[2] as String?,
      gpsLatitude: fields[3] as double?,
      gpsLongitude: fields[4] as double?,
      inLocationName: fields[5] as String?,
      locationType: fields[6] as String?,
      attendenceType: fields[7] as String?,
      picture: fields[8] as Uint8List?,
      punchedOut: fields[9] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(10) // Number of fields in the object
      ..writeByte(0)
      ..write(obj.attendenceIndex)
      ..writeByte(1)
      ..write(obj.inDateTime)
      ..writeByte(2)
      ..write(obj.outDateTime)
      ..writeByte(3)
      ..write(obj.gpsLatitude)
      ..writeByte(4)
      ..write(obj.gpsLongitude)
      ..writeByte(5)
      ..write(obj.inLocationName)
      ..writeByte(6)
      ..write(obj.locationType)
      ..writeByte(7)
      ..write(obj.attendenceType)
      ..writeByte(8)
      ..write(obj.picture)
      ..writeByte(9)
      ..write(obj.punchedOut);
  }
}
