import 'package:bjup_application/common/response_models/attendence_record_model/attendence_record_model.dart';
import 'package:hive/hive.dart';

class AttendenceStorageService {
  final String _attendanceBoxName = 'attendance_data';

  Future<Box> _openAttendanceBox() async {
    if (!Hive.isBoxOpen(_attendanceBoxName)) {
      return await Hive.openBox(_attendanceBoxName);
    }
    return Hive.box(_attendanceBoxName);
  }

  Future<void> storeAttendanceData(AttendanceRecord data) async {
    final box = await _openAttendanceBox();
    try {
      await box.add(data);
      print('Attendance data stored in Hive: $data');
    } catch (e) {
      print('Error storing attendance data in Hive: $e');
      // Optionally, re-throw the exception or handle it as needed.
      rethrow;
    }
  }

  Future<List<AttendanceRecord>> getAllAttendanceData() async {
    final box = await _openAttendanceBox();
    return box.values.toList().cast<AttendanceRecord>();
  }

  Future<void> replaceAllAttendanceData(
      List<AttendanceRecord> newRecords) async {
    final box = await _openAttendanceBox();
    await box.clear(); // Clear the box first
    await box.addAll(newRecords); // Add all the new records
    print(
        'All attendance records replaced in Hive with ${newRecords.length} new records.');
  }

  Future<void> updateAttendanceData(
      int index, AttendanceRecord updatedRecord) async {
    final box = await _openAttendanceBox();

    if (index >= 0 && index < box.length) {
      await box.put(index, updatedRecord); // Use put with the index
      print(
          'Attendance record at index $index updated in Hive: ${updatedRecord.toMap()}');
    } else {
      throw HiveError('Attendance record with index $index not found.');
    }
  }

  Future<void> clearAttendanceData() async {
    final box = await _openAttendanceBox();
    await box.clear();
    print('Attendance data cleared from Hive.');
  }
}
