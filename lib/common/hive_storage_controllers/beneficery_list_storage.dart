import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:hive/hive.dart';

class BeneficiaryStorageService {
  static final Map<String, Box> _projectBoxes = {};

  Future<Box> _getProjectBox({required String projectId}) async {
    try {
      if (_projectBoxes.containsKey(projectId)) {
        return _projectBoxes[projectId]!;
      } else {
        final box = await Hive.openBox(projectId);
        _projectBoxes[projectId] = box;
        return box;
      }
    } catch (e) {
      throw HiveError('Failed to get project box $projectId: $e');
    }
  }

  Future<void> addBeneficiaryData({
    required List<BeneficiaryData> beneficiaryDataList,
    required String interviewId,
    required String villageId,
    required String projectId,
  }) async {
    final String boxKey = 'beneficiaryData_${interviewId}_$villageId';
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<BeneficiaryData> existingBeneficiaries =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<BeneficiaryData>() ??
              <BeneficiaryData>[];

      final Set<String> existingBeneficiaryIds =
          existingBeneficiaries.map((b) => b.beneficiaryId).toSet();

      final List<BeneficiaryData> newBeneficiariesToAdd = beneficiaryDataList
          .where((newBeneficiary) =>
              !existingBeneficiaryIds.contains(newBeneficiary.beneficiaryId))
          .toList();

      if (newBeneficiariesToAdd.isNotEmpty) {
        final updatedBeneficiaries = [
          ...existingBeneficiaries,
          ...newBeneficiariesToAdd
        ];
        await projectBox.put(boxKey, updatedBeneficiaries);
      }
    } on HiveError catch (e) {
      throw HiveError('Failed to add beneficiary data to $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while adding beneficiary data to $boxKey: $e');
    }
  }

  Future<List<BeneficiaryData>> getBeneficiaryData({
    required String interviewId,
    required String villageId,
    required String projectId,
  }) async {
    final String boxKey = 'beneficiaryData_${interviewId}_$villageId';
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<BeneficiaryData> beneficiaryData =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<BeneficiaryData>() ??
              <BeneficiaryData>[];
      return beneficiaryData;
    } on HiveError catch (e) {
      throw HiveError('Failed to get beneficiary data from $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while getting data from $boxKey: $e');
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
