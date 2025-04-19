import 'package:bjup_application/common/response_models/get_beneficiary_response/get_beneficiary_response.dart';
import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
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
          Hive.registerAdapter(GetBeneficeryResponseAdapter());
          Hive.registerAdapter(SelectedVillagesDataAdapter());
          Hive.registerAdapter(BeneficiaryDataAdapter());
          Hive.registerAdapter(CBODataAdapter());
        }
        _storageVillageBox =
            await Hive.openBox<GetBeneficeryResponse>('downloadedVillageData');
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
    required GetBeneficeryResponse downloadedVillageData,
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
  Future<GetBeneficeryResponse?> getDownloadedVillageData(
      {required String interviewId}) async {
    await init();
    try {
      final downloadedVillageData = await _storageVillageBox?.get(interviewId);
      print(downloadedVillageData);
      return downloadedVillageData as GetBeneficeryResponse;
    } catch (e) {
      print('downloadedVillageData read error: $e');
      return null;
    }
  }

  Future<void> initVillageData() async {
    if (!_isVillageInitialized) {
      try {
        if (!Hive.isAdapterRegistered(222)) {
          Hive.registerAdapter(GetVillageListResponseAdapter());
          Hive.registerAdapter(VillagesListAdapter());
          Hive.registerAdapter(InterviewTypeListAdapter());
        }
        _storageBox = await Hive.openBox<VillagesList>('villageData');
        _isVillageInitialized = true;
      } catch (e) {
        print('villageData initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveVillageData({
    required VillagesList villageData,
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
  Future<List<VillagesList>> getVillageData() async {
    try {
      final boxData = await Hive.box<VillagesList>('villageData');
      final villageData = boxData.values.toList();
      if (villageData.isEmpty) {
        return <VillagesList>[];
      }
      print(villageData);
      return villageData;
    } catch (e) {
      print('villageData read error: $e');
      return <VillagesList>[];
    }
  }
}
