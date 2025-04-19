import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:hive/hive.dart';

class QuestionFormStorageService {
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

  Future<void> addQuestionFormData({
    required List<FormQuestionData> questionFormDataList,
    required String questionSetId,
    required String projectId,
  }) async {
    final String boxKey = 'questionForms_$questionSetId'; // Consistent box key
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<FormQuestionData> existingQuestionForms =
          (projectBox.get(boxKey) as List<dynamic>?)
                  ?.cast<FormQuestionData>() ??
              <FormQuestionData>[];

      final Set<String> existingQuestionFormIds =
          existingQuestionForms.map((form) => form.questionId).toSet();

      final List<FormQuestionData> newQuestionFormsToAdd = questionFormDataList
          .where((newForm) =>
              !existingQuestionFormIds.contains(newForm.questionId))
          .toList();

      if (newQuestionFormsToAdd.isNotEmpty) {
        final updatedQuestionForms = [
          ...existingQuestionForms,
          ...newQuestionFormsToAdd
        ];
        await projectBox.put(boxKey, updatedQuestionForms);
      }
    } on HiveError catch (e) {
      throw HiveError('Failed to add question form data to $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while adding question form data to $boxKey: $e');
    }
  }

  Future<List<FormQuestionData>> getQuestionFormData({
    required String questionSetId,
    required String projectId,
  }) async {
    final String boxKey = 'questionForms_$questionSetId';
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<FormQuestionData> questionFormData =
          (projectBox.get(boxKey) as List<dynamic>?)
                  ?.cast<FormQuestionData>() ??
              <FormQuestionData>[];
      return questionFormData;
    } on HiveError catch (e) {
      throw HiveError('Failed to get question form data from $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while getting question form data from $boxKey: $e');
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
