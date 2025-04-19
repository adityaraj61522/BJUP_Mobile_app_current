// import 'package:bjup_application/common/response_models/download_CBO_response/download_CBO_response.dart';
// import 'package:hive/hive.dart';

// class DownloadVillageDataStorage {
//   static final DownloadVillageDataStorage _instance =
//       DownloadVillageDataStorage._internal();
//   factory DownloadVillageDataStorage() => _instance;
//   DownloadVillageDataStorage._internal();

//   Box? _storageBox;
//   bool _isInitialized = false;

//   Future<void> init() async {
//     if (!_isInitialized) {
//       try {
//         if (!Hive.isAdapterRegistered(170)) {
//           Hive.registerAdapter(CBOBeneficiaryResponseAdapter());
//           Hive.registerAdapter(VillageAdapter());
//           Hive.registerAdapter(BeneficiaryAdapter());
//           Hive.registerAdapter(CBOAdapter());
//         }
//         _storageBox =
//             await Hive.openBox<CBOBeneficiaryResponse>('downloadedVillageData');
//         _isInitialized = true;
//       } catch (e) {
//         print('downloadedVillageData initialization error: $e');
//         rethrow;
//       }
//     }
//   }

//   // Store user session
//   Future<void> saveDownloadedVillageData({
//     required String interviewId,
//     required CBOBeneficiaryResponse downloadedVillageData,
//   }) async {
//     await init();
//     try {
//       await _storageBox?.put(interviewId, downloadedVillageData);
//     } catch (e) {
//       print('downloadedVillageData save error: $e');
//       rethrow;
//     }
//   }

//   // Get current user
//   Future<CBOBeneficiaryResponse?> getDownloadedVillageData(
//       {required String interviewId}) async {
//     try {
//       final downloadedVillageData = await _storageBox?.get(interviewId);
//       print(downloadedVillageData);
//       return downloadedVillageData as CBOBeneficiaryResponse;
//     } catch (e) {
//       print('downloadedVillageData read error: $e');
//       return null;
//     }
//   }
// }
