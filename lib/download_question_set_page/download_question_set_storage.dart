import 'dart:convert';
import 'package:bjup_application/common/response_models/download_question_set_response/download_question_set_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class DownloadQuestionSetStorage {
  static final DownloadQuestionSetStorage _instance =
      DownloadQuestionSetStorage._internal();
  factory DownloadQuestionSetStorage() => _instance;
  DownloadQuestionSetStorage._internal();

  Box? _storageBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        if (!Hive.isAdapterRegistered(22)) {
          Hive.registerAdapter(SurveyModelAdapter());
          Hive.registerAdapter(FormQuestionAdapter());
          Hive.registerAdapter(QuestionOptionAdapter());
        }
        _storageBox = await Hive.openBox('downloadedQuestionSet');
        _isInitialized = true;
      } catch (e) {
        print('Session initialization error: $e');
        rethrow;
      }
    }
  }

  // Store user session
  Future<void> saveDownloadedQuestionSet(
      {required SurveyModel downloadedQuestionSet}) async {
    await init();
    try {
      await _storageBox?.put('downloadedQuestionSet', downloadedQuestionSet);
    } catch (e) {
      print('downloadedQuestionSet save error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<SurveyModel?> getDownloadedQuestionSet() async {
    try {
      final downloadedQuestionSet =
          await _storageBox?.get('downloadedQuestionSet');
      print(downloadedQuestionSet);
      return downloadedQuestionSet as SurveyModel;
    } catch (e) {
      print('downloadedQuestionSet read error: $e');
      return null;
    }
  }
}
