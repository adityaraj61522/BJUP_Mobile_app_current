import 'dart:io';
import 'dart:typed_data';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/survey_storage.dart';
import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:date_field/date_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:bjup_application/survey_form/survey_form_enum.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:uuid/uuid.dart';

class SurveyPage extends StatefulWidget {
  final List<FormQuestionData> formQuestions;
  final String beneficeryId;
  final String userId;
  final String questionSetId;
  final String projectId;
  final String questionSetName;

  const SurveyPage({
    super.key,
    required this.formQuestions,
    required this.beneficeryId,
    required this.userId,
    required this.questionSetId,
    required this.projectId,
    required this.questionSetName,
  });

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<FormQuestionData> _questions = [];
  final Map<String, dynamic> _answers = {};
  final Map<String, String?> _validationErrors = {};
  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final RxBool isLoading = false.obs;
  final RxBool loadingLocation = false.obs;
  final ApiService apiService = ApiService();
  final SurveyStorageService surveyStorageService = SurveyStorageService();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _questions = widget.formQuestions;
    _signatureController.addListener(_handleSignatureChange);
  }

  @override
  void dispose() {
    _signatureController.removeListener(_handleSignatureChange);
    _signatureController.dispose();
    super.dispose();
  }

  void _handleSignatureChange() {
    String? signatureQuestionId;
    for (var q in _questions) {
      if (q.questionTypeEnum == QuestionType.writingPad) {
        signatureQuestionId = q.questionId;
        break;
      }
    }

    if (signatureQuestionId != null) {
      if (_signatureController.isNotEmpty &&
          _answers.containsKey(signatureQuestionId)) {
        if (_validationErrors.containsKey(signatureQuestionId)) {
          setState(() {
            _validationErrors.remove(signatureQuestionId);
          });
        }
      } else if (_signatureController.isEmpty &&
          _answers.containsKey(signatureQuestionId)) {
        setState(() {
          _answers.remove(signatureQuestionId);
          if (signatureQuestionId != null) {
            _validateField(signatureQuestionId);
          }
        });
      }
    }
  }

  Future<String?> _saveFileLocally(String sourcePath, String fileType) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileExtension = sourcePath.split('.').last;
      final uniqueFilename = '${_uuid.v4()}.$fileExtension';
      final newPath = '${directory.path}/$uniqueFilename';
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(newPath);
      print('File saved locally at: $newPath');
      return newPath;
    } catch (e) {
      print("Error saving file locally: $e");
      Get.snackbar(
        "File Error",
        "Could not save $fileType locally.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return null;
    }
  }

  Future<String?> _saveSignatureLocally(Uint8List signatureBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final uniqueFilename = '${_uuid.v4()}.png';
      final filePath = '${directory.path}/$uniqueFilename';
      final File signatureFile = File(filePath);
      await signatureFile.writeAsBytes(signatureBytes);
      print('Signature saved locally at: $filePath');
      return filePath;
    } catch (e) {
      print("Error saving signature locally: $e");
      Get.snackbar(
        "File Error",
        "Could not save signature locally.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return null;
    }
  }

  bool _validateField(String questionId) {
    final question = _questions.firstWhere((q) => q.questionId == questionId);
    bool isValid = true;
    String? error;

    if (question.mandatory) {
      final answer = _answers[questionId];
      if (answer == null ||
          (answer is String && answer.trim().isEmpty) ||
          (answer is List && answer.isEmpty) ||
          (answer is Map && answer.isEmpty)) {
        isValid = false;
        error = 'This field is required';
      }
    }

    setState(() {
      if (!isValid) {
        _validationErrors[questionId] = error;
      } else {
        _validationErrors.remove(questionId);
      }
    });
    return isValid;
  }

  Future<void> onSaveFormClicked() async {
    setState(() {
      _validationErrors.clear();
    });

    bool isFormValid = true;
    for (final question in _questions) {
      if (!_validateField(question.questionId)) {
        isFormValid = false;
      }
    }

    if (!isFormValid) {
      Get.snackbar(
        "Validation Error",
        "Please fill all mandatory fields correctly.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      setState(() {});
      return;
    }

    isLoading.value = true;

    try {
      List<Map<String, dynamic>> savedSurveyQuestions = _questions
          .where(
              (question) => question.questionTypeEnum != QuestionType.readOnly)
          .map((question) {
        dynamic answerValue = _answers[question.questionId];
        String answerIdStr = "";

        // Handle multiple choice type questions
        if (question.questionTypeEnum == QuestionType.multiSelectField ||
            question.questionTypeEnum == QuestionType.checkboxField) {
          if (answerValue is List) {
            answerIdStr = answerValue.join(',');
            answerValue = ""; // Clear the answer field
          }
        }
        // Handle radio and select fields
        else if (question.questionTypeEnum == QuestionType.radioField ||
            question.questionTypeEnum == QuestionType.selectField) {
          if (answerValue != null) {
            answerIdStr = answerValue.toString();
            answerValue = ""; // Clear the answer field
          }
        }
        // Handle date fields
        else if (answerValue is DateTime) {
          answerValue = DateFormat('yyyy-MM-dd').format(answerValue);
        }

        return {
          "question_id": question.questionId,
          "question_type": question.questionTypeEnum.toName(),
          "answer": answerValue ?? "",
          "answerId": answerIdStr,
        };
      }).toList();

      print("Preparing to save: ${jsonEncode(savedSurveyQuestions)}");

      final formToSave = {
        'animator_id': widget.userId,
        'savedSurveyQuestions': jsonEncode(savedSurveyQuestions),
        'surveyId': "1",
        'questionSetId': widget.questionSetId,
        'beneficiaryId': widget.beneficeryId,
        'questionSetName': widget.questionSetName,
        'isSynced': false,
        'projectId': widget.projectId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await surveyStorageService.saveSurveyFormData(
          projectId: widget.projectId,
          questionSetId: widget.questionSetId,
          beneficiaryId: widget.beneficeryId,
          savedSurveyQuestions: formToSave);

      print("Survey Saved Locally successfully!");
      Get.snackbar(
        "Success",
        "Survey Saved Locally successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary1,
        colorText: AppColors.white,
      );
      Get.offAllNamed(AppRoutes.projectActionList,
          arguments: {"projectId": widget.projectId});
    } catch (error) {
      print("Error saving survey locally: $error");
      Get.snackbar(
        "Error",
        "Failed to save survey locally. $error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _getDisplayPath(String? fullPath) {
    if (fullPath == null || fullPath.isEmpty) return "No file selected";
    return "File selected";
  }

  Widget _wrapWithValidation(String questionId, Widget child) {
    final error = _validationErrors[questionId];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionWidget(FormQuestionData question, int questionIndex) {
    Widget questionWidget;
    final String? errorText = _validationErrors[question.questionId];
    final bool hasError = errorText != null;
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
    );
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.5),
    );

    final labelStyle = TextStyle(color: hasError ? Colors.red : null);
    final labelText =
        '${question.questionText}${question.mandatory ? '*' : ''}';

    switch (question.questionTypeEnum) {
      case QuestionType.textAreaField:
        questionWidget = TextFormField(
          initialValue: _answers[question.questionId] as String?,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: labelStyle,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
          ),
          onChanged: (value) {
            _answers[question.questionId] = value;
            _validateField(question.questionId);
          },
          maxLines: 3,
        );
        break;
      case QuestionType.numbericTextField:
      case QuestionType.mobileField:
        questionWidget = TextFormField(
          initialValue: _answers[question.questionId] as String?,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: labelStyle,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _answers[question.questionId] = value;
            _validateField(question.questionId);
          },
          validator: (value) {
            if (question.questionTypeEnum == QuestionType.mobileField &&
                value != null &&
                value.isNotEmpty) {
              if (!RegExp(r'^[6-9][0-9]*$').hasMatch(value)) {
                return 'Mobile number must start with 6, 7, 8, or 9 and contain only numbers';
              }
            }
            return null;
          },
        );
        break;
      case QuestionType.textField:
      case QuestionType.urlField:
        questionWidget = TextFormField(
          initialValue: _answers[question.questionId] as String?,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: labelStyle,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
          ),
          keyboardType:
              question.questionTypeEnum == QuestionType.numbericTextField
                  ? TextInputType.number
                  : question.questionTypeEnum == QuestionType.mobileField
                      ? TextInputType.phone
                      : question.questionTypeEnum == QuestionType.urlField
                          ? TextInputType.url
                          : TextInputType.text,
          onChanged: (value) {
            _answers[question.questionId] = value;
            _validateField(question.questionId);
          },
          validator: (value) {
            if (question.questionTypeEnum == QuestionType.urlField &&
                value != null &&
                value.isNotEmpty) {
              if (!Uri.parse(value).isAbsolute) {
                return 'Please enter a valid URL';
              }
            }
            return null;
          },
        );
        break;

      case QuestionType.dateField:
      case QuestionType.datePickerField:
        questionWidget = buildDateField(question, hasError, errorText,
            inputBorder, errorBorder, labelStyle);
        break;

      case QuestionType.radioField:
        questionWidget = _buildRadioField(question, hasError);
        break;

      case QuestionType.fileUploadImage:
      case QuestionType.fileUploadAll:
        questionWidget = _buildFileUploadField(question, hasError);
        break;

      case QuestionType.checkboxField:
        questionWidget = _buildCheckboxField(question, hasError);
        break;
      case QuestionType.multiSelectField:
        questionWidget = _buildMultiSelectField(question, hasError);
        break;
      case QuestionType.selectField:
        questionWidget = _buildSelectField(
            question, hasError, inputBorder, errorBorder, labelStyle);
        break;
      case QuestionType.mobileCamera:
        questionWidget = _buildCameraField(question, hasError);
        break;
      case QuestionType.gpsLocation:
        questionWidget = _buildGpsLocationField(question, hasError);
        break;
      case QuestionType.writingPad:
        questionWidget = _buildSignatureField(question, hasError);
        break;
      case QuestionType.readOnly:
        questionWidget = Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(question.questionText,
                style: TextStyle(color: Colors.grey[700])));
        break;
      case QuestionType.unknown:
        questionWidget =
            Text('Unknown question type: ${question.questionType}');
        break;
    }

    Widget finalWidget = (question.questionTypeEnum != QuestionType.readOnly)
        ? _wrapWithValidation(question.questionId, questionWidget)
        : questionWidget;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Q${questionIndex + 1}${question.mandatory ? '*' : ''}. ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: finalWidget),
        ],
      ),
    );
  }

  Widget buildDateField(
      FormQuestionData question,
      bool hasError,
      String? errorText,
      InputBorder border,
      InputBorder errorBorder,
      TextStyle labelStyle) {
    final labelText =
        '${question.questionText}${question.mandatory ? '*' : ''}';
    return DateTimeFormField(
      initialValue: _answers[question.questionId] as DateTime?,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
      mode: DateTimeFieldPickerMode.date,
      dateFormat: DateFormat('yyyy-MM-dd'),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(2100, 1, 1),
      onChanged: (DateTime? value) {
        setState(() {
          _answers[question.questionId] = value;
          _validateField(question.questionId);
        });
      },
    );
  }

  Widget _buildCheckboxField(FormQuestionData question, bool hasError) {
    if (!_answers.containsKey(question.questionId) ||
        !(_answers[question.questionId] is List)) {
      _answers[question.questionId] = <String>[];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}',
            style: TextStyle(color: hasError ? Colors.red : null)),
        ...question.questionOptions
            .map((option) => CheckboxListTile(
                  title: Text(option.optionText),
                  value: (_answers[question.questionId] as List?)
                          ?.contains(option.optionId) ??
                      false,
                  onChanged: (bool? value) {
                    setState(() {
                      final currentList =
                          _answers[question.questionId] as List<dynamic>;
                      if (value == true) {
                        if (!currentList.contains(option.optionId)) {
                          currentList.add(option.optionId);
                        }
                      } else {
                        currentList.remove(option.optionId);
                      }
                      _validateField(question.questionId);
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildRadioField(FormQuestionData question, bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}',
            style: TextStyle(color: hasError ? Colors.red : null)),
        ...question.questionOptions
            .map((option) => RadioListTile<String>(
                  title: Text(option.optionText),
                  value: option.optionId,
                  groupValue: _answers[question.questionId] as String?,
                  onChanged: (String? value) {
                    setState(() {
                      _answers[question.questionId] = value;
                      _validateField(question.questionId);
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildMultiSelectField(FormQuestionData question, bool hasError) {
    if (!_answers.containsKey(question.questionId) ||
        !(_answers[question.questionId] is List)) {
      _answers[question.questionId] = <String>[];
    }
    final List<dynamic> selectedOptions =
        _answers[question.questionId] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}',
            style: TextStyle(color: hasError ? Colors.red : null)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey,
              width: hasError ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          constraints: BoxConstraints(maxHeight: 200),
          child: ListView(
            shrinkWrap: true,
            children: question.questionOptions.map((option) {
              bool isSelected = selectedOptions.contains(option.optionId);
              return CheckboxListTile(
                title: Text(option.optionText),
                value: isSelected,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (!selectedOptions.contains(option.optionId)) {
                        selectedOptions.add(option.optionId);
                      }
                    } else {
                      selectedOptions.remove(option.optionId);
                    }
                    _validateField(question.questionId);
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectField(FormQuestionData question, bool hasError,
      InputBorder border, InputBorder errorBorder, TextStyle labelStyle) {
    final labelText =
        '${question.questionText}${question.mandatory ? '*' : ''}';
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
      value: _answers[question.questionId] as String?,
      items: question.questionOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option.optionId,
          child: Text(option.optionText),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _answers[question.questionId] = value;
          _validateField(question.questionId);
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildFileUploadField(FormQuestionData question, bool hasError) {
    final String? currentPath = _answers[question.questionId] as String?;
    final String displayPath = _getDisplayPath(currentPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}',
            style: TextStyle(color: hasError ? Colors.red : null)),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              style: ElevatedButton.styleFrom(
                side: hasError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : null,
                foregroundColor: hasError ? Colors.red : null,
              ),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type:
                      question.questionTypeEnum == QuestionType.fileUploadImage
                          ? FileType.image
                          : FileType.any,
                );

                if (result != null && result.files.isNotEmpty) {
                  final pickedFilePath = result.files.first.path;
                  if (pickedFilePath != null) {
                    final String? localPath =
                        await _saveFileLocally(pickedFilePath, "file");
                    if (localPath != null) {
                      setState(() {
                        _answers[question.questionId] = localPath;
                        _validateField(question.questionId);
                      });
                    }
                  } else {
                    print("File path is null (potentially web platform)");
                    Get.snackbar("Info",
                        "File path not available directly. Web handling might be needed.",
                        snackPosition: SnackPosition.BOTTOM);
                  }
                }
              },
              label: const Text('Pick File'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayPath,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraField(FormQuestionData question, bool hasError) {
    final String? currentPath = _answers[question.questionId] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}',
            style: TextStyle(color: hasError ? Colors.red : null)),
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          style: ElevatedButton.styleFrom(
            side: hasError
                ? const BorderSide(color: Colors.red, width: 1.5)
                : null,
            foregroundColor: hasError ? Colors.red : null,
          ),
          onPressed: () async {
            try {
              final XFile? image = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (image != null) {
                final String? localPath =
                    await _saveFileLocally(image.path, "image");
                if (localPath != null) {
                  setState(() {
                    _answers[question.questionId] = localPath;
                    _validateField(question.questionId);
                  });
                }
              }
            } catch (e) {
              print("Error picking/saving camera image: $e");
              Get.snackbar("Camera Error", "Could not capture or save image.",
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
          label: const Text('Take Photo'),
        ),
        if (currentPath != null && currentPath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: kIsWeb
                ? Image.network(currentPath,
                    height: 100,
                    errorBuilder: (c, o, s) => Text('Cannot display image'))
                : Image.file(File(currentPath),
                    height: 100,
                    errorBuilder: (c, o, s) => Text('Cannot display image')),
          ),
      ],
    );
  }

  Widget _buildGpsLocationField(FormQuestionData question, bool hasError) {
    final String? currentLocation = _answers[question.questionId] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}',
            style: TextStyle(color: hasError ? Colors.red : null)),
        ElevatedButton.icon(
          icon: const Icon(Icons.location_on),
          style: ElevatedButton.styleFrom(
            side: hasError
                ? const BorderSide(color: Colors.red, width: 1.5)
                : null,
            foregroundColor: hasError ? Colors.red : null,
          ),
          onPressed: () async {
            bool serviceEnabled;
            LocationPermission permission;

            serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              Get.snackbar("Location Error", "Location services are disabled.",
                  snackPosition: SnackPosition.BOTTOM);
              return;
            }

            permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied) {
                Get.snackbar(
                    "Permission Error", "Location permissions are denied.",
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
            }

            if (permission == LocationPermission.deniedForever) {
              Get.snackbar("Permission Error",
                  "Location permissions are permanently denied, we cannot request permissions.",
                  snackPosition: SnackPosition.BOTTOM);
              return;
            }

            try {
              loadingLocation.value = true;
              Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );
              setState(() {
                _answers[question.questionId] =
                    "${position.latitude}, ${position.longitude}";
                _validateField(question.questionId);
              });
              Get.snackbar(
                "Success",
                "Location captured.",
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
                backgroundColor: AppColors.primary1,
              );
            } catch (e) {
              print("Error getting location: $e");
              Get.snackbar("Location Error", "Error getting location: $e",
                  snackPosition: SnackPosition.BOTTOM);
            } finally {
              loadingLocation.value = false;
            }
          },
          label: const Text('Get Current Location'),
        ),
        if (loadingLocation.value)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary1),
            ),
          ),
        if (currentLocation != null && currentLocation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Location: $currentLocation',
                style: TextStyle(color: Colors.grey[600])),
          ),
      ],
    );
  }

  Widget _buildSignatureField(FormQuestionData question, bool hasError) {
    final String? currentPath = _answers[question.questionId] as String?;
    final bool isSignatureSaved = currentPath != null && currentPath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}',
            style: TextStyle(color: hasError ? Colors.red : null)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: hasError ? Colors.red : Colors.grey,
                width: hasError ? 1.5 : 1.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Signature(
            key: ValueKey(question.questionId),
            controller: _signatureController,
            height: 150,
            backgroundColor: Colors.grey[200]!,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                _signatureController.clear();
                if (_answers.containsKey(question.questionId)) {
                  setState(() {
                    _answers.remove(question.questionId);
                    _validateField(question.questionId);
                  });
                }
              },
              child: const Text('Clear'),
            ),
            ElevatedButton.icon(
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.save, size: 18),
              style: ElevatedButton.styleFrom(
                foregroundColor: isSignatureSaved ? Colors.green : null,
              ),
              label: const Text('Save Signature'),
              onPressed: () async {
                if (_signatureController.isNotEmpty) {
                  final Uint8List? signatureBytes =
                      await _signatureController.toPngBytes();
                  if (signatureBytes != null) {
                    final String? localPath =
                        await _saveSignatureLocally(signatureBytes);
                    if (localPath != null) {
                      setState(() {
                        _answers[question.questionId] = localPath;
                        _validateField(question.questionId);
                        Get.snackbar("Success", "Signature saved.",
                            snackPosition: SnackPosition.BOTTOM,
                            duration: Duration(seconds: 2));
                      });
                    }
                  } else {
                    Get.snackbar("Error", "Could not export signature.",
                        snackPosition: SnackPosition.BOTTOM);
                  }
                } else {
                  if (question.mandatory) {
                    setState(() {
                      _validationErrors[question.questionId] =
                          'Signature is required';
                    });
                  }
                  Get.snackbar(
                      "Info", "Please provide a signature before saving.",
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
            ),
          ],
        ),
        if (isSignatureSaved)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('Signature Saved.',
                    style: TextStyle(color: Colors.green[700])),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ..._questions
                          .asMap()
                          .entries
                          .map((entry) =>
                              _buildQuestionWidget(entry.value, entry.key))
                          .toList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                if (isLoading.value)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary1),
                      ),
                    ),
                  ),
              ],
            )),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: isLoading.value ? null : () => onSaveFormClicked(),
              icon: isLoading.value
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.save_alt, color: AppColors.white),
              label: Text(
                isLoading.value ? "Saving..." : "Save Survey",
                style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary1,
                  minimumSize: const Size(double.infinity, 50),
                  disabledBackgroundColor: AppColors.primary1.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
