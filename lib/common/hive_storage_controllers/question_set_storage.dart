import 'package:bjup_application/common/response_models/get_question_set_response/get_question_set_response.dart';
import 'package:hive/hive.dart';

class QuestionSetStorageService {
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

  Future<void> addQuestionSetData({
    required List<QuestionSetList> questionSetDataList,
    required String projectId,
  }) async {
    final String boxKey = 'questionSets'; // Consistent box key
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<QuestionSetList> existingQuestionSets =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<QuestionSetList>() ??
              <QuestionSetList>[];

      final Set<String> existingQuestionSetIds =
          existingQuestionSets.map((qs) => qs.id).toSet();

      final List<QuestionSetList> newQuestionSetsToAdd = questionSetDataList
          .where((newQuestionSet) =>
              !existingQuestionSetIds.contains(newQuestionSet.id))
          .toList();

      if (newQuestionSetsToAdd.isNotEmpty) {
        final updatedQuestionSets = [
          ...existingQuestionSets,
          ...newQuestionSetsToAdd
        ];
        await projectBox.put(boxKey, updatedQuestionSets);
      }
    } on HiveError catch (e) {
      throw HiveError('Failed to add question set data to $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while adding question set data to $boxKey: $e');
    }
  }

  Future<List<QuestionSetList>> getQuestionSetData({
    required String projectId,
  }) async {
    final String boxKey = 'questionSets'; // Consistent box key
    try {
      final projectBox = await _getProjectBox(projectId: projectId);
      final List<QuestionSetList> questionSetData =
          (projectBox.get(boxKey) as List<dynamic>?)?.cast<QuestionSetList>() ??
              <QuestionSetList>[];
      return questionSetData;
    } on HiveError catch (e) {
      throw HiveError('Failed to get question set data from $boxKey: $e');
    } catch (e) {
      throw HiveError(
          'An unexpected error occurred while getting question set data from $boxKey: $e');
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
