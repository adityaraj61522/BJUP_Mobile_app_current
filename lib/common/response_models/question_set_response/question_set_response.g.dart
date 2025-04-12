// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_set_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionSetResponseAdapter extends TypeAdapter<QuestionSetResponse> {
  @override
  final int typeId = 91;

  @override
  QuestionSetResponse read(BinaryReader reader) {
    return QuestionSetResponse(
      responseCode: reader.read(),
      message: reader.read(),
      questionSet: reader.read(),
      reportType: reader.read(),
      language: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionSetResponse obj) {
    writer.write(obj.responseCode);
    writer.write(obj.message);
    writer.write(obj.questionSet);
    writer.write(obj.reportType);
    writer.write(obj.language);
  }
}

class QuestionSetAdapter extends TypeAdapter<QuestionSet> {
  @override
  final int typeId = 92;

  @override
  QuestionSet read(BinaryReader reader) {
    return QuestionSet(
      id: reader.read(),
      title: reader.read(),
      interviewTypeId: reader.read(),
      interviewType: reader.read(),
      reportType: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionSet obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.interviewTypeId);
    writer.write(obj.interviewType);
    writer.write(obj.reportType);
  }
}

class ReportTypeAdapter extends TypeAdapter<ReportType> {
  @override
  final int typeId = 93;

  @override
  ReportType read(BinaryReader reader) {
    return ReportType(
      id: reader.read(),
      type: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, ReportType obj) {
    writer.write(obj.id);
    writer.write(obj.type);
  }
}

class LanguageAdapter extends TypeAdapter<Language> {
  @override
  final int typeId = 94;

  @override
  Language read(BinaryReader reader) {
    return Language(
      key: reader.read(),
      language: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Language obj) {
    writer.write(obj.key);
    writer.write(obj.language);
  }
}
