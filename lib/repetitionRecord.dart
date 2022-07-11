import 'package:flutter/cupertino.dart';

import 'actionDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepetitionRecord {
  String id;

  String mode;
  int repeatTimes;
  String startTime;
  String endTime;
  int completion; //-1: not applied, 0: not completed, 1: completed
  List<ActionDetail>? actionDetail = [];

  RepetitionRecord(
      {required this.id,
      required this.mode,
      required this.repeatTimes,
      required this.startTime,
      required this.endTime,
      required this.completion,
      required this.actionDetail});

  RepetitionRecord.fromJson(Map<String, dynamic> json, String id)
      : id = id,
        mode = json['mode'],
        repeatTimes = json['repeatTimes'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        completion = json['completion'] {
    actionDetail = [];
    if (json['actionDetail'] != null) {
      (json['actionDetail']).forEach(
          (value) => {actionDetail!.add(ActionDetail.fromJson(value))});
    }
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'repeatTimes': repeatTimes,
        'startTime': startTime,
        'endTime': endTime,
        'completion': completion,
        'actionDetail': List<dynamic>.from(
            actionDetail!.map((value) => value.toJson()).toList())
      };
}

class RepetitionRecordModel extends ChangeNotifier {
  final List<RepetitionRecord> items = [];

  CollectionReference exerciseCollection =
      FirebaseFirestore.instance.collection("stroke");

  int totalCorrectButtons = 0;

  bool loading = false;

  RepetitionRecordModel() {
    //fetch();
  }

  Future fetch() async {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();
    totalCorrectButtons = 0;

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all movies
    var querySnapshot = await exerciseCollection.get();

    //iterate over the exercises and add them to the list
    querySnapshot.docs.forEach((doc) {
      //note not using the add() function, because we don't want to add them to the db
      var repetitionRecord = RepetitionRecord.fromJson(
          doc.data()! as Map<String, dynamic>, doc.id);
      items.add(repetitionRecord);

      repetitionRecord.actionDetail!.forEach((value) {
        if (value.buttonCorrect == 1) {
          totalCorrectButtons++;
        }
      });
    });

    //we're done, no longer loading
    loading = false;
    update();
  }

  int getCorrectButtonCount() {
    return totalCorrectButtons;
  }

  Future add(RepetitionRecord item) async {
    loading = true;
    update();

    await exerciseCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, RepetitionRecord item) async {
    loading = true;
    update();

    await exerciseCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }

  Future delete(String id) async {
    loading = true;
    update();

    await exerciseCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  // This call tells the widgets that are listening to this model to rebuild.
  void update() {
    notifyListeners();
  }

  RepetitionRecord? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((movie) => movie.id == id);
  }
}
