import 'package:hive/hive.dart';

part 'get_question_set_response.g.dart';

@HiveType(typeId: 91)
class GetQuestionSetResponse {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<QuestionSetList> questionSet;

  @HiveField(3)
  final List<ReportTypeList> reportType;

  @HiveField(4)
  final List<LanguageList> language;

  GetQuestionSetResponse({
    required this.responseCode,
    required this.message,
    required this.questionSet,
    required this.reportType,
    required this.language,
  });

  factory GetQuestionSetResponse.fromMap(Map<String, dynamic> json) {
    return GetQuestionSetResponse(
      responseCode: json['response_code'],
      message: json['message'],
      questionSet: (json['data']['question_set'] as List)
          .map((item) => QuestionSetList.fromMap(item))
          .toList(),
      reportType: (json['data']['report_type'] as List)
          .map((item) => ReportTypeList.fromMap(item))
          .toList(),
      language: (json['data']['language'] as List)
          .map((item) => LanguageList.fromMap(item))
          .toList(),
    );
  }
}

@HiveType(typeId: 92)
class QuestionSetList {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String interviewTypeId;

  @HiveField(3)
  final String interviewType;

  @HiveField(4)
  final String reportType;

  QuestionSetList({
    required this.id,
    required this.title,
    required this.interviewTypeId,
    required this.interviewType,
    required this.reportType,
  });

  factory QuestionSetList.fromMap(Map<String, dynamic> json) {
    return QuestionSetList(
      id: json['question_set_id'],
      title: json['question_set_title'],
      interviewTypeId: json['interview_type_id'],
      interviewType: json['interview_type'],
      reportType: json['report_type'],
    );
  }
}

@HiveType(typeId: 93)
class ReportTypeList {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  ReportTypeList({required this.id, required this.type});

  factory ReportTypeList.fromMap(Map<String, dynamic> json) {
    return ReportTypeList(
      id: json['id'],
      type: json['type'],
    );
  }
}

@HiveType(typeId: 94)
class LanguageList {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final String language;

  LanguageList({required this.key, required this.language});

  factory LanguageList.fromMap(Map<String, dynamic> json) {
    return LanguageList(
      key: json['key'],
      language: json['language'],
    );
  }
}

Future<void> saveQuestionSetResponse(GetQuestionSetResponse response) async {
  var box =
      await Hive.openBox<GetQuestionSetResponse>('questionSetResponseBox');
  await box.put('response', response);
}

Future<GetQuestionSetResponse?> getQuestionSetResponse() async {
  var box =
      await Hive.openBox<GetQuestionSetResponse>('questionSetResponseBox');
  return box.get('response');
}
