import 'package:bjup_application/survey_form/survey_form_enum.dart';
import 'package:hive/hive.dart';

part 'get_question_form_response.g.dart';

@HiveType(typeId: 155)
class GetQuestionFormResponse extends HiveObject {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<FormQuestionData> formQuestions;

  @HiveField(3)
  final List<dynamic> oldSurvey;

  @HiveField(4)
  final String questionSetId;

  @HiveField(5)
  final String reportTypeId;

  @HiveField(6)
  final String interviewTypeId;

  @HiveField(7)
  final String language;

  GetQuestionFormResponse({
    required this.responseCode,
    required this.message,
    required this.formQuestions,
    required this.oldSurvey,
    required this.questionSetId,
    required this.reportTypeId,
    required this.interviewTypeId,
    required this.language,
  });

  factory GetQuestionFormResponse.fromMap(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return GetQuestionFormResponse(
      responseCode: json['response_code'] ?? 0,
      message: json['message'] ?? '',
      formQuestions: (data['form_questions'] as List?)
              ?.map((q) => FormQuestionData.fromMap(q))
              .toList() ??
          [],
      oldSurvey: data['old_survey'] ?? [],
      questionSetId: data['question_set_id'] ?? '',
      reportTypeId: data['report_type_id'] ?? '',
      interviewTypeId: data['interview_type_id'] ?? '',
      language: data['language'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'message': message,
      'data': {
        'form_questions': formQuestions.map((q) => q.toJson()).toList(),
        'old_survey': oldSurvey,
        'question_set_id': questionSetId,
        'report_type_id': reportTypeId,
        'interview_type_id': interviewTypeId,
        'language': language,
      },
    };
  }
}

@HiveType(typeId: 156)
class FormQuestionData extends HiveObject {
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
  final List<QuestionDropdownOption> questionOptions;

  @HiveField(7)
  final QuestionType questionTypeEnum;

  FormQuestionData({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.parentQuestion,
    required this.parentQuestionOption,
    required this.mandatory,
    required this.questionOptions,
    required this.questionTypeEnum,
  });

  factory FormQuestionData.fromMap(Map<String, dynamic> json) {
    return FormQuestionData(
        questionId: json['question_id'] ?? '',
        questionText: json['question_text'] ?? '',
        questionType: json['question_type'] ?? '',
        parentQuestion: json['parent_question'] ?? '0',
        parentQuestionOption: json['parent_question_option'] ?? '0',
        mandatory: json['mandatory'] == '1',
        questionOptions: (json['question_options'] as List?)
                ?.map((o) => QuestionDropdownOption.fromMap(o))
                .toList() ??
            [],
        questionTypeEnum: json['question_type'].toString().toQuestionType());
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
      'question_type_enum': questionTypeEnum.toName(),
    };
  }
}

@HiveType(typeId: 157)
class QuestionDropdownOption extends HiveObject {
  @HiveField(0)
  final String optionId;

  @HiveField(1)
  final String optionText;

  QuestionDropdownOption({
    required this.optionId,
    required this.optionText,
  });

  factory QuestionDropdownOption.fromMap(Map<String, dynamic> json) {
    return QuestionDropdownOption(
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
