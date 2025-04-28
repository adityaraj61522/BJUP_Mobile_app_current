import 'dart:io';
import 'dart:typed_data';

import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/survey_storage.dart';
import 'package:bjup_application/common/response_models/get_question_form_response/get_question_form_response.dart';
import 'package:bjup_application/common/routes/routes.dart';
import 'package:date_field/date_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:bjup_application/survey_form/survey_form_enum.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

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
  Map<String, dynamic> _answers = {}; // To store the answers
  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final isLoading = false.obs;
  final ApiService apiService = ApiService();

  final SurveyStorageService surveyStorageService = SurveyStorageService();

  @override
  void initState() {
    super.initState();
    _questions = widget.formQuestions;
  }

  onSaveFormClicked() async {
    bool isValid = true;
    for (final question in _questions) {
      if (question.mandatory && !_answers.containsKey(question.questionId)) {
        isValid = false;
        Get.snackbar(
          "Validation Error",
          "Please answer all mandatory questions.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
        setState(() {}); // Trigger a rebuild to show red borders
        return;
      } else if (question.mandatory) {
        final answer = _answers[question.questionId];
        if (answer == null ||
            (answer is String && answer.trim().isEmpty) ||
            (answer is List && answer.isEmpty)) {
          isValid = false;
          Get.snackbar(
            "Validation Error",
            "Please answer all mandatory questions.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.red,
            colorText: AppColors.white,
          );
          setState(() {}); // Trigger a rebuild to show red borders
          return;
        }
      }
    }

    if (isValid) {
      List<Map<String, dynamic>> savedSurveyQuestions =
          _questions.map((question) {
        return {
          "question_id": question.questionId,
          "question_type": question.questionTypeEnum.toName(),
          "answer": _answers[question.questionId] ?? "",
          "answerId":
              (question.questionTypeEnum == QuestionType.checkboxField ||
                          question.questionTypeEnum ==
                              QuestionType.multiSelectField) &&
                      _answers.containsKey(question.questionId)
                  ? (_answers[question.questionId] as List).join(',')
                  : "",
        };
      }).toList();

      print(jsonEncode(savedSurveyQuestions));
      final formToSave = {
        'animator_id': widget.userId,
        'savedSurveyQuestions': jsonEncode(savedSurveyQuestions),
        'surveyId': "1",
        'questionSetId': widget.questionSetId,
        'beneficiaryId': widget.beneficeryId,
        'questionSetName': widget.questionSetName,
        'isSynced': false,
      };
      await surveyStorageService
          .saveSurveyFormData(
              projectId: widget.projectId,
              questionSetId: widget.questionSetId,
              beneficiaryId: widget.beneficeryId,
              savedSurveyQuestions: formToSave)
          .then((value) {
        print("Survey Saved Locally successfully!");
        Get.snackbar(
          "Success",
          "Survey Saved Locally successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.green,
          colorText: AppColors.white,
        );
        Get.toNamed(AppRoutes.projectActionList);
      }).catchError((error) {
        print("Error saving survey locally: $error");
        Get.snackbar(
          "Error",
          "Failed to save survey locally.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
      });
    }
  }

  bool _isAnswered(String questionId) => _answers.containsKey(questionId);

// Fix for TextFormField (text type) - Add error text when mandatory not answered
  Widget _buildQuestionWidget(FormQuestionData question, int questionIndex) {
    Widget questionWidget;
    final bool isMandatoryNotAnswered =
        question.mandatory && !_isAnswered(question.questionId);
    final border = isMandatoryNotAnswered
        ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.red))
        : const OutlineInputBorder();

    switch (question.questionTypeEnum) {
      case QuestionType.textAreaField:
        questionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: question.questionText,
                border: border,
              ),
              onChanged: (value) => _answers[question.questionId] = value,
              maxLines: null,
            ),
            if (isMandatoryNotAnswered)
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text('This field is required',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
        break;
      case QuestionType.textField:
        questionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: question.questionText,
                border: border,
              ),
              onChanged: (value) => _answers[question.questionId] = value,
            ),
            if (isMandatoryNotAnswered)
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text('This field is required',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
        break;
      case QuestionType.numbericTextField:
        questionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: question.questionText,
                border: border,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _answers[question.questionId] = value,
            ),
            if (isMandatoryNotAnswered)
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text('This field is required',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
        break;

      // Fix for DateField
      case QuestionType.dateField:
      case QuestionType.datePickerField:
        questionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDateField(question, isMandatoryNotAnswered),
            if (isMandatoryNotAnswered)
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text('This field is required',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
        break;

      case QuestionType.mobileField:
        questionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                  labelText: question.questionText, border: border),
              keyboardType: TextInputType.phone,
              onChanged: (value) => _answers[question.questionId] = value,
            ),
            if (isMandatoryNotAnswered)
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text('This field is required',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
        break;

      // Fix for radio field to not show warning by default
      case QuestionType.radioField:
        questionWidget = _buildRadioField(question, isMandatoryNotAnswered);
        break;

      // Fix for file upload field to always show warning when mandatory
      case QuestionType.fileUploadImage:
      case QuestionType.fileUploadAll:
        questionWidget =
            _buildFileUploadField(question, isMandatoryNotAnswered);
        break;

      // Other cases remain unchanged
      case QuestionType.checkboxField:
        questionWidget = _buildCheckboxField(question, isMandatoryNotAnswered);
        break;
      case QuestionType.multiSelectField:
        questionWidget =
            _buildMultiSelectField(question, isMandatoryNotAnswered);
        break;
      case QuestionType.selectField:
        questionWidget = _buildSelectField(question, isMandatoryNotAnswered);
        break;
      case QuestionType.mobileCamera:
        questionWidget = _buildCameraField(question, isMandatoryNotAnswered);
        break;
      case QuestionType.gpsLocation:
        questionWidget =
            _buildGpsLocationField(question, isMandatoryNotAnswered);
        break;
      case QuestionType.writingPad:
        questionWidget = _buildSignatureField(question, isMandatoryNotAnswered);
        break;
      case QuestionType.readOnly:
        questionWidget = Text(question.questionText);
        break;
      case QuestionType.urlField:
        questionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                  labelText: question.questionText, border: border),
              keyboardType: TextInputType.url,
              onChanged: (value) => _answers[question.questionId] = value,
            ),
            if (isMandatoryNotAnswered)
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text('This field is required',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
        break;
      case QuestionType.unknown:
        questionWidget =
            Text('Unknown question type: ${question.questionType}');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${questionIndex + 1}${question.mandatory ? '*' : ''}. ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Expanded(child: questionWidget),
        ],
      ),
    );
  }

  Widget buildDateField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return DateTimeFormField(
      decoration: InputDecoration(
        labelText: question.questionText,
        border: isMandatoryNotAnswered
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red))
            : const OutlineInputBorder(),
      ),
      mode: DateTimeFieldPickerMode.date,
      dateFormat: DateFormat('yyyy-MM-dd'),
      firstDate: DateTime(1900, 1, 1), // Set start date to 01-01-1900
      lastDate: DateTime(2100, 12, 31), // Set end date to 31-12-2100
      onChanged: (DateTime? value) {
        setState(() {
          _answers[question.questionId] = value;
        });
      },
      validator: (DateTime? value) {
        if (question.mandatory && value == null) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildCheckboxField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}'),
        if (isMandatoryNotAnswered)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('This field is required',
                style: TextStyle(color: Colors.red)),
          ),
        ...question.questionOptions
            .map((option) => CheckboxListTile(
                  title: Text(option.optionText),
                  value: _answers.containsKey(question.questionId) &&
                      (_answers[question.questionId] as List?)
                              ?.contains(option.optionId) ==
                          true,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _answers.putIfAbsent(
                            question.questionId, () => <String>[]);
                        (_answers[question.questionId] as List)
                            .add(option.optionId);
                      } else {
                        if (_answers.containsKey(question.questionId)) {
                          (_answers[question.questionId] as List)
                              .remove(option.optionId);
                          if ((_answers[question.questionId] as List).isEmpty) {
                            _answers.remove(question.questionId);
                          }
                        }
                      }
                    });
                  },
                ))
            .toList(),
      ],
    );
  }

// Fix for radio field to not show warning by default
  Widget _buildRadioField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}'),
        if (isMandatoryNotAnswered)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('This field is required',
                style: TextStyle(color: Colors.red)),
          ),
        ...question.questionOptions
            .map((option) => RadioListTile<String>(
                  title: Text(option.optionText),
                  value: option.optionId,
                  groupValue: _answers[question.questionId] as String?,
                  onChanged: (String? value) {
                    setState(() {
                      _answers[question.questionId] = value;
                    });
                  },
                ))
            .toList(),
      ],
    );
  }

  Widget _buildMultiSelectField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    // Initialize the selected options list if it doesn't exist
    if (!_answers.containsKey(question.questionId)) {
      _answers[question.questionId] = <String>[];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}'),
        if (isMandatoryNotAnswered)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('This field is required',
                style: TextStyle(color: Colors.red)),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isMandatoryNotAnswered ? Colors.red : Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...question.questionOptions.map((option) {
                bool isSelected = (_answers[question.questionId] as List)
                    .contains(option.optionId);
                return CheckboxListTile(
                  title: Text(option.optionText),
                  value: isSelected,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        // Add the option to the selected list
                        (_answers[question.questionId] as List<dynamic>)
                            .add(option.optionId);
                      } else {
                        // Remove the option from the selected list
                        (_answers[question.questionId] as List<dynamic>)
                            .remove(option.optionId);
                      }

                      // Remove the key if the list is empty
                      if ((_answers[question.questionId] as List).isEmpty) {
                        _answers.remove(question.questionId);
                      }
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
        // if (_answers.containsKey(question.questionId) &&
        //     (_answers[question.questionId] as List).isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 8.0),
        //     child: Text(
        //       'Selected: ${(_answers[question.questionId] as List).join(",")}',
        //       style: const TextStyle(fontSize: 12.0, color: Colors.grey),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildSelectField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: question.questionText,
        border: isMandatoryNotAnswered
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red))
            : const OutlineInputBorder(),
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
        });
      },
      validator: (value) {
        if (question.mandatory && value == null) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }

  Widget _buildFileUploadField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}'),
        if (isMandatoryNotAnswered)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('This field is required',
                style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: isMandatoryNotAnswered
                ? const BorderSide(color: Colors.red)
                : null,
          ),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: question.questionTypeEnum == QuestionType.fileUploadImage
                  ? FileType.image
                  : FileType.any,
            );

            if (result != null && result.files.isNotEmpty) {
              setState(() {
                _answers[question.questionId] = result.files.first.path;
              });
            }
          },
          child: const Text('Pick File'),
        ),
        if (_answers.containsKey(question.questionId) &&
            _answers[question.questionId]!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Selected file: ${_answers[question.questionId]}'),
          ),
      ],
    );
  }

  Widget _buildCameraField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}'),
        if (isMandatoryNotAnswered && !_isAnswered(question.questionId))
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('This field is required',
                style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: isMandatoryNotAnswered && !_isAnswered(question.questionId)
                ? const BorderSide(color: Colors.red)
                : null,
          ),
          onPressed: () async {
            final XFile? image =
                await _picker.pickImage(source: ImageSource.camera);
            if (image != null) {
              setState(() {
                _answers[question.questionId] = image.path;
              });
            }
          },
          child: const Text('Take Photo'),
        ),
        if (_answers.containsKey(question.questionId) &&
            _answers[question.questionId]!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 100,
              child: Image.file(File(_answers[question.questionId]!)),
            ),
          ),
      ],
    );
  }

  Widget _buildGpsLocationField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}'),
        if (isMandatoryNotAnswered && !_isAnswered(question.questionId))
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('This field is required',
                style: TextStyle(color: Colors.red)),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: isMandatoryNotAnswered && !_isAnswered(question.questionId)
                ? const BorderSide(color: Colors.red)
                : null,
          ),
          onPressed: () async {
            PermissionStatus permission = await Permission.location.request();
            if (permission.isGranted) {
              try {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                setState(() {
                  _answers[question.questionId] =
                      "${position.latitude}, ${position.longitude}";
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error getting location.')),
                );
              }
            } else if (permission.isDenied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location permission denied.')),
              );
            } else if (permission.isPermanentlyDenied) {
              openAppSettings();
            }
          },
          child: const Text('Get Current Location'),
        ),
        if (_answers.containsKey(question.questionId) &&
            _answers[question.questionId]!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Current location: ${_answers[question.questionId]}'),
          ),
      ],
    );
  }

  Widget _buildSignatureField(
      FormQuestionData question, bool isMandatoryNotAnswered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${question.questionText}${question.mandatory ? '*' : ''}'),
        if (isMandatoryNotAnswered && !_isAnswered(question.questionId))
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('This field is required',
                style: TextStyle(color: Colors.red)),
          ),
        Signature(
          controller: _signatureController,
          width: 300,
          height: 200,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() => _signatureController.clear());
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side:
                    isMandatoryNotAnswered && !_isAnswered(question.questionId)
                        ? const BorderSide(color: Colors.red)
                        : null,
              ),
              onPressed: () async {
                if (_signatureController.isNotEmpty) {
                  final Uint8List? signatureBytes =
                      await _signatureController.toPngBytes();
                  if (signatureBytes != null) {
                    setState(() {
                      _answers[question.questionId] =
                          base64Encode(signatureBytes);
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please provide a signature.')),
                  );
                }
              },
              child: const Text('Save Signature'),
            ),
          ],
        ),
        if (_answers.containsKey(question.questionId) &&
            _answers[question.questionId]!.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Signature captured.'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ..._questions
              .asMap()
              .entries
              .map((entry) => _buildQuestionWidget(entry.value, entry.key))
              .toList(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () => onSaveFormClicked(),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Save Survey",
                style: TextStyle(
                    color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
