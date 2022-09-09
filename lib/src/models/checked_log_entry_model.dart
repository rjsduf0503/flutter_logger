class CheckedLogEntryModel {
  late bool checked;
  late dynamic logEntry;

  CheckedLogEntryModel({this.checked = false, this.logEntry});
}

class CheckedAndExtendedLogEntryModel extends CheckedLogEntryModel {
  late bool extended;
  CheckedAndExtendedLogEntryModel({this.extended = true});
}
