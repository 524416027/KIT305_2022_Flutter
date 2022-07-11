class ActionDetail {
  String description;
  String actionTime;
  String actionType;
  int buttonCorrect; //-1: not applied, 0: false, 1: true

  ActionDetail(
      {required this.description,
      required this.actionTime,
      required this.actionType,
      required this.buttonCorrect});

  ActionDetail.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        actionTime = json['actionTime'],
        actionType = json['actionType'],
        buttonCorrect = json['buttonCorrect'];

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'actionTime': actionTime,
      'actionType': actionType,
      'buttonCorrect': buttonCorrect
    };
  }
}
