import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:hive/hive.dart';

class VillageStorageService {
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

  Future<void> addVillageData({
    required List<VillagesList> villageDataList,
    required String interviewId,
    required String projectId,
  }) async {
    final String boxKey = 'villageData_$interviewId';
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<VillagesList> existingVillages =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<VillagesList>() ??
              <VillagesList>[];

      final Set<String> existingVillageIds =
          existingVillages.map((v) => v.villageId).toSet();

      final List<VillagesList> newVillagesToAdd = villageDataList
          .where((newVillage) =>
              !existingVillageIds.contains(newVillage.villageId))
          .toList();

      if (newVillagesToAdd.isNotEmpty) {
        final updatedVillages = [...existingVillages, ...newVillagesToAdd];
        await projectBox.put(boxKey, updatedVillages);
      }
    } on HiveError catch (e) {
      throw HiveError('Failed to add village data to $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while adding village data to $boxKey: $e');
    }
  }

  // New function to get village data
  Future<List<VillagesList>> getVillageData({
    required String interviewId,
    required String projectId,
  }) async {
    final String boxKey = 'villageData_$interviewId';
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<VillagesList> villageData =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<VillagesList>() ??
              <VillagesList>[];
      return villageData;
    } on HiveError catch (e) {
      throw HiveError('Failed to get village data from $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while getting village data from $boxKey: $e');
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
