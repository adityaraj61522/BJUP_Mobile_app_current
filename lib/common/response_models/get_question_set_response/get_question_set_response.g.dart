// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_question_set_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GetQuestionSetResponseAdapter
    extends TypeAdapter<GetQuestionSetResponse> {
  @override
  final int typeId = 91;

  @override
  GetQuestionSetResponse read(BinaryReader reader) {
    return GetQuestionSetResponse(
      responseCode: reader.read(),
      message: reader.read(),
      questionSet: reader.read(),
      reportType: reader.read(),
      language: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, GetQuestionSetResponse obj) {
    writer.write(obj.responseCode);
    writer.write(obj.message);
    writer.write(obj.questionSet);
    writer.write(obj.reportType);
    writer.write(obj.language);
  }
}

class QuestionSetListAdapter extends TypeAdapter<QuestionSetList> {
  @override
  final int typeId = 92;

  @override
  QuestionSetList read(BinaryReader reader) {
    return QuestionSetList(
      id: reader.read(),
      title: reader.read(),
      interviewTypeId: reader.read(),
      interviewType: reader.read(),
      reportType: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionSetList obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.interviewTypeId);
    writer.write(obj.interviewType);
    writer.write(obj.reportType);
  }
}

class ReportTypeListAdapter extends TypeAdapter<ReportTypeList> {
  @override
  final int typeId = 93;

  @override
  ReportTypeList read(BinaryReader reader) {
    return ReportTypeList(
      id: reader.read(),
      type: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, ReportTypeList obj) {
    writer.write(obj.id);
    writer.write(obj.type);
  }
}

class LanguageListAdapter extends TypeAdapter<LanguageList> {
  @override
  final int typeId = 94;

  @override
  LanguageList read(BinaryReader reader) {
    return LanguageList(
      key: reader.read(),
      language: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, LanguageList obj) {
    writer.write(obj.key);
    writer.write(obj.language);
  }
}
