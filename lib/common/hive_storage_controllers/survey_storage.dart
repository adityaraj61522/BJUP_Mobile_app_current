import 'package:hive/hive.dart';

class SurveyStorageService {
  static final Map<String, Box> _projectSurveyBoxes = {};

  Future<Box> _getProjectSurveyBox({required String projectId}) async {
    try {
      if (_projectSurveyBoxes.containsKey(projectId)) {
        return _projectSurveyBoxes[projectId]!;
      } else {
        final box = await Hive.openBox('survey_data_$projectId');
        _projectSurveyBoxes[projectId] = box;
        return box;
      }
    } catch (e) {
      throw HiveError('Failed to get project survey box $projectId: $e');
    }
  }

  Future<void> saveSurveyFormData({
    required String projectId,
    required String questionSetId,
    required String beneficiaryId,
    required Map<String, dynamic> savedSurveyQuestions,
  }) async {
    final String boxKey =
        'survey_form_data_qs_${questionSetId}_ben_${beneficiaryId}';
    try {
      final projectBox = await _getProjectSurveyBox(projectId: projectId);
      await projectBox.put(boxKey, savedSurveyQuestions);
      print(
          'Survey form data saved for Project: $projectId, QuestionSet: $questionSetId, Beneficiary: $beneficiaryId');
    } on HiveError catch (e) {
      throw HiveError('Failed to save survey form data to $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while saving survey form data to $boxKey: $e');
    }
  }

  Future<Map<String, dynamic>?> getSavedSurveyFormData({
    required String projectId,
    required String questionSetId,
    required String beneficiaryId,
  }) async {
    final String boxKey =
        'survey_form_data_qs_${questionSetId}_ben_${beneficiaryId}';
    try {
      final projectBox = await _getProjectSurveyBox(projectId: projectId);
      final Map<String, dynamic>? savedData =
          projectBox.get(boxKey) as Map<String, dynamic>?;
      return savedData;
    } on HiveError catch (e) {
      throw HiveError('Failed to get saved survey form data from $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while getting saved survey form data from $boxKey: $e');
    }
  }

  Future<List<Map<String, Map<String, dynamic>>>>
      getAllSavedSurveyDataForProject({
    required String projectId,
  }) async {
    try {
      final projectBox = await _getProjectSurveyBox(projectId: projectId);
      List<Map<String, Map<String, dynamic>>> allData = [];
      for (var key in projectBox.keys) {
        if (key is String && key.startsWith('survey_form_data_qs_')) {
          final dynamic rawData = projectBox.get(key);
          if (rawData is Map) {
            // Safely cast the Map to the desired type
            Map<String, dynamic> data = rawData.cast<String, dynamic>();
            if (data.isNotEmpty) {
              allData.add({key: data});
            }
          }
        }
      }
      return allData;
    } on HiveError catch (e) {
      throw HiveError(
          'Failed to get all saved survey data for project $projectId: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while getting all saved survey data for project $projectId: $e');
    }
  }

  // Function to update existing saved survey form data
  Future<void> updateSurveyFormData({
    required String projectId,
    required String questionSetId,
    required String beneficiaryId,
    required Map<String, dynamic> updatedSurveyQuestions,
  }) async {
    final String boxKey =
        'survey_form_data_qs_${questionSetId}_ben_$beneficiaryId';
    try {
      final projectBox = await _getProjectSurveyBox(projectId: projectId);
      if (projectBox.containsKey(boxKey)) {
        await projectBox.put(boxKey, updatedSurveyQuestions);
        print(
            'Survey form data updated for Project: $projectId, QuestionSet: $questionSetId, Beneficiary: $beneficiaryId');
      } else {
        print(
            'No existing survey form data found for Project: $projectId, QuestionSet: $questionSetId, Beneficiary: $beneficiaryId. Saving new data.');
        await projectBox.put(boxKey, updatedSurveyQuestions);
      }
    } on HiveError catch (e) {
      throw HiveError('Failed to update survey form data for $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while updating survey form data for $boxKey: $e');
    }
  }

  static Future<void> closeSurveyBox({required String projectId}) async {
    try {
      if (_projectSurveyBoxes.containsKey(projectId)) {
        await _projectSurveyBoxes[projectId]!.close();
        _projectSurveyBoxes.remove(projectId);
      }
    } catch (e) {
      throw HiveError('Failed to close survey box for project $projectId: $e');
    }
  }

  Future<void> closeAllSurveyBoxes() async {
    try {
      await Future.wait(_projectSurveyBoxes.values.map((box) => box.close()));
      _projectSurveyBoxes.clear();
    } catch (e) {
      throw HiveError('Failed to close all survey boxes: $e');
    }
  }
}
