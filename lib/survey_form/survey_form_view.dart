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
    // final decodedResponse = jsonDecode(widget.apiResponse);
    // final List<dynamic> formQuestionsJson = decodedResponse['form_questions'];
    _questions = widget.formQuestions;
  }

  onSaveFormClicked() async {
    // Prepare the answer data here
    List<Map<String, dynamic>> savedSurveyQuestions =
        _questions.map((question) {
      return {
        "question_id": question.questionId,
        "question_type": question.questionTypeEnum
            .toName(), // Use the enum to get the API string
        "answer": _answers[question.questionId] ?? "",
        "answerId": (question.questionTypeEnum == QuestionType.checkboxField ||
                    question.questionTypeEnum ==
                        QuestionType.multiSelectField) &&
                _answers.containsKey(question.questionId)
            ? (_answers[question.questionId] as List).join(',')
            : "", // Adjust logic for answerId if needed for other types
      };
    }).toList();

    print(jsonEncode(savedSurveyQuestions));
    final formToSave = {
      'animator_id': widget.userId,
      'savedSurveyQuestions': savedSurveyQuestions.toString(),
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
    ;
  }

  Widget _buildQuestionWidget(FormQuestionData question, int questionIndex) {
    Widget questionWidget;
    switch (question.questionTypeEnum) {
      // Use questionTypeEnum here
      case QuestionType.textAreaField:
        questionWidget = TextFormField(
          decoration: InputDecoration(
            labelText: question.questionText,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _answers[question.questionId] = value,
          maxLines: null,
        );
      case QuestionType.textField:
        questionWidget = TextFormField(
          decoration: InputDecoration(
            labelText: question.questionText,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _answers[question.questionId] = value,
        );
      case QuestionType.numbericTextField:
        questionWidget = TextFormField(
          decoration: InputDecoration(
            labelText: question.questionText,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _answers[question.questionId] = value,
        );
      case QuestionType.dateField:
      case QuestionType.datePickerField:
        questionWidget = buildDateField(question);
      case QuestionType.mobileField:
        questionWidget = TextFormField(
          decoration: InputDecoration(labelText: question.questionText),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _answers[question.questionId] = value,
        );
      case QuestionType.checkboxField:
        questionWidget = _buildCheckboxField(question);
      case QuestionType.radioField:
        questionWidget = _buildRadioField(question);
      case QuestionType.multiSelectField:
        questionWidget = _buildMultiSelectField(question);
      case QuestionType.selectField:
        questionWidget = _buildSelectField(question);
      case QuestionType.fileUploadImage:
      case QuestionType.fileUploadAll:
        questionWidget = _buildFileUploadField(question); // Placeholder
      case QuestionType.mobileCamera:
        questionWidget = _buildCameraField(question); // Placeholder
      case QuestionType.gpsLocation:
        questionWidget = _buildGpsLocationField(question); // Placeholder
      case QuestionType.writingPad:
        questionWidget = _buildSignatureField(question); // Placeholder
      case QuestionType.readOnly:
        questionWidget = Text(question.questionText);
      case QuestionType.urlField:
        questionWidget = TextFormField(
          decoration: InputDecoration(labelText: question.questionText),
          keyboardType: TextInputType.url,
          onChanged: (value) => _answers[question.questionId] = value,
        );
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
            'Q${questionIndex + 1}. ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ), // Display the question number
          Expanded(child: questionWidget),
        ],
      ),
    );
  }

  Widget buildDateField(FormQuestionData question) {
    return DateTimeFormField(
      decoration: InputDecoration(
        labelText: question.questionText,
        border: OutlineInputBorder(),
      ),
      mode: DateTimeFieldPickerMode.date,
      dateFormat: DateFormat('yyyy-MM-dd'),
      firstDate: DateTime.now().add(const Duration(days: 10)),
      lastDate: DateTime.now().add(const Duration(days: 40)),
      initialPickerDateTime: DateTime.now().add(const Duration(days: 20)),
      onChanged: (DateTime? value) {
        _answers[question.questionId] = value;
      },
    );
  }

  Widget _buildCheckboxField(FormQuestionData question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(question.questionText),
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

  Widget _buildRadioField(FormQuestionData question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText),
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

  Widget _buildMultiSelectField(FormQuestionData question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: question.questionText),
          value: (_answers[question.questionId] as List<String>?)?.first,
          items: question.questionOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option.optionId,
              child: Text(option.optionText),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              if (newValue != null) {
                _answers[question.questionId] = [newValue];
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSelectField(FormQuestionData question) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: question.questionText,
        border: OutlineInputBorder(),
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
    );
  }

  Widget _buildFileUploadField(FormQuestionData question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText),
        ElevatedButton(
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
            _answers[question.questionId].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Selected file: ${_answers[question.questionId]}'),
          ),
      ],
    );
  }

  Widget _buildCameraField(FormQuestionData question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText),
        ElevatedButton(
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
            _answers[question.questionId].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 100,
              child: Image.file(File(_answers[question.questionId])),
            ),
          ),
      ],
    );
  }

  Widget _buildGpsLocationField(FormQuestionData question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText),
        ElevatedButton(
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
            _answers[question.questionId].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Current location: ${_answers[question.questionId]}'),
          ),
      ],
    );
  }

  Widget _buildSignatureField(FormQuestionData question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText),
        Signature(
          controller: _signatureController,
          width: 300,
          height: 200,
          // border: Border.all(),
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
              onPressed: () async {
                if (_signatureController.isNotEmpty) {
                  final Uint8List? signatureBytes =
                      await _signatureController.toPngBytes();
                  if (signatureBytes != null) {
                    setState(() {
                      _answers[question.questionId] =
                          base64Encode(signatureBytes);
                    });
                    // Optionally display the captured signature
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return AlertDialog(
                    //       content: Image.memory(signatureBytes),
                    //     );
                    //   },
                    // );
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
            _answers[question.questionId].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: const Text('Signature captured.'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(title: const Text('Survey')),
    //   body:
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ..._questions
              .asMap() // Convert the list to a map with index
              .entries
              .map((entry) => _buildQuestionWidget(
                  entry.value, entry.key)) // Pass both question and index
              .toList(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () => onSaveFormClicked(),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
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
