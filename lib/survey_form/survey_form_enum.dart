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
  unknown,
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
        return 'Text Area Field';
      case QuestionType.dateField:
        return 'Date Field';
      case QuestionType.gpsLocation:
        return 'Gps Location';
      case QuestionType.datePickerField:
        return 'Date Picker Field';
      case QuestionType.mobileField:
        return 'Mobile Field';
      case QuestionType.readOnly:
        return 'Read Only';
      case QuestionType.textField:
        return 'Text Field';
      case QuestionType.mobileCamera:
        return 'Mobile Camera';
      case QuestionType.numbericTextField:
        return 'Numberic Text Field';
      case QuestionType.multiSelectField:
        return 'Multi Select Field';
      case QuestionType.writingPad:
        return 'Writing Pad';
      case QuestionType.checkboxField:
        return 'Checkbox Field';
      case QuestionType.radioField:
        return 'Radio Field';
      case QuestionType.fileUploadImage:
        return 'File Upload Image';
      case QuestionType.fileUploadAll:
        return 'File Upload All';
      case QuestionType.selectField:
        return 'Select Field';
      case QuestionType.urlField:
        return 'URL Field';
      case QuestionType.unknown:
        return 'Unknown';
    }
  }

  String toApiString() {
    return toName().toLowerCase().replaceAll(' ', '');
  }
}
