import 'package:hive/hive.dart';

part 'download_question_set_response.g.dart';

@HiveType(typeId: 22)
class SurveyModel extends HiveObject {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<FormQuestion> formQuestions;

  SurveyModel({
    required this.responseCode,
    required this.message,
    required this.formQuestions,
  });

  factory SurveyModel.fromMap(Map<String, dynamic> json) {
    return SurveyModel(
      responseCode: json['response_code'] ?? 0,
      message: json['message'] ?? '',
      formQuestions: (json['data']['form_questions'] as List?)
              ?.map((q) => FormQuestion.fromMap(q))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'message': message,
      'data': {
        'form_questions': formQuestions.map((q) => q.toJson()).toList(),
      },
    };
  }
}

@HiveType(typeId: 33)
class FormQuestion extends HiveObject {
  @HiveField(0)
  final String questionId;

  @HiveField(1)
  final String questionText;

  @HiveField(2)
  final String questionType;

  @HiveField(3)
  final String parentQuestion;

  @HiveField(4)
  final String parentQuestionOption;

  @HiveField(5)
  final bool mandatory;

  @HiveField(6)
  final List<QuestionOption> questionOptions;

  FormQuestion({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.parentQuestion,
    required this.parentQuestionOption,
    required this.mandatory,
    required this.questionOptions,
  });

  factory FormQuestion.fromMap(Map<String, dynamic> json) {
    return FormQuestion(
      questionId: json['question_id'] ?? '',
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? '',
      parentQuestion: json['parent_question'] ?? '0',
      parentQuestionOption: json['parent_question_option'] ?? '0',
      mandatory: json['mandatory'] == '1',
      questionOptions: (json['question_options'] as List?)
              ?.map((o) => QuestionOption.fromMap(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_text': questionText,
      'question_type': questionType,
      'parent_question': parentQuestion,
      'parent_question_option': parentQuestionOption,
      'mandatory': mandatory ? '1' : '0',
      'question_options': questionOptions.map((o) => o.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 44)
class QuestionOption extends HiveObject {
  @HiveField(0)
  final String optionId;

  @HiveField(1)
  final String optionText;

  QuestionOption({
    required this.optionId,
    required this.optionText,
  });

  factory QuestionOption.fromMap(Map<String, dynamic> json) {
    return QuestionOption(
      optionId: json['option_id'] ?? '',
      optionText: json['option_text']?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_id': optionId,
      'option_text': optionText,
    };
  }
}
