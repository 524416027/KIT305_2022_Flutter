import 'package:assignment_4/repetitionRecord.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'repetitionRecord.dart';
import 'actionDetail.dart';
import 'main.dart';

int numberOfSliderIndex = 0;
List<int> numberOfSlider = [2, 4, 8];
List<Color> numberOfSliderColor = [Colors.green, Colors.blue, Colors.blue];

int knobDropSpeedIndex = 0;
List<double> knobDropSpeed = [0.005, 0.01, 0.02];
List<Color> knobDropSpeedColor = [Colors.green, Colors.blue, Colors.blue];

class SliderExerciseSettings extends StatefulWidget {
  const SliderExerciseSettings({Key? key}) : super(key: key);

  @override
  State<SliderExerciseSettings> createState() => _SliderExerciseSettingsState();
}

class _SliderExerciseSettingsState extends State<SliderExerciseSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 64, right: 32),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Back to Menu",
                  style: TextStyle(fontSize: 32),
                ),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(96),
                    primary: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text("Number of Sliders", style: TextStyle(fontSize: 24)),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      numberOfSliderIndex = 0;
                    });
                  },
                  child: Text("2", style: TextStyle(fontSize: 24)),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(128, 64),
                      primary: numberOfSliderIndex == 0
                          ? Colors.green
                          : Colors.blue),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          numberOfSliderIndex = 1;
                        });
                      },
                      child: Text("4", style: TextStyle(fontSize: 24)),
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(128, 64),
                          primary: numberOfSliderIndex == 1
                              ? Colors.green
                              : Colors.blue)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          numberOfSliderIndex = 2;
                        });
                      },
                      child: Text("8", style: TextStyle(fontSize: 24)),
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(128, 64),
                          primary: numberOfSliderIndex == 2
                              ? Colors.green
                              : Colors.blue)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text("Knob drop speed", style: TextStyle(fontSize: 24)),
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        knobDropSpeedIndex = 0;
                      });
                    },
                    child: Text("Slow", style: TextStyle(fontSize: 24)),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(128, 64),
                        primary: knobDropSpeedIndex == 0
                            ? Colors.green
                            : Colors.blue)),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          knobDropSpeedIndex = 1;
                        });
                      },
                      child: Text("Normal", style: TextStyle(fontSize: 24)),
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(128, 64),
                          primary: knobDropSpeedIndex == 1
                              ? Colors.green
                              : Colors.blue)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          knobDropSpeedIndex = 2;
                        });
                      },
                      child: Text("Fast", style: TextStyle(fontSize: 24)),
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(128, 64),
                          primary: knobDropSpeedIndex == 2
                              ? Colors.green
                              : Colors.blue)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text("How to play:", style: TextStyle(fontSize: 32)),
            ),
            Text(
                "After start the exercise by press the 'Start' button at left, the slider knobs will continually drop, the game will end if half of the slider dropped to the bottom.",
                style: TextStyle(fontSize: 24)),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: ((context) {
                    return SliderExercise();
                  })));
                },
                child: Text(
                  "Start Slider Exercise!",
                  style: TextStyle(fontSize: 32),
                ),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(512, 96), primary: Colors.green),
              ),
            )
          ],
        ),
      )),
    );
  }
}

CollectionReference db = FirebaseFirestore.instance.collection("stroke");

List<ActionDetail> actionDetails = [];

class SliderExercise extends StatefulWidget {
  const SliderExercise({Key? key}) : super(key: key);

  @override
  State<SliderExercise> createState() => _SliderExerciseState();
}

class _SliderExerciseState extends State<SliderExercise> {
  var id = "";
  RepetitionRecord repetitionRecord = RepetitionRecord(
      id: "",
      mode: "",
      repeatTimes: 0,
      startTime: "",
      endTime: "",
      completion: -1,
      actionDetail: []);

  bool isStarted = false;
  List<double> sliderValues = [1, 1, 1, 1, 1, 1, 1, 1];
  List<bool> sliderVisibility = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<bool> sliderValueEmpty = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  int sliderPerformCount = 0;

  Timer? timer;
  Duration duration = Duration(days: 5);
  bool timerOnPause = false;

  void startTimer() {
    timer = Timer.periodic(
        Duration(milliseconds: 100), ((timer) => setCountDown()));
  }

  void setCountDown() {
    setState(() {
      if (!timerOnPause) {
        //drop down knobs by speed array value
        for (int i = 0; i < numberOfSlider[numberOfSliderIndex]; i++) {
          if (sliderValues[i] - knobDropSpeed[knobDropSpeedIndex] >= 0) {
            sliderValues[i] -= knobDropSpeed[knobDropSpeedIndex];

            if (sliderValues[i] <= 0) {
              sliderValueEmpty[i] = true;
            } else {
              sliderValueEmpty[i] = false;
            }
          } else {
            sliderValues[i] = 0;
            sliderValueEmpty[i] = true;
          }
        }
      }

      checkEndGame();
    });
  }

  void startGame() {
    //enable using sliders
    for (int i = 0; i < numberOfSlider[numberOfSliderIndex]; i++) {
      sliderVisibility[i] = true;
    }

    recordStartGame();
  }

  void checkEndGame() {
    int count = 0;
    for (int i = 0; i < numberOfSlider[numberOfSliderIndex]; i++) {
      if (sliderValueEmpty[i]) {
        count++;
      }

      if (count > numberOfSlider[numberOfSliderIndex] / 2) {
        endGame();
      }
    }
  }

  void endGame() {
    //stop game
    timer?.cancel();
    //disable all sliders
    for (int i = 0; i < numberOfSlider[numberOfSliderIndex]; i++) {
      sliderVisibility[i] = false;
    }

    recordEndGame();

    //alert box to return
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Too many knobs sank to the bottom, better next time!"),
        actions: [
          CupertinoDialogAction(
            child: Text("Back to Main Menu"),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: ((context) {
                return MainMenu();
              })));
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
    print("game end");
  }

  void recordStartGame() {
    print("================");
    print("record start game");
    var dt = DateTime.now();
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(dt.hour);
    final minutes = strDigits(dt.minute);
    final seconds = strDigits(dt.second);

    id = dt.toString();

    ActionDetail actionDetail = ActionDetail(
        description: "Exercise Start",
        actionTime: "$hours:$minutes:$seconds",
        actionType: "start",
        buttonCorrect: -1);

    actionDetails.add(actionDetail);

    repetitionRecord.id = id;
    repetitionRecord.mode = "Slider Exercise";
    repetitionRecord.startTime = "$hours:$minutes:$seconds";
    repetitionRecord.actionDetail = actionDetails;

    db.doc(id).set(repetitionRecord.toJson());
  }

  void recordEndGame() {
    timer?.cancel();
    print("record end game");
    var dt = DateTime.now();
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(dt.hour);
    final minutes = strDigits(dt.minute);
    final seconds = strDigits(dt.second);

    ActionDetail actionDetail = ActionDetail(
        description: "Exercise End",
        actionTime: "$hours:$minutes:$seconds",
        actionType: "end",
        buttonCorrect: -1);

    actionDetails.add(actionDetail);

    repetitionRecord.repeatTimes = sliderPerformCount;
    repetitionRecord.endTime = "$hours:$minutes:$seconds";
    repetitionRecord.completion = -1;
    repetitionRecord.actionDetail = actionDetails;

    db.doc(id).update(repetitionRecord.toJson());

    actionDetails.clear();
    //reset data of the round
    repetitionRecord.id = "";
    repetitionRecord.mode = "";
    repetitionRecord.repeatTimes = 0;
    repetitionRecord.startTime = "";
    repetitionRecord.endTime = "";
    repetitionRecord.completion = -1;
    repetitionRecord.actionDetail = actionDetails;
  }

  void recordSliderPerform(int sliderIndex, double value) {
    print("record slider action of $sliderIndex");
    sliderPerformCount++;
    var dt = DateTime.now();
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(dt.hour);
    final minutes = strDigits(dt.minute);
    final seconds = strDigits(dt.second);

    ActionDetail actionDetail = ActionDetail(
        description:
            "Slider $sliderIndex performed to value ${value.toStringAsFixed(3)}",
        actionTime: "$hours:$minutes:$seconds",
        actionType: "sliderPerform",
        buttonCorrect: -1);

    actionDetails.add(actionDetail);

    repetitionRecord.actionDetail = actionDetails;

    db.doc(id).update(repetitionRecord.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 32, top: 64, right: 64, bottom: 64),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Visibility(
                    visible: !isStarted,
                    child: ElevatedButton(
                      onPressed: () {
                        isStarted = true;
                        startGame();
                        startTimer();
                      },
                      child: Text(
                        "Start",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(fixedSize: Size(160, 64)),
                    ),
                  ),
                  Visibility(
                    visible: isStarted,
                    child: ElevatedButton(
                        onPressed: () {
                          timerOnPause = true;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                CupertinoAlertDialog(
                              title: Text(
                                  "Are you sure to end and return to Main Menu?"),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    recordEndGame();

                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: ((context) {
                                      return MainMenu();
                                    })));
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text("No"),
                                  onPressed: () {
                                    timerOnPause = false;

                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                            barrierDismissible: false,
                          );
                        },
                        child: Text(
                          "Return to Menu",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(160, 64), primary: Colors.red)),
                  ),
                ],
              ),
              //1
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[0],
                    child: Slider(
                        value: sliderValues[0],
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            sliderValues[0] = value;
                          });
                        },
                        onChangeEnd: (value) {
                          recordSliderPerform(0, value);
                        }),
                  )),
              //2
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[1],
                    child: Slider(
                        value: sliderValues[1],
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            sliderValues[1] = value;
                          });
                        },
                        onChangeEnd: (value) {
                          recordSliderPerform(1, value);
                        }),
                  )),
              //3
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[2],
                    child: Slider(
                        value: sliderValues[2],
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            sliderValues[2] = value;
                          });
                        },
                        onChangeEnd: (value) {
                          recordSliderPerform(2, value);
                        }),
                  )),
              //4
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[3],
                    child: Slider(
                      value: sliderValues[3],
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        setState(() {
                          sliderValues[3] = value;
                        });
                      },
                      onChangeEnd: (value) {
                        recordSliderPerform(3, value);
                      },
                    ),
                  )),
              //5
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[4],
                    child: Slider(
                        value: sliderValues[4],
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            sliderValues[4] = value;
                          });
                        },
                        onChangeEnd: (value) {
                          recordSliderPerform(4, value);
                        }),
                  )),
              //6
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[5],
                    child: Slider(
                        value: sliderValues[5],
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            sliderValues[5] = value;
                          });
                        },
                        onChangeEnd: (value) {
                          recordSliderPerform(5, value);
                        }),
                  )),
              //7
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[6],
                    child: Slider(
                        value: sliderValues[6],
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            sliderValues[6] = value;
                          });
                        },
                        onChangeEnd: (value) {
                          recordSliderPerform(6, value);
                        }),
                  )),
              //8
              RotatedBox(
                  quarterTurns: -45,
                  child: Visibility(
                    visible: sliderVisibility[7],
                    child: Slider(
                        value: sliderValues[7],
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            sliderValues[7] = value;
                          });
                        },
                        onChangeEnd: (value) {
                          recordSliderPerform(7, value);
                        }),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
