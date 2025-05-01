import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:hive/hive.dart';

class CBOStorageService {
  static final Map<String, Box> _projectBoxes = {};

  Future<Box> _getProjectBox({required String projectId}) async {
    try {
      if (_projectBoxes.containsKey(projectId)) {
        return _projectBoxes[projectId]!;
      } else {
        final box = await Hive.openBox('cbo_$projectId');
        _projectBoxes[projectId] = box;
        return box;
      }
    } catch (e) {
      throw HiveError('Failed to get project box $projectId: $e');
    }
  }

  Future<void> addCBOData({
    required List<CBOData> cboDataList,
    required String interviewId,
    required String villageId,
    required String projectId,
  }) async {
    final String boxKey = 'cboData_${interviewId}_$villageId';
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<CBOData> existingCBOs =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<CBOData>() ??
              <CBOData>[];

      final Set<String> existingCBOIds =
          existingCBOs.map((b) => b.cboid).toSet();

      final List<CBOData> newCBOsToAdd = cboDataList
          .where((newCBO) => !existingCBOIds.contains(newCBO.cboid))
          .toList();

      if (newCBOsToAdd.isNotEmpty) {
        final updatedCBOs = [...existingCBOs, ...newCBOsToAdd];
        await projectBox.put(boxKey, updatedCBOs);
      }
    } catch (e) {
      throw HiveError('Failed to add CBO data to $boxKey: $e');
    }
  }

  Future<List<CBOData>> getCBOData({
    required String interviewId,
    required String villageId,
    required String projectId,
  }) async {
    final String boxKey = 'cboData_${interviewId}_$villageId';
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<CBOData> cboData =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<CBOData>() ??
              <CBOData>[];
      return cboData;
    } catch (e) {
      throw HiveError('Failed to get CBO data from $boxKey: $e');
    }
  }

  static Future<void> closeBox({required String projectId}) async {
    try {
      if (_projectBoxes.containsKey(projectId)) {
        await _projectBoxes[projectId]!.close();
        _projectBoxes.remove(projectId);
      }
    } catch (e) {
      throw HiveError('Failed to close box $projectId: $e');
    }
  }

  static Future<void> closeAllBoxes() async {
    try {
      await Future.wait(_projectBoxes.values.map((box) => box.close()));
      _projectBoxes.clear();
    } catch (e) {
      throw HiveError('Failed to close all boxes: $e');
    }
  }
}
