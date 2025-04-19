enum QuestionType {
  textAreaField,
  dateField,
  gpsLocation,
  datePickerField,
  mobileField,
  readOnly,
  textField,
  mobileCamera,
  numbericTextField,
  multiSelectField,
  writingPad,
  checkboxField,
  radioField,
  fileUploadImage,
  fileUploadAll,
  selectField,
  urlField,
  unknown, // Add a default case for robustness
}

extension QuestionTypeExtension on String {
  QuestionType toQuestionType() {
    switch (toLowerCase().replaceAll(' ', '')) {
      case 'textareafield':
        return QuestionType.textAreaField;
      case 'datefield':
        return QuestionType.dateField;
      case 'gpslocation':
        return QuestionType.gpsLocation;
      case 'datepickerfield':
        return QuestionType.datePickerField;
      case 'mobilefield':
        return QuestionType.mobileField;
      case 'readonly':
        return QuestionType.readOnly;
      case 'textfield':
        return QuestionType.textField;
      case 'mobilecamera':
        return QuestionType.mobileCamera;
      case 'numberictextfield':
        return QuestionType.numbericTextField;
      case 'multiselectfield':
        return QuestionType.multiSelectField;
      case 'writingpad':
        return QuestionType.writingPad;
      case 'checkboxfield':
        return QuestionType.checkboxField;
      case 'radiofield':
        return QuestionType.radioField;
      case 'fileuploadimage':
        return QuestionType.fileUploadImage;
      case 'fileuploadall':
        return QuestionType.fileUploadAll;
      case 'selectfield':
        return QuestionType.selectField;
      case 'urlfield':
        return QuestionType.urlField;
      default:
        return QuestionType.unknown;
    }
  }
}

extension QuestionTypeToNameExtension on QuestionType {
  String toName() {
    switch (this) {
      case QuestionType.textAreaField:
        return 'textAreaField';
      case QuestionType.dateField:
        return 'dateField';
      case QuestionType.gpsLocation:
        return 'gpsLocation';
      case QuestionType.datePickerField:
        return 'datePickerField';
      case QuestionType.mobileField:
        return 'mobileField';
      case QuestionType.readOnly:
        return 'readOnly';
      case QuestionType.textField:
        return 'textField';
      case QuestionType.mobileCamera:
        return 'mobileCamera';
      case QuestionType.numbericTextField:
        return 'numbericTextField';
      case QuestionType.multiSelectField:
        return 'multiSelectField';
      case QuestionType.writingPad:
        return 'writingPad';
      case QuestionType.checkboxField:
        return 'checkboxField';
      case QuestionType.radioField:
        return 'radioField';
      case QuestionType.fileUploadImage:
        return 'fileUploadImage';
      case QuestionType.fileUploadAll:
        return 'fileUploadAll';
      case QuestionType.selectField:
        return 'selectField';
      case QuestionType.urlField:
        return 'urlField';
      case QuestionType.unknown:
        return 'unknown';
    }
  }

  String toApiString() {
    return toName().toLowerCase().replaceAll(' ', '');
  }
}
