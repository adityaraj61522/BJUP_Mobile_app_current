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
    await box.add(data);
    print('Attendance data stored in Hive: $data');
  }

  Future<List<AttendanceRecord>> getAllAttendanceData() async {
    final box = await _openAttendanceBox();
    return box.values.toList().cast<AttendanceRecord>();
  }

  Future<void> clearAttendanceData() async {
    final box = await _openAttendanceBox();
    await box.clear();
    print('Attendance data cleared from Hive.');
  }
}
