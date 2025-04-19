part of 'get_question_form_response.dart';

class GetQuestionFormResponseAdapter
    extends TypeAdapter<GetQuestionFormResponse> {
  @override
  final int typeId = 155;

  @override
  GetQuestionFormResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return GetQuestionFormResponse(
      responseCode: fields[0] as int,
      message: fields[1] as String,
      formQuestions: (fields[2] as List).cast<FormQuestionData>(),
      oldSurvey: fields[3] as List,
      questionSetId: fields[4] as String,
      reportTypeId: fields[5] as String,
      interviewTypeId: fields[6] as String,
      language: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GetQuestionFormResponse obj) {
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

class FormQuestionDataAdapter extends TypeAdapter<FormQuestionData> {
  @override
  final int typeId = 156;

  @override
  FormQuestionData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return FormQuestionData(
      questionId: fields[0] as String,
      questionText: fields[1] as String,
      questionType: fields[2] as String,
      parentQuestion: fields[3] as String,
      parentQuestionOption: fields[4] as String,
      mandatory: fields[5] as bool,
      questionOptions: (fields[6] as List).cast<QuestionDropdownOption>(),
      questionTypeEnum: fields[7] as QuestionType,
    );
  }

  @override
  void write(BinaryWriter writer, FormQuestionData obj) {
    writer
      ..writeByte(8) // Corrected: Now writing 8 fields
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
      ..write(obj.questionOptions)
      ..writeByte(7)
      ..write(obj.questionTypeEnum);
  }
}

class QuestionDropdownOptionAdapter
    extends TypeAdapter<QuestionDropdownOption> {
  @override
  final int typeId = 157;

  @override
  QuestionDropdownOption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return QuestionDropdownOption(
      optionId: fields[0] as String,
      optionText: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionDropdownOption obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.optionId)
      ..writeByte(1)
      ..write(obj.optionText);
  }
}
