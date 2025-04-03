import 'package:bjup_application/common/response_models/download_CBO_response/download_CBO_response.dart';
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
        if (!Hive.isAdapterRegistered(2222)) {
          Hive.registerAdapter(DownloadCBODataResponseAdapter());
          Hive.registerAdapter(VillageAdapter());
          Hive.registerAdapter(CBOAdapter());
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
      {required DownloadCBODataResponse downloadedVillageData}) async {
    await init();
    try {
      await _storageBox?.put('downloadedVillageData', downloadedVillageData);
    } catch (e) {
      print('downloadedVillageData save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<DownloadCBODataResponse?> getDownloadedVillageData() async {
    try {
      final downloadedVillageData =
          await _storageBox?.get('downloadedVillageData');
      print(downloadedVillageData);
      return downloadedVillageData as DownloadCBODataResponse;
    } catch (e) {
      print('downloadedVillageData read error: $e');
      return null;
    }
  }
}
