part of 'download_question_set_response.dart';

class SurveyModelAdapter extends TypeAdapter<DownloadedQuestionSetResponse> {
  @override
  final int typeId = 155;

  @override
  DownloadedQuestionSetResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return DownloadedQuestionSetResponse(
      responseCode: fields[0] as int,
      message: fields[1] as String,
      formQuestions: (fields[2] as List).cast<FormQuestion>(),
      oldSurvey: fields[3] as List,
      questionSetId: fields[4] as String,
      reportTypeId: fields[5] as String,
      interviewTypeId: fields[6] as String,
      language: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedQuestionSetResponse obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.responseCode)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.formQuestions)
      ..writeByte(3)
      ..write(obj.oldSurvey)
      ..writeByte(4)
      ..write(obj.questionSetId)
      ..writeByte(5)
      ..write(obj.reportTypeId)
      ..writeByte(6)
      ..write(obj.interviewTypeId)
      ..writeByte(7)
      ..write(obj.language);
  }
}

class FormQuestionAdapter extends TypeAdapter<FormQuestion> {
  @override
  final int typeId = 156;

  @override
  FormQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return FormQuestion(
      questionId: fields[0] as String,
      questionText: fields[1] as String,
      questionType: fields[2] as String,
      parentQuestion: fields[3] as String,
      parentQuestionOption: fields[4] as String,
      mandatory: fields[5] as bool,
      questionOptions: (fields[6] as List).cast<QuestionOption>(),
    );
  }

  @override
  void write(BinaryWriter writer, FormQuestion obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.questionType)
      ..writeByte(3)
      ..write(obj.parentQuestion)
      ..writeByte(4)
      ..write(obj.parentQuestionOption)
      ..writeByte(5)
      ..write(obj.mandatory)
      ..writeByte(6)
      ..write(obj.questionOptions);
  }
}

class QuestionOptionAdapter extends TypeAdapter<QuestionOption> {
  @override
  final int typeId = 157;

  @override
  QuestionOption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return QuestionOption(
      optionId: fields[0] as String,
      optionText: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionOption obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.optionId)
      ..writeByte(1)
      ..write(obj.optionText);
  }
}
