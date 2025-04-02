part of 'download_question_set_response.dart';

class SurveyModelAdapter extends TypeAdapter<SurveyModel> {
  @override
  final int typeId = 22;

  @override
  SurveyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyModel(
      responseCode: fields[0] as int,
      message: fields[1] as String,
      formQuestions: (fields[2] as List).cast<FormQuestion>(),
    );
  }

  @override
  void write(BinaryWriter writer, SurveyModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.responseCode)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.formQuestions);
  }
}

class FormQuestionAdapter extends TypeAdapter<FormQuestion> {
  @override
  final int typeId = 33;

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
  final int typeId = 44;

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
