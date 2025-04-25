import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'attendence_record_model.g.dart'; // Run 'flutter pub run build_runner build'

@HiveType(typeId: 78) // Choose a unique typeId
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  int? attendenceIndex;

  @HiveField(1)
  String? inDateTime;

  @HiveField(2)
  String? outDateTime;

  @HiveField(3)
  double? gpsLatitude;

  @HiveField(4)
  double? gpsLongitude;

  @HiveField(5)
  String? inLocationName;

  @HiveField(10)
  String? outLocationName;

  @HiveField(6)
  String? locationType;

  @HiveField(7)
  String? attendenceType;

  @HiveField(8)
  Uint8List? picture;

  @HiveField(9)
  bool? punchedOut;

  AttendanceRecord({
    this.attendenceIndex,
    this.inDateTime,
    this.outDateTime,
    this.gpsLatitude,
    this.gpsLongitude,
    this.inLocationName,
    this.outLocationName,
    this.locationType,
    this.attendenceType,
    this.picture,
    this.punchedOut,
  });

  // Factory method to create AttendanceRecord from JSON-like data
  factory AttendanceRecord.fromMap(
      Map<String, dynamic> data, Uint8List? pictureBytes) {
    return AttendanceRecord(
      attendenceIndex: data['attendenceIndex'] as int?,
      inDateTime: data['inDateTime'] as String?,
      outDateTime: data['outDateTime'] as String?,
      gpsLatitude: (data['gps_latitude'] as num?)?.toDouble(),
      gpsLongitude: (data['gps_longitude'] as num?)?.toDouble(),
      inLocationName: data['inLocationName'] as String?,
      outLocationName: data['outLocationName'] as String?,
      locationType: data['locationType'] as String?,
      attendenceType: data['attendenceType'] as String?,
      picture: pictureBytes, // Assign the provided image bytes
      punchedOut: data['punchedOut'] as bool?,
    );
  }

  // Convert AttendanceRecord object to a Map (for potential later use)
  Map<String, dynamic> toMap() {
    return {
      'attendenceIndex': attendenceIndex,
      'inDateTime': inDateTime,
      'outDateTime': outDateTime,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'inLocationName': inLocationName,
      'outLocationName': outLocationName,
      'locationType': locationType,
      'attendenceType': attendenceType,
      'picture': picture,
      'punchedOut': punchedOut,
    };
  }
}
