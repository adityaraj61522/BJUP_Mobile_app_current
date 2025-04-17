import 'package:bjup_application/common/response_models/download_question_set_response/download_question_set_response.dart';
import 'package:bjup_application/common/response_models/question_set_response/question_set_response.dart';
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
          Hive.registerAdapter(SurveyModelAdapter());
          Hive.registerAdapter(FormQuestionAdapter());
          Hive.registerAdapter(QuestionOptionAdapter());
        }
        _storageBox = await Hive.openBox<DownloadedQuestionSetResponse>(
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
      {required DownloadedQuestionSetResponse downloadedQuestionSet}) async {
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
  Future<List<DownloadedQuestionSetResponse>> getDownloadedQuestionSet() async {
    try {
      final boxData = await Hive.box<DownloadedQuestionSetResponse>(
          'downloadedQuestionSet');
      final questionSetData = boxData.values.toList();
      if (questionSetData.isEmpty) {
        return <DownloadedQuestionSetResponse>[];
      }
      print(questionSetData);
      return questionSetData;
    } catch (e) {
      print('downloadedQuestionSet read error: $e');
      return <DownloadedQuestionSetResponse>[];
    }
  }

  Future<void> initQuestionSet() async {
    if (!_isQuestionInitialized) {
      try {
        if (!Hive.isAdapterRegistered(91)) {
          Hive.registerAdapter(QuestionSetResponseAdapter());
          Hive.registerAdapter(QuestionSetAdapter());
          Hive.registerAdapter(ReportTypeAdapter());
          Hive.registerAdapter(LanguageAdapter());
        }
        _storageQuestionBox =
            await Hive.openBox<QuestionSet>('questionSetData');
        _isQuestionInitialized = true;
      } catch (e) {
        print('Session initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveQuestionSetData(
      {required QuestionSet questionSetData}) async {
    await initQuestionSet();
    try {
      await _storageQuestionBox?.add(questionSetData);
    } catch (e) {
      print('questionSetData save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<List<QuestionSet>> getQuestionSetData() async {
    try {
      final boxData = await Hive.box<QuestionSet>('questionSetData');
      final questionSetData = boxData.values.toList();
      if (questionSetData.isEmpty) {
        return <QuestionSet>[];
      }
      print(questionSetData);
      return questionSetData;
    } catch (e) {
      print('questionSetData read error: $e');
      return <QuestionSet>[];
    }
  }
}
