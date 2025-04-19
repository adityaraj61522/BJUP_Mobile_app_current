import 'package:hive/hive.dart';
import 'package:bjup_application/survey_form/survey_form_enum.dart'; // Import your enum

class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final int typeId = 158; // Choose a unique typeId (158 is just an example)

  @override
  QuestionType read(BinaryReader reader) {
    final index = reader.readInt();
    switch (index) {
      case 0:
        return QuestionType.textAreaField;
      case 1:
        return QuestionType.dateField;
      case 2:
        return QuestionType.gpsLocation;
      case 3:
        return QuestionType.datePickerField;
      case 4:
        return QuestionType.mobileField;
      case 5:
        return QuestionType.readOnly;
      case 6:
        return QuestionType.textField;
      case 7:
        return QuestionType.mobileCamera;
      case 8:
        return QuestionType.numbericTextField;
      case 9:
        return QuestionType.multiSelectField;
      case 10:
        return QuestionType.writingPad;
      case 11:
        return QuestionType.checkboxField;
      case 12:
        return QuestionType.radioField;
      case 13:
        return QuestionType.fileUploadImage;
      case 14:
        return QuestionType.fileUploadAll;
      case 15:
        return QuestionType.selectField;
      case 16:
        return QuestionType.urlField;
      case 17:
        return QuestionType.unknown;
      default:
        return QuestionType.unknown; // Or throw an error
    }
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    switch (obj) {
      case QuestionType.textAreaField:
        writer.writeInt(0);
        break;
      case QuestionType.dateField:
        writer.writeInt(1);
        break;
      case QuestionType.gpsLocation:
        writer.writeInt(2);
        break;
      case QuestionType.datePickerField:
        writer.writeInt(3);
        break;
      case QuestionType.mobileField:
        writer.writeInt(4);
        break;
      case QuestionType.readOnly:
        writer.writeInt(5);
        break;
      case QuestionType.textField:
        writer.writeInt(6);
        break;
      case QuestionType.mobileCamera:
        writer.writeInt(7);
        break;
      case QuestionType.numbericTextField:
        writer.writeInt(8);
        break;
      case QuestionType.multiSelectField:
        writer.writeInt(9);
        break;
      case QuestionType.writingPad:
        writer.writeInt(10);
        break;
      case QuestionType.checkboxField:
        writer.writeInt(11);
        break;
      case QuestionType.radioField:
        writer.writeInt(12);
        break;
      case QuestionType.fileUploadImage:
        writer.writeInt(13);
        break;
      case QuestionType.fileUploadAll:
        writer.writeInt(14);
        break;
      case QuestionType.selectField:
        writer.writeInt(15);
        break;
      case QuestionType.urlField:
        writer.writeInt(16);
        break;
      case QuestionType.unknown:
        writer.writeInt(17);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
