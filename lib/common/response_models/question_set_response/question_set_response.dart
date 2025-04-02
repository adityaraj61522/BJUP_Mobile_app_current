import 'package:hive/hive.dart';

part 'question_set_response.g.dart';

@HiveType(typeId: 0)
class QuestionSetResponse {
  @HiveField(0)
  final int responseCode;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final List<QuestionSet> questionSet;

  @HiveField(3)
  final List<ReportType> reportType;

  @HiveField(4)
  final List<Language> language;

  QuestionSetResponse({
    required this.responseCode,
    required this.message,
    required this.questionSet,
    required this.reportType,
    required this.language,
  });

  factory QuestionSetResponse.fromMap(Map<String, dynamic> json) {
    return QuestionSetResponse(
      responseCode: json['response_code'],
      message: json['message'],
      questionSet: (json['data']['question_set'] as List)
          .map((item) => QuestionSet.fromMap(item))
          .toList(),
      reportType: (json['data']['report_type'] as List)
          .map((item) => ReportType.fromMap(item))
          .toList(),
      language: (json['data']['language'] as List)
          .map((item) => Language.fromMap(item))
          .toList(),
    );
  }
}

@HiveType(typeId: 1)
class QuestionSet {
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

  QuestionSet({
    required this.id,
    required this.title,
    required this.interviewTypeId,
    required this.interviewType,
    required this.reportType,
  });

  factory QuestionSet.fromMap(Map<String, dynamic> json) {
    return QuestionSet(
      id: json['question_set_id'],
      title: json['question_set_title'],
      interviewTypeId: json['interview_type_id'],
      interviewType: json['interview_type'],
      reportType: json['report_type'],
    );
  }
}

@HiveType(typeId: 2)
class ReportType {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  ReportType({required this.id, required this.type});

  factory ReportType.fromMap(Map<String, dynamic> json) {
    return ReportType(
      id: json['id'],
      type: json['type'],
    );
  }
}

@HiveType(typeId: 3)
class Language {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final String language;

  Language({required this.key, required this.language});

  factory Language.fromMap(Map<String, dynamic> json) {
    return Language(
      key: json['key'],
      language: json['language'],
    );
  }
}

Future<void> saveQuestionSetResponse(QuestionSetResponse response) async {
  var box = await Hive.openBox<QuestionSetResponse>('questionSetResponseBox');
  await box.put('response', response);
}

Future<QuestionSetResponse?> getQuestionSetResponse() async {
  var box = await Hive.openBox<QuestionSetResponse>('questionSetResponseBox');
  return box.get('response');
}
