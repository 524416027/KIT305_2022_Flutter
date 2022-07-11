import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:numberpicker/numberpicker.dart';

import 'main.dart';
import 'repetitionRecord.dart';
import 'actionDetail.dart';

int currentMinuteValue = 0;
int currentSecondValue = 0;

int currentPlayTimeValue = 0;
int currentAppearButtonValue = 2;

bool randomButtonOrder = false;
bool nextButtonIndication = false;

int buttonSizeIndex = 1; //0:small, 1:medium, 2:large

bool isFreeplay = true;

class RepetitionSettings extends StatefulWidget {
  const RepetitionSettings({Key? key}) : super(key: key);

  @override
  State<RepetitionSettings> createState() => _RepetitionSettingsState();
}

class _RepetitionSettingsState extends State<RepetitionSettings> {
  void settingDebug() {
    print("minutes: $currentMinuteValue\n");
    print("seconds: $currentSecondValue\n");
    print("playTime: $currentPlayTimeValue\n");
    print("appearButton: $currentAppearButtonValue\n");
    print("randomButtonOrder: $randomButtonOrder\n");
    print("nextButtonIndication: $nextButtonIndication\n");
    print("buttonSizeIndex: $buttonSizeIndex\n");
    print("isFreeplay: $isFreeplay\n");
  }

  Color integerChangeColor(int value) {
    if (value != 0) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String integerChangeString(int value) {
    if (value != 0) {
      return "(Enabled)";
    } else {
      return "(Disabled)";
    }
  }

  Color toggleButtonChangeColor(bool value) {
    if (value) {
      return Colors.greenAccent;
    } else {
      return Colors.red;
    }
  }

  String toggleButtonChangeString(bool value) {
    if (value) {
      return "ON";
    } else {
      return "OFF";
    }
  }

  Color buttonIndexIfSelf(int index) {
    if (buttonSizeIndex == index) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  void checkIfOnFreeplay() {
    if (currentMinuteValue == 0 &&
        currentSecondValue == 0 &&
        currentPlayTimeValue == 0) {
      isFreeplay = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                //section 1 left half of screen
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 32, top: 64, right: 12),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Back to Menu",
                          style: TextStyle(fontSize: 32),
                        ),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(96),
                            primary: Colors.red),
                      ),
                    ),
                    //time limit text section row
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 32, top: 32, right: 12),
                      child: Row(
                        children: [
                          const Text(
                            "Time Limit ",
                            style: TextStyle(fontSize: 32),
                          ),
                          Text(
                              integerChangeString(
                                  currentSecondValue + currentMinuteValue),
                              style: TextStyle(
                                  fontSize: 32,
                                  color: integerChangeColor(
                                      currentSecondValue + currentMinuteValue)))
                        ],
                      ),
                    ),
                    //time limit selection section row
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 32, top: 16, right: 12),
                      child: Row(
                        children: [
                          //minutes picker
                          Expanded(
                            child: NumberPicker(
                                minValue: 0,
                                maxValue: 59,
                                value: currentMinuteValue,
                                onChanged: (value) {
                                  setState(() => currentMinuteValue = value);
                                  if (currentMinuteValue > 0) {
                                    isFreeplay = false;
                                  } else {
                                    checkIfOnFreeplay();
                                  }
                                }),
                          ),
                          const Text(
                            "Minutes",
                            style: TextStyle(fontSize: 24),
                          ),
                          //seconds picker
                          Expanded(
                            child: NumberPicker(
                                minValue: 0,
                                maxValue: 59,
                                value: currentSecondValue,
                                onChanged: (value) {
                                  setState(() => currentSecondValue = value);
                                  if (currentSecondValue > 0) {
                                    isFreeplay = false;
                                  } else {
                                    checkIfOnFreeplay();
                                  }
                                }),
                          ),
                          const Text(
                            "Seconds",
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                //section 1 right half of screen
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 64, right: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CupertinoSegmentedControl(
                          groupValue: isFreeplay ? 1 : 0,
                          children: {
                            0: SizedBox(
                              height: 96,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Repetition Mode",
                                    style: TextStyle(fontSize: 32),
                                  ),
                                ],
                              ),
                            ),
                            1: SizedBox(
                              height: 96,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Free-play Mode",
                                    style: TextStyle(fontSize: 32),
                                  ),
                                ],
                              ),
                            ),
                          },
                          onValueChanged: (value) {
                            setState(() {
                              if (value == 0) {
                                //on repetition mode
                                isFreeplay = false;

                                //enable repeat time
                                currentPlayTimeValue = 1;
                              } else {
                                //on free-play mode
                                isFreeplay = true;

                                //disable time limit and repleat time
                                currentPlayTimeValue = 0;
                                currentMinuteValue = 0;
                                currentSecondValue = 0;
                              }
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 32),
                        child: Row(
                          children: [
                            Text(
                              "Play $currentPlayTimeValue Time ",
                              style: const TextStyle(fontSize: 32),
                            ),
                            Text(
                              integerChangeString(currentPlayTimeValue),
                              style: TextStyle(
                                  fontSize: 32,
                                  color:
                                      integerChangeColor(currentPlayTimeValue)),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Slider(
                            value: currentPlayTimeValue.toDouble(),
                            min: 0,
                            max: 10,
                            onChanged: (value) {
                              setState(
                                  () => currentPlayTimeValue = value.toInt());
                              if (currentPlayTimeValue > 0) {
                                isFreeplay = false;
                              } else {
                                checkIfOnFreeplay();
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 32),
                        child: Text(
                          "Appear $currentAppearButtonValue Buttons ",
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Slider(
                            value: currentAppearButtonValue.toDouble(),
                            min: 2,
                            max: 5,
                            onChanged: (value) {
                              setState(() =>
                                  currentAppearButtonValue = value.toInt());
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          //section 2
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 32, right: 32),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          randomButtonOrder = !randomButtonOrder;
                        });
                      },
                      child: Text(
                        "Random Button Order ${toggleButtonChangeString(randomButtonOrder)}",
                        style: TextStyle(
                            fontSize: 32,
                            color: toggleButtonChangeColor(randomButtonOrder)),
                      ),
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromHeight(96)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          nextButtonIndication = !nextButtonIndication;
                        });
                      },
                      child: Text(
                        "Next-button Indication ${toggleButtonChangeString(nextButtonIndication)}",
                        style: TextStyle(
                            fontSize: 32,
                            color:
                                toggleButtonChangeColor(nextButtonIndication)),
                      ),
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromHeight(96)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //section 3
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 32, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Button Size",
                        style: TextStyle(fontSize: 32),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                buttonSizeIndex = 0;
                              });
                            },
                            child: const Text(
                              "S",
                              style: TextStyle(fontSize: 32),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(64, 64),
                                primary: buttonIndexIfSelf(0),
                                shape: const CircleBorder()),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                buttonSizeIndex = 1;
                              });
                            },
                            child: const Text(
                              "M",
                              style: TextStyle(fontSize: 64),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(128, 128),
                                primary: buttonIndexIfSelf(1),
                                shape: const CircleBorder()),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                buttonSizeIndex = 2;
                              });
                            },
                            child: const Text(
                              "L",
                              style: TextStyle(fontSize: 96),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(192, 192),
                                primary: buttonIndexIfSelf(2),
                                shape: const CircleBorder()),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 128, right: 32),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: ((context) {
                        return RepetitionExercise();
                      })));
                    },
                    child: const Text(
                      "Start Repetition Exercise!",
                      style: TextStyle(fontSize: 32),
                    ),
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(96),
                        primary: Colors.green),
                  ),
                )),
                Visibility(
                  visible: false,
                  child: ElevatedButton(
                      onPressed: () {
                        settingDebug();
                      },
                      child: Text("test button")),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}

CollectionReference db = FirebaseFirestore.instance.collection("stroke");

List<ActionDetail> actionDetails = [];

class RepetitionExercise extends StatefulWidget {
  const RepetitionExercise({Key? key}) : super(key: key);

  @override
  State<RepetitionExercise> createState() => _RepetitionExerciseState();
}

class _RepetitionExerciseState extends State<RepetitionExercise> {
  var id = "";
  RepetitionRecord repetitionRecord = RepetitionRecord(
      id: "",
      mode: "",
      repeatTimes: 0,
      startTime: "",
      endTime: "",
      completion: -1,
      actionDetail: []);

  var buttonSize = [64, 128, 192];
  var buttonTextSize = [16, 32, 48];
  bool isStarted = false;
  var buttonEnable = [false, false, false, false, false];
  var buttonPosX = [0, 0, 0, 0, 0];
  var buttonPosY = [0, 0, 0, 0, 0];
  var buttonColors = [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
  ];
  int buttonPressCount = 0;
  int roundCompleteCount = 0;
  int timeTaken = 0;
  String endID = "";

  int currentTimeCount = currentMinuteValue * 60 + currentSecondValue;
  bool timerOnPause = false;

  Timer? timer;
  Duration duration = Duration(days: 5);

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), ((timer) => setCountDown()));
  }

  /*
  void stopTimer() {
    setState(() => timer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => duration = Duration(days: 5));
  }
  */

  void setCountDown() {
    //final reduceSecondsBy = 1;
    setState(() {
      /*
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        timer!.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
      */

      if (!timerOnPause) {
        if (currentMinuteValue * 60 + currentSecondValue > 0) {
          currentTimeCount--;
        }

        timeTaken++;
        if (currentTimeCount < 0) {
          currentTimeCount = 0;
          if (isFreeplay) {
            recordGameEnd(true, "Congratulations on completing the exercise!");
          } else {
            //time up and repetition goal exists
            if (currentPlayTimeValue > 0) {
              recordGameEnd(
                  true, "Time up, didn't make it on time, try again!");
            }
            //time up but no repetition goal
            else {
              recordGameEnd(
                  true, "Congratulations on completing the exercise!");
            }
          }
        }
      }
    });
  }

  void startGame() {
    isStarted = true;

    for (int i = 0; i < currentAppearButtonValue; i++) {
      buttonEnable[i] = true;
    }

    if (nextButtonIndication) {
      buttonColors[0] = Colors.green;
    }

    buttonRandomPosition();
  }

  int randomInRange(min, max) {
    return min + Random().nextInt(max - min);
  }

  void buttonRandomPosition() {
    //yMin = 10, xMin = 10
    //yMax = 640, xMax = 1210
    //based on 64 size button

    for (int i = 0; i < currentAppearButtonValue; i++) {
      bool overLapping = false;
      do {
        overLapping = false;

        int randomX = randomInRange(10, 1274 - buttonSize[buttonSizeIndex]);
        int randomY = randomInRange(10, 704 - buttonSize[buttonSizeIndex]);
        buttonPosX[i] = randomX;
        buttonPosY[i] = randomY;

        for (int j = 0; j < i; j++) {
          if (buttonCheckOverlap(i, j)) {
            overLapping = true;
          }
        }
      } while (overLapping);
    }
  }

  bool buttonCheckOverlap(int button1, int button2) {
    if (buttonPosX[button1] >=
            buttonPosX[button2] + buttonSize[buttonSizeIndex] ||
        buttonPosX[button2] >=
            buttonPosX[button1] + buttonSize[buttonSizeIndex]) {
      return false;
    }

    if (buttonPosY[button1] + buttonSize[buttonSizeIndex] <=
            buttonPosY[button2] ||
        buttonPosY[button2] + buttonSize[buttonSizeIndex] <=
            buttonPosY[button1]) {
      return false;
    }

    return true;
  }

  void gameEnd(String endTitle) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) {
      return RepetitionResult(
          titleText: endTitle,
          timeTaken: timeTaken,
          repeatComplete: roundCompleteCount,
          id: id);
    })));
  }

  void recordGameStart() {
    print("================");
    print("record start game");
    var dt = DateTime.now();
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(dt.hour);
    final minutes = strDigits(dt.minute);
    final seconds = strDigits(dt.second);

    id = dt.toString();
    print("record start game");
    ActionDetail actionDetail = ActionDetail(
        description: "Exercise Start",
        actionTime: "$hours:$minutes:$seconds",
        actionType: "start",
        buttonCorrect: -1);

    actionDetails.add(actionDetail);

    repetitionRecord.id = id;
    repetitionRecord.mode = isFreeplay ? "Free-play" : "Repetition";
    repetitionRecord.startTime = "$hours:$minutes:$seconds";
    repetitionRecord.actionDetail = actionDetails;

    db.doc(id).set(repetitionRecord.toJson());
    /*
    db.doc(id).set({
      'id': id,
      'mode': isFreeplay ? "Free-play" : "Repetition",
      'repeatTimes': 0,
      'startTime': "$hours:$minutes:$seconds",
      'endTime': "",
      'completion': -1,
      'actionDetail': actionDetails
    });
    */
  }

  void recordGameEnd(bool failForceEnd, String endTitle) {
    timer?.cancel();
    print("record end game: $failForceEnd");
    var dt = DateTime.now();
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(dt.hour);
    final minutes = strDigits(dt.minute);
    final seconds = strDigits(dt.second);

    int completion = -1;

    if (!isFreeplay) {
      completion = failForceEnd ? 0 : 1;
    }

    ActionDetail actionDetail = ActionDetail(
        description: "Exercise End",
        actionTime: "$hours:$minutes:$seconds",
        actionType: "end",
        buttonCorrect: -1);

    actionDetails.add(actionDetail);

    repetitionRecord.repeatTimes = roundCompleteCount;
    repetitionRecord.endTime = "$hours:$minutes:$seconds";
    repetitionRecord.completion = completion;
    repetitionRecord.actionDetail = actionDetails;

    db.doc(id).update(repetitionRecord.toJson());

    endID = repetitionRecord.id;

    actionDetails.clear();
    //reset data of the round
    repetitionRecord.id = "";
    repetitionRecord.mode = "";
    repetitionRecord.repeatTimes = 0;
    repetitionRecord.startTime = "";
    repetitionRecord.endTime = "";
    repetitionRecord.completion = -1;
    repetitionRecord.actionDetail = actionDetails;

    if (endTitle != "") {
      gameEnd(endTitle);
      print("end title: $endTitle");
    }
  }

  void recordRoundComplete() {
    print("record round complete");
    print("----");
    var dt = DateTime.now();
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(dt.hour);
    final minutes = strDigits(dt.minute);
    final seconds = strDigits(dt.second);

    ActionDetail actionDetail = ActionDetail(
        description: "Round $roundCompleteCount Completed",
        actionTime: "$hours:$minutes:$seconds",
        actionType: "round",
        buttonCorrect: -1);

    actionDetails.add(actionDetail);

    repetitionRecord.actionDetail = actionDetails;

    db.doc(id).update(repetitionRecord.toJson());
  }

  void recordButtonPress(int buttonNum, bool correct) {
    print("record button press: $buttonNum, press correct: $correct");
    var dt = DateTime.now();
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(dt.hour);
    final minutes = strDigits(dt.minute);
    final seconds = strDigits(dt.second);

    ActionDetail actionDetail = ActionDetail(
        description: "Button $buttonNum pressed",
        actionTime: "$hours:$minutes:$seconds",
        actionType: "buttonPress",
        buttonCorrect: correct ? 1 : 0);

    actionDetails.add(actionDetail);

    repetitionRecord.actionDetail = actionDetails;

    db.doc(id).update(repetitionRecord.toJson());
  }

  void buttonPress(int buttonNum) {
    if (buttonPressCount == buttonNum - 1) {
      //record to database about button press correct
      recordButtonPress(buttonNum, true);
      //correct button index to next button
      buttonPressCount++;

      //set indication for next button
      if (nextButtonIndication) {
        setState(() {
          //reset current button color back to blue
          buttonColors[buttonNum - 1] = Colors.blue;

          //check if next button back to 1
          if (buttonPressCount >= currentAppearButtonValue) {
            buttonColors[0] = Colors.green;
          } else {
            buttonColors[buttonPressCount] = Colors.green;
          }
        });
      }
    } else {
      //record to database about button press wrong
      recordButtonPress(buttonNum, false);
    }

    //completed one round
    if (buttonPressCount >= currentAppearButtonValue) {
      setState(() {
        roundCompleteCount++;
      });
      //record to database about round complete
      recordRoundComplete();
      //reset count and next button index
      buttonPressCount = 0;

      //in freeplay mode
      if (isFreeplay) {
        //continual to start a new round
        newRound();
      }
      //in repetition mode
      else {
        //with round count
        if (currentPlayTimeValue != 0) {
          //meet the round complete goal
          if (roundCompleteCount >= currentPlayTimeValue) {
            recordGameEnd(
                false, "Congratulations on completing the repetition goal!");
          } else {
            //continual to start a new round
            newRound();
          }
        }
        //with time limit
        else {
          //continual to start a new round
          newRound();
        }
      }
    }
  }

  void newRound() {
    if (randomButtonOrder) {
      buttonRandomPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = strDigits((currentTimeCount / 60).toInt());
    final seconds = strDigits(currentTimeCount.remainder(60));

    return Scaffold(
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: ElevatedButton(
              onPressed: () {
                timerOnPause = true;

                showDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text("Are you sure to return to Main Menu?"),
                    content: Text("Your progress will be lost if you leave."),
                    actions: [
                      CupertinoDialogAction(
                        child: Text("Yes"),
                        onPressed: () {
                          if (isStarted) {
                            recordGameEnd(true, "");
                          }

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
              child: const Text(
                "Back to Menu",
                style: TextStyle(fontSize: 32),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(64)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Row(
              children: [
                Visibility(
                  visible: currentMinuteValue * 60 + currentSecondValue > 0,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Text(
                      "Time Left: $minutes:$seconds",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Visibility(
                  visible: currentPlayTimeValue > 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      "Repeat Done: $roundCompleteCount/$currentPlayTimeValue",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Visibility(
                  visible: isFreeplay,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      "Repeat Done: $roundCompleteCount",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          buttonRandomPosition();
                          timerOnPause = !timerOnPause;
                        });
                      },
                      child: Text("random test")),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                //start button
                Padding(
                  padding: const EdgeInsets.only(top: 256),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: !isStarted,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              startGame();
                            });

                            recordGameStart();
                            startTimer();
                          },
                          child: const Text(
                            "Start",
                            style: TextStyle(fontSize: 32),
                          ),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(512, 96),
                              primary: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                //exercise buttons
                Positioned(
                    top: buttonPosY[0].toDouble(),
                    left: buttonPosX[0].toDouble(),
                    child: Visibility(
                      visible: buttonEnable[0],
                      child: ElevatedButton(
                        onPressed: () {
                          buttonPress(1);
                        },
                        child: Text(
                          "1",
                          style: TextStyle(
                              fontSize:
                                  buttonTextSize[buttonSizeIndex].toDouble()),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                                buttonSize[buttonSizeIndex].toDouble(),
                                buttonSize[buttonSizeIndex].toDouble()),
                            shape: CircleBorder(),
                            primary: buttonColors[0]),
                      ),
                    )),
                Positioned(
                    top: buttonPosY[1].toDouble(),
                    left: buttonPosX[1].toDouble(),
                    child: Visibility(
                      visible: buttonEnable[1],
                      child: ElevatedButton(
                        onPressed: () {
                          buttonPress(2);
                        },
                        child: Text(
                          "2",
                          style: TextStyle(
                              fontSize:
                                  buttonTextSize[buttonSizeIndex].toDouble()),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                                buttonSize[buttonSizeIndex].toDouble(),
                                buttonSize[buttonSizeIndex].toDouble()),
                            shape: CircleBorder(),
                            primary: buttonColors[1]),
                      ),
                    )),
                Positioned(
                    top: buttonPosY[2].toDouble(),
                    left: buttonPosX[2].toDouble(),
                    child: Visibility(
                      visible: buttonEnable[2],
                      child: ElevatedButton(
                        onPressed: () {
                          buttonPress(3);
                        },
                        child: Text(
                          "3",
                          style: TextStyle(
                              fontSize:
                                  buttonTextSize[buttonSizeIndex].toDouble()),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                                buttonSize[buttonSizeIndex].toDouble(),
                                buttonSize[buttonSizeIndex].toDouble()),
                            shape: CircleBorder(),
                            primary: buttonColors[2]),
                      ),
                    )),
                Positioned(
                    top: buttonPosY[3].toDouble(),
                    left: buttonPosX[3].toDouble(),
                    child: Visibility(
                      visible: buttonEnable[3],
                      child: ElevatedButton(
                        onPressed: () {
                          buttonPress(4);
                        },
                        child: Text(
                          "4",
                          style: TextStyle(
                              fontSize:
                                  buttonTextSize[buttonSizeIndex].toDouble()),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                                buttonSize[buttonSizeIndex].toDouble(),
                                buttonSize[buttonSizeIndex].toDouble()),
                            shape: CircleBorder(),
                            primary: buttonColors[3]),
                      ),
                    )),
                Positioned(
                    top: buttonPosY[4].toDouble(),
                    left: buttonPosX[4].toDouble(),
                    child: Visibility(
                      visible: buttonEnable[4],
                      child: ElevatedButton(
                        onPressed: () {
                          buttonPress(5);
                        },
                        child: Text(
                          "5",
                          style: TextStyle(
                              fontSize:
                                  buttonTextSize[buttonSizeIndex].toDouble()),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                                buttonSize[buttonSizeIndex].toDouble(),
                                buttonSize[buttonSizeIndex].toDouble()),
                            shape: CircleBorder(),
                            primary: buttonColors[4]),
                      ),
                    )),
              ],
            ),
          )
        ],
      )),
    );
  }
}

class RepetitionResult extends StatefulWidget {
  const RepetitionResult(
      {Key? key,
      required this.titleText,
      required this.timeTaken,
      required this.repeatComplete,
      required this.id})
      : super(key: key);

  final String titleText;
  final int timeTaken;
  final int repeatComplete;
  final String id;

  @override
  State<RepetitionResult> createState() => _RepetitionResultState();
}

class _RepetitionResultState extends State<RepetitionResult> {
  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = strDigits((widget.timeTaken / 60).toInt());
    final seconds = strDigits(widget.timeTaken.remainder(60));

    return Scaffold(
      body: Center(
          child: (Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 128),
            child: Text(
              "${widget.titleText}",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              "Time taken: $minutes:$seconds",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              "Repeat completed: ${widget.repeatComplete}",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 32, top: 64, right: 12),
                child: ElevatedButton(
                  onPressed: () async {
                    final cameras = await availableCameras();

                    final firstCamera = cameras.first;

                    var picture = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => TakePictureScreen(
                                  camera: firstCamera,
                                  id: widget.id,
                                ))));
                  },
                  child: Text(
                    "Take a Photo",
                    style: TextStyle(fontSize: 32),
                  ),
                  style:
                      ElevatedButton.styleFrom(fixedSize: Size.fromHeight(96)),
                ),
              )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 64, right: 32),
                child: ElevatedButton(
                  onPressed: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      final picture = File(image.path);

                      try {
                        FirebaseStorage.instance
                            .ref("image/${widget.id}.jpeg")
                            .putFile(picture);
                      } on FirebaseException catch (e) {}

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => DisplayPictureScreen(
                                  imagePath: image.path))));
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Select a Picture",
                    style: TextStyle(fontSize: 32),
                  ),
                  style:
                      ElevatedButton.styleFrom(fixedSize: Size.fromHeight(96)),
                ),
              ))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 32, top: 24, right: 32),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Return to Main Menu",
                    style: TextStyle(fontSize: 32),
                  ),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size.fromHeight(96), primary: Colors.red),
                ),
              )),
            ],
          )
        ],
      ))),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final id;

  const TakePictureScreen({Key? key, required this.camera, required this.id})
      : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            final picture = File(image.path);

            try {
              await FirebaseStorage.instance
                  .ref("image/${widget.id}.jpeg")
                  .putFile(picture);
            } on FirebaseException catch (e) {}

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: ((context) =>
                        DisplayPictureScreen(imagePath: image.path))));
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.file(File(imagePath))),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home_filled),
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: ((context) {
            return MainMenu();
          })));
        },
      ),
    );
  }
}
