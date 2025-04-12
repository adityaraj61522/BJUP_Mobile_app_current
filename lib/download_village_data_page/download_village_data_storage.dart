import 'package:bjup_application/common/response_models/download_CBO_response/download_CBO_response.dart';
import 'package:bjup_application/common/response_models/download_village_data_response/download_village_data_response.dart';
import 'package:hive/hive.dart';

class DownloadVillageDataStorage {
  static final DownloadVillageDataStorage _instance =
      DownloadVillageDataStorage._internal();
  factory DownloadVillageDataStorage() => _instance;
  DownloadVillageDataStorage._internal();

  Box? _storageBox;
  Box? _storageVillageBox;
  bool _isInitialized = false;
  bool _isVillageInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        if (!Hive.isAdapterRegistered(170)) {
          Hive.registerAdapter(CBOBeneficiaryResponseAdapter());
          Hive.registerAdapter(VillageAdapter());
          Hive.registerAdapter(BeneficiaryAdapter());
          Hive.registerAdapter(CBOAdapter());
        }
        _storageVillageBox =
            await Hive.openBox<CBOBeneficiaryResponse>('downloadedVillageData');
        _isInitialized = true;
      } catch (e) {
        print('downloadedVillageData initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveDownloadedVillageData({
    required String villageInterviewId,
    required CBOBeneficiaryResponse downloadedVillageData,
  }) async {
    await init();
    try {
      await _storageVillageBox?.put(villageInterviewId, downloadedVillageData);
    } catch (e) {
      print('downloadedVillageData save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<CBOBeneficiaryResponse?> getDownloadedVillageData(
      {required String interviewId}) async {
    await init();
    try {
      final downloadedVillageData = await _storageVillageBox?.get(interviewId);
      print(downloadedVillageData);
      return downloadedVillageData as CBOBeneficiaryResponse;
    } catch (e) {
      print('downloadedVillageData read error: $e');
      return null;
    }
  }

  Future<void> initVillageData() async {
    if (!_isVillageInitialized) {
      try {
        if (!Hive.isAdapterRegistered(222)) {
          Hive.registerAdapter(DownloadVillageDataResponseAdapter());
          Hive.registerAdapter(VillageResAdapter());
          Hive.registerAdapter(InterviewTypeAdapter());
        }
        _storageBox = await Hive.openBox<Village>('villageData');
        _isVillageInitialized = true;
      } catch (e) {
        print('villageData initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveVillageData({
    required Village villageData,
  }) async {
    await initVillageData();
    try {
      await _storageBox?.add(villageData);
    } catch (e) {
      print('villageData save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<List<Village>> getVillageData() async {
    try {
      final boxData = await Hive.box<Village>('villageData');
      final villageData = boxData.values.toList();
      if (villageData.isEmpty) {
        return <Village>[];
      }
      print(villageData);
      return villageData;
    } catch (e) {
      print('villageData read error: $e');
      return <Village>[];
    }
  }
}
