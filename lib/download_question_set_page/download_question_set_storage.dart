import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:bjup_application/common/response_models/get_question_set_response/get_question_set_response.dart';
import 'package:bjup_application/survey_form/survey_form_enum.g.dart';
import 'package:hive/hive.dart';

class DownloadQuestionSetStorage {
  static final DownloadQuestionSetStorage _instance =
      DownloadQuestionSetStorage._internal();
  factory DownloadQuestionSetStorage() => _instance;
  DownloadQuestionSetStorage._internal();

  Box? _storageBox;
  Box? _storageQuestionBox;
  bool _isInitialized = false;
  bool _isQuestionInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        if (!Hive.isAdapterRegistered(155)) {
          Hive.registerAdapter(GetQuestionFormResponseAdapter());
          Hive.registerAdapter(FormQuestionDataAdapter());
          Hive.registerAdapter(QuestionDropdownOptionAdapter());
          Hive.registerAdapter(QuestionTypeAdapter());
        }
        _storageBox = await Hive.openBox<GetQuestionFormResponse>(
            'downloadedQuestionSet');
        _isInitialized = true;
      } catch (e) {
        print('Session initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveDownloadedQuestionSet(
      {required GetQuestionFormResponse downloadedQuestionSet}) async {
    await init();
    try {
      if (_storageBox == null) {
        print('Storage box is not initialized');
        return;
      }
      // Check if the question set already exists
      await _storageBox?.add(downloadedQuestionSet);
    } catch (e) {
      print('downloadedQuestionSet save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<List<GetQuestionFormResponse>> getDownloadedQuestionSet() async {
    try {
      final boxData =
          await Hive.box<GetQuestionFormResponse>('downloadedQuestionSet');
      final questionSetData = boxData.values.toList();
      if (questionSetData.isEmpty) {
        return <GetQuestionFormResponse>[];
      }
      print(questionSetData);
      return questionSetData;
    } catch (e) {
      print('downloadedQuestionSet read error: $e');
      return <GetQuestionFormResponse>[];
    }
  }

  Future<void> initQuestionSet() async {
    if (!_isQuestionInitialized) {
      try {
        if (!Hive.isAdapterRegistered(91)) {
          Hive.registerAdapter(GetQuestionSetResponseAdapter());
          Hive.registerAdapter(QuestionSetListAdapter());
          Hive.registerAdapter(ReportTypeListAdapter());
          Hive.registerAdapter(LanguageListAdapter());
        }
        _storageQuestionBox =
            await Hive.openBox<QuestionSetList>('questionSetData');
        _isQuestionInitialized = true;
      } catch (e) {
        print('Session initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveQuestionSetData(
      {required QuestionSetList questionSetData}) async {
    await initQuestionSet();
    try {
      await _storageQuestionBox?.add(questionSetData);
    } catch (e) {
      print('questionSetData save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<List<QuestionSetList>> getQuestionSetData() async {
    try {
      final boxData = await Hive.box<QuestionSetList>('questionSetData');
      final questionSetData = boxData.values.toList();
      if (questionSetData.isEmpty) {
        return <QuestionSetList>[];
      }
      print(questionSetData);
      return questionSetData;
    } catch (e) {
      print('questionSetData read error: $e');
      return <QuestionSetList>[];
    }
  }
}
