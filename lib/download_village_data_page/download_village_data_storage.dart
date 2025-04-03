import 'package:bjup_application/common/response_models/download_village_data_response/download_village_data_response.dart';
import 'package:hive/hive.dart';

class DownloadVillageDataStorage {
  static final DownloadVillageDataStorage _instance =
      DownloadVillageDataStorage._internal();
  factory DownloadVillageDataStorage() => _instance;
  DownloadVillageDataStorage._internal();

  Box? _storageBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        if (!Hive.isAdapterRegistered(22)) {
          Hive.registerAdapter(DownloadVillageDataResponseAdapter());
          Hive.registerAdapter(VillageAdapter());
          Hive.registerAdapter(InterviewTypeAdapter());
        }
        _storageBox = await Hive.openBox('downloadedVillageData');
        _isInitialized = true;
      } catch (e) {
        print('downloadedVillageData initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveDownloadedVillageData(
      {required DownloadVillageDataResponse downloadedVillageData}) async {
    await init();
    try {
      await _storageBox?.put('downloadedVillageData', downloadedVillageData);
    } catch (e) {
      print('downloadedVillageData save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<DownloadVillageDataResponse?> getDownloadedVillageData() async {
    try {
      final downloadedQuestionSet =
          await _storageBox?.get('downloadedVillageData');
      print(downloadedQuestionSet);
      return downloadedQuestionSet as DownloadVillageDataResponse;
    } catch (e) {
      print('downloadedVillageData read error: $e');
      return null;
    }
  }
}
