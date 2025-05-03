// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/survey_storage.dart';
import 'package:bjup_application/common/immage_compressor/immage_compressor.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:bjup_application/survey_form/survey_form_enum.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class SyncSurveyController extends GetxController {
  final SessionManager sessionManager = SessionManager();
  final SurveyStorageService surveyStorageService = SurveyStorageService();
  final ApiService apiService = ApiService();

  // Using RxList<dynamic> to match the actual type that GetX provides
  final synkedSurveyData = [].obs;
  final notSynkedSurveyData = [].obs;

  final selectedSyncedSurveys = false.obs;

  String projectId = '';
  String projectTitle = '';
  String officeName = '';
  UserLoginResponse? userData;
  final selectedAnamitorId = ''.obs;
  final selectedOfficeId = ''.obs;
  final isLoading = false.obs;
  final syncProgress = 0.obs;
  final totalSurveysToSync = 0.obs;

  // Add a timeout duration for API calls
  final Duration _apiTimeout = Duration(seconds: 30);

  @override
  void onInit() async {
    super.onInit();
    try {
      final args = Get.arguments;
      if (args == null ||
          !args.containsKey('projectId') ||
          !args.containsKey('projectTitle')) {
        _handleError('Missing required arguments');
        return;
      }

      projectId = args['projectId'] ?? '';
      projectTitle = args['projectTitle'] ?? '';

      if (projectId.isEmpty) {
        _handleError('Project ID cannot be empty');
        return;
      }

      try {
        userData = await sessionManager.getUserData();
        officeName = userData?.office.officeTitle ?? 'Unknown Office';
        selectedOfficeId.value = userData?.office.id ?? '';
        selectedAnamitorId.value = userData?.userId ?? '';
      } catch (e) {
        print('Error getting user data: $e');
        // Continue without user data, handle gracefully
        officeName = 'Unknown Office';
      }

      await getSurveysToSync();
    } catch (e, stackTrace) {
      _handleError('Error during initialization', e, stackTrace);
    }
  }

  Future<void> getSurveysToSync() async {
    try {
      isLoading.value = true;

      if (projectId.isEmpty) {
        _handleError('Project ID is empty');
        isLoading.value = false;
        return;
      }

      final savedSurveys = await surveyStorageService
          .getAllSavedSurveyDataForProject(
        projectId: projectId,
      )
          .timeout(_apiTimeout, onTimeout: () {
        throw TimeoutException('Operation timed out while retrieving surveys');
      });

      synkedSurveyData.clear();
      notSynkedSurveyData.clear();

      if (savedSurveys.isNotEmpty) {
        List<Map<String, dynamic>> extractedSurveyData = [];
        for (var surveyMap in savedSurveys) {
          if (surveyMap != null) {
            surveyMap.forEach((hiveKey, surveyData) {
              if (surveyData != null && surveyData is Map<String, dynamic>) {
                extractedSurveyData.add(surveyData);
                print('Added survey data for $hiveKey');
              } else {
                print('Invalid survey data format for $hiveKey');
              }
            });
          }
        }

        if (extractedSurveyData.isNotEmpty) {
          try {
            synkedSurveyData.addAll(extractedSurveyData
                .where((e) => e != null && e['isSynced'] == true));
            notSynkedSurveyData.addAll(extractedSurveyData
                .where((e) => e != null && e['isSynced'] == false));

            totalSurveysToSync.value = notSynkedSurveyData.length;
            print(
                'Found ${synkedSurveyData.length} synced and ${notSynkedSurveyData.length} unsynced surveys');
          } catch (e, stackTrace) {
            print('Error filtering surveys: $e');
            print('Stack trace: $stackTrace');
          }
        } else {
          print('No valid survey data extracted.');
        }
      } else {
        print('No saved surveys found.');
      }
    } catch (e, stackTrace) {
      _handleError('Error retrieving saved surveys', e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onSyncSurveyClicked() async {
    if (notSynkedSurveyData.isEmpty) {
      Get.snackbar(
        "Info",
        "No surveys to sync",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary1,
        colorText: AppColors.white,
      );
      return;
    }

    if (isLoading.value) {
      Get.snackbar(
        "Info",
        "Sync operation is already in progress",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary1,
        colorText: AppColors.white,
      );
      return;
    }

    isLoading.value = true;
    int successCount = 0;
    int failedCount = 0;
    syncProgress.value = 0;
    totalSurveysToSync.value = notSynkedSurveyData.length;

    try {
      // Create a copy of the list to avoid modification issues during iteration
      final surveys = List<Map<String, dynamic>>.from(notSynkedSurveyData);

      for (int i = 0; i < surveys.length; i++) {
        final survey = surveys[i];
        print('Processing survey ${i + 1}/${surveys.length}');

        try {
          bool success = await submitSurvey(savedSurveyQuestions: survey);
          if (success) {
            await _updateSurveyStatus(survey);
            successCount++;
          } else {
            failedCount++;
          }
        } catch (e, stackTrace) {
          print('Error syncing survey: $e');
          print('Stack trace: $stackTrace');
          failedCount++;
        }

        // Update progress
        syncProgress.value = ((i + 1) / surveys.length * 100).round();
      }

      // Refresh lists after sync operations
      await getSurveysToSync();

      // Show final result
      _showSyncResultMessage(successCount, failedCount);
    } catch (e, stackTrace) {
      _handleError('Error during sync operation', e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateSurveyStatus(Map<String, dynamic> survey) async {
    try {
      await surveyStorageService.updateSurveyFormData(
        projectId: projectId,
        questionSetId: survey['questionSetId'] ?? '',
        beneficiaryId: survey['beneficiaryId'] ?? '',
        updatedSurveyQuestions: {
          ...survey,
          'isSynced': true,
        },
      );

      // Update local lists
      synkedSurveyData.add(survey);
      notSynkedSurveyData.remove(survey);
      print('Survey marked as synced successfully');
    } catch (e, stackTrace) {
      print('Error updating survey status: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update survey status: $e');
    }
  }

  void _showSyncResultMessage(int successCount, int failedCount) {
    if (successCount > 0 && failedCount == 0) {
      Get.snackbar(
        "Success",
        "$successCount ${successCount == 1 ? 'survey' : 'surveys'} synced successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary1,
        colorText: AppColors.white,
        duration: Duration(seconds: 3),
      );
    } else if (successCount > 0 && failedCount > 0) {
      Get.snackbar(
        "Partial Success",
        "$successCount synced, $failedCount failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
        duration: Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        "Failed",
        "All sync operations failed. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<bool> submitSurvey(
      {required Map<String, dynamic> savedSurveyQuestions}) async {
    if (savedSurveyQuestions.isEmpty) {
      print('Error: saved survey questions is empty');
      return false;
    }

    try {
      // Get the saved survey questions
      var surveyQuestionsData = savedSurveyQuestions['savedSurveyQuestions'];
      if (surveyQuestionsData == null) {
        print('Error: savedSurveyQuestions value is null');
        return false;
      }

      // Handle different data types for survey questions
      List<dynamic> questionsArray = [];

      // If it's already a List, use it directly
      if (surveyQuestionsData is List) {
        print('Survey questions is already a List');
        questionsArray = surveyQuestionsData;
      }
      // If it's a String, try to parse as JSON
      else if (surveyQuestionsData is String) {
        print('Parsing survey questions from String');
        try {
          questionsArray = jsonDecode(surveyQuestionsData);
          if (questionsArray is! List) {
            print('Error: Decoded JSON is not a List');
            return false;
          }
        } catch (e) {
          print('Error parsing survey questions JSON: $e');
          return false;
        }
      }
      // If it's a Map, wrap in a List
      else if (surveyQuestionsData is Map) {
        print('Survey questions is a Map, wrapping in List');
        questionsArray = [surveyQuestionsData];
      } else {
        print(
            'Error: Unexpected data type for survey questions: ${surveyQuestionsData.runtimeType}');
        return false;
      }

      // FormData to hold all the form fields including files
      var formData = FormData();

      // Create a new list to store questions without file uploads
      List<dynamic> filteredQuestionsArray = [];

      for (var question in questionsArray) {
        if (question is Map<String, dynamic> &&
            question.containsKey('question_type') &&
            question.containsKey('question_id')) {
          String questionType = question['question_type'] ?? '';
          String questionId = question['question_id']?.toString() ?? '';
          var answer = question['answer'];

          if (questionId.isEmpty) {
            continue;
          }

          // Handle file upload question types
          if (_isFileUploadType(questionType) &&
              answer != null &&
              answer != '') {
            String answerStr = answer is String ? answer : answer.toString();

            if (answerStr.isNotEmpty) {
              try {
                File originalFile = File(answerStr);
                String filePath = answerStr;
                bool fileExists = await originalFile.exists();

                if (!fileExists) {
                  final directory = await getApplicationDocumentsDirectory();
                  final possibleFilename = answerStr.split('/').last;
                  final alternativePath = '${directory.path}/$possibleFilename';
                  File alternativeFile = File(alternativePath);
                  if (await alternativeFile.exists()) {
                    filePath = alternativePath;
                    fileExists = true;
                  }
                }

                if (fileExists) {
                  String? compressedFilePath =
                      await ImageCompressor.compressImageFile(
                    filePath,
                    targetSizeKB: 1536,
                    minQuality: 60,
                  );

                  if (compressedFilePath != null) {
                    filePath = compressedFilePath;
                  }

                  String filename = filePath.split('/').last;
                  formData.files.add(
                    MapEntry(
                      "question_$questionId",
                      await MultipartFile.fromFile(filePath,
                          filename: filename),
                    ),
                  );

                  // Skip adding this question to filteredQuestionsArray
                  continue;
                }
              } catch (e) {
                print('Error processing file $answerStr: $e');
              }
            }
          }
          // If not a file upload question or if file processing failed, add to filtered array
          filteredQuestionsArray.add(question);
        }
      }

      // Use the filtered array for the rest of the process
      formData.fields.add(
          MapEntry('savedSurveyQuestions', jsonEncode(filteredQuestionsArray)));

      // Add required metadata fields from savedSurveyQuestions to formData
      // These fields should NOT be included in the savedSurveyQuestions JSON string
      _addMetadataField(formData, savedSurveyQuestions, 'surveyId');
      _addMetadataField(formData, savedSurveyQuestions, 'questionSetId');
      _addMetadataField(formData, savedSurveyQuestions, 'beneficiaryId');
      _addMetadataField(
          formData, savedSurveyQuestions, 'animator_id', userData?.userId);

      // Print debug information about the form data being sent
      print('FormData fields to be sent:');
      for (var field in formData.fields) {
        print('  Field: ${field.key}, Value length: ${field.value.length}');
      }

      print('FormData files to be sent:');
      for (var file in formData.files) {
        print('  Field: ${file.key}, Filename: ${file.value.filename}');
      }

      // Submit the survey with timeout
      var response = await apiService
          .post("/synchSurvey.php", formData)
          .timeout(_apiTimeout, onTimeout: () {
        throw TimeoutException('API request timed out');
      });

      // Check response
      if (response != null && response.statusCode == 200) {
        print('Survey submitted successfully: ${response.data}');
        return true;
      } else {
        print(
            'Failed to submit survey: ${response?.statusCode} - ${response?.data}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Error submitting survey: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

// Helper method to add metadata fields to form data
  void _addMetadataField(
      FormData formData, Map<String, dynamic> data, String fieldName,
      [String? defaultValue]) {
    String value = '';

    if (data.containsKey(fieldName) && data[fieldName] != null) {
      value = data[fieldName] is String
          ? data[fieldName]
          : data[fieldName].toString();
    } else if (defaultValue != null && defaultValue.isNotEmpty) {
      value = defaultValue;
    }

    if (value.isNotEmpty) {
      formData.fields.add(MapEntry(fieldName, value));
    }
  }

  bool _isFileUploadType(String questionType) {
    final type = questionType.toQuestionType();
    return type == QuestionType.mobileCamera ||
        type == QuestionType.fileUploadAll ||
        type == QuestionType.fileUploadImage ||
        type == QuestionType.writingPad;
  }

  void _handleError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      print('$message: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    } else {
      print(message);
    }

    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
      duration: Duration(seconds: 5),
    );
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
