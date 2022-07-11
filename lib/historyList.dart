import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:assignment_4/repetitionRecord.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repetitionExercise.dart';
import 'actionDetail.dart';

class HistoryList extends StatefulWidget {
  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  int filterIndex = -1; //-1: all, 0: in-completed, 1: completed
  List<String> filterText = ["All", "In-completed", "Completed"];

  Future<String> getImage(String id) async {
    var url =
        await FirebaseStorage.instance.ref("image/${id}.jpeg").getDownloadURL();

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RepetitionRecordModel>(builder: buildScaffold);
  }

  Scaffold buildScaffold(
      BuildContext context, RepetitionRecordModel repetitionRecordModel, _) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6, top: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back to Menu",
                      style: TextStyle(fontSize: 32),
                    ),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromHeight(64), primary: Colors.red),
                  ),
                )),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, top: 24),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filterIndex++;
                      if (filterIndex > 1) {
                        filterIndex = -1;
                      }
                    });
                  },
                  child: Text(
                    filterText[filterIndex + 1],
                    style: TextStyle(fontSize: 32),
                  ),
                  style:
                      ElevatedButton.styleFrom(fixedSize: Size.fromHeight(64)),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (_, index) {
              var repetitionRecord = repetitionRecordModel.items[index];
              bool visible = false;

              if (filterIndex == -1) {
                visible = true;
              } else {
                visible = repetitionRecord.completion == filterIndex;
              }

              return Visibility(
                visible: visible,
                child: ListTile(
                  leading: SizedBox(
                    height: 128,
                    width: 128,
                    child: FutureBuilder(
                        future: getImage(repetitionRecord.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> image) {
                          if (image.hasData) {
                            return Image.network(image.data.toString());
                          } else {
                            return new Container();
                          }
                        }),
                  ),
                  title: Text(
                    "Mode: ${repetitionRecord.mode}",
                    style: TextStyle(fontSize: 24),
                  ),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 16),
                          child: Text(
                            "Repeat Times: ${repetitionRecord.repeatTimes}",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 32, top: 8, bottom: 32),
                              child: Text(
                                "Start Time: ${repetitionRecord.startTime}",
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 32, bottom: 32),
                              child: Text(
                                "End Time: ${repetitionRecord.endTime}",
                                style: TextStyle(fontSize: 24),
                              ),
                            )
                          ],
                        )
                      ]),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ActionDetail(
                          id: repetitionRecordModel.items[index].id);
                    }));
                  },
                  tileColor: index % 2 == 0 ? Colors.white : Colors.black12,
                ),
              );
            },
            itemCount: repetitionRecordModel.items.length,
          ),
        ),
        Row(
          children: [
            Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    String shareText = "";

                    repetitionRecordModel.items.forEach((value) {
                      String completion = "";

                      if (value.completion != -1) {
                        if (value.completion == 0) {
                          completion = "not completed";
                        } else {
                          completion = "completed";
                        }
                      } else {
                        completion = "not applied";
                        ;
                      }

                      shareText +=
                          "${value.mode} mode is started at ${value.startTime} and end at ${value.endTime}, the completion of the exercise is ${completion}, total of ${value.repeatTimes} repetition times performed.\n";
                    });
                    Share.share(shareText);
                  },
                  child: const Text(
                    "Share all Records",
                    style: TextStyle(fontSize: 32),
                  ),
                  style:
                      ElevatedButton.styleFrom(fixedSize: Size.fromHeight(64)),
                )),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    "Total ${Provider.of<RepetitionRecordModel>(context, listen: false).getCorrectButtonCount()} buttons been correctly pressed.",
                    style: TextStyle(fontSize: 24),
                  ),
                ))
          ],
        )
      ],
    )));
  }
}

class ActionDetail extends StatefulWidget {
  const ActionDetail({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<ActionDetail> createState() => _ActionDetailState();
}

class _ActionDetailState extends State<ActionDetail> {
  @override
  Widget build(BuildContext context) {
    var repetitionRecord =
        Provider.of<RepetitionRecordModel>(context, listen: false)
            .get(widget.id);

    var actionDetails = repetitionRecord!.actionDetail;
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back to History list",
                      style: TextStyle(fontSize: 32),
                    ),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromHeight(64), primary: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: ((_, index) {
              var actionDetail = actionDetails![index];
              String correctText = "";
              Color correctColor = Colors.black;
              if (actionDetail.buttonCorrect != -1) {
                correctText =
                    actionDetail.buttonCorrect == 0 ? "Wrong" : "Correct";
                correctColor =
                    actionDetail.buttonCorrect == 0 ? Colors.red : Colors.green;
              }
              return ListTile(
                title: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      "${actionDetail.description} ",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      correctText,
                      style: TextStyle(fontSize: 24, color: correctColor),
                    ),
                  )
                ]),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 32, top: 8, bottom: 16),
                  child: Text("Time: ${actionDetail.actionTime}",
                      style: TextStyle(fontSize: 24)),
                ),
                tileColor: index % 2 == 0 ? Colors.white : Colors.black12,
              );
            }),
            itemCount: actionDetails!.length,
          )),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: Text("Are you sure to delete this record?"),
                          content: Text(
                              "The record deleted will unable to restore."),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("Yes"),
                              onPressed: () async {
                                await Provider.of<RepetitionRecordModel>(
                                        context,
                                        listen: false)
                                    .delete(repetitionRecord.id);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text("No"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                        barrierDismissible: false,
                      );
                    },
                    child: Text(
                      "Delete Record",
                      style: TextStyle(fontSize: 32),
                    ),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromHeight(64), primary: Colors.red),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ElevatedButton(
                    onPressed: () {
                      String shareText = "";
                      String buttonCorrect = "";

                      actionDetails.forEach((value) {
                        if (value.buttonCorrect != -1) {
                          if (value.buttonCorrect == 0) {
                            buttonCorrect = ", the button pressed wrong.";
                          } else {
                            buttonCorrect = ", the button pressed correctly.";
                          }
                        } else {
                          buttonCorrect = ".";
                        }

                        shareText +=
                            "${value.description} is at ${value.actionTime}${buttonCorrect}\n";
                      });

                      Share.share(shareText);
                    },
                    child: Text(
                      "Share Record",
                      style: TextStyle(fontSize: 32),
                    ),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromHeight(64)),
                  ),
                ),
              ),
            ],
          )
        ],
      )),
    );
  }
}
