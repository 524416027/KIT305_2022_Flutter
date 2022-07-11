import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

import 'repetitionExercise.dart';
import 'repetitionRecord.dart';
import 'sliderExercise.dart';
import 'historyList.dart';

Future main() async {
  //converted main() to be an asynchronous function
  WidgetsFlutterBinding.ensureInitialized(); //added this line
  await initializeFirebase(); //added this line too
  runApp(const MyApp());
}

Future<FirebaseApp> initializeFirebase() async {
  //android and ios get config from the GoogleServices.json and .plist files
  return await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /*
    return MaterialApp(
      title: 'Assignment 4',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainMenu(),
    );
    */

    return ChangeNotifierProvider(
        create: (context) => RepetitionRecordModel(),
        child: MaterialApp(
            title: 'Database Tutorial',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: MainMenu()));
  }
}

String defaultUserName = "anonymous user";
String userName = "";

class MainMenu extends StatefulWidget {
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Future<void> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("userName") ?? defaultUserName;
    if (userName == "") {
      userName = defaultUserName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 128.0, right: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome, ",
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
                FutureBuilder(
                    future: getUserName(),
                    builder: (context, asyncSnapshot) {
                      return Text(
                        "$userName ",
                        style: const TextStyle(
                          fontSize: 32,
                        ),
                      );
                    }),
                //edit name button here
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return EditName();
                    })));
                  },
                  child: const Text(
                    "Edit Name",
                    style: TextStyle(fontSize: 24),
                  ),
                  style:
                      ElevatedButton.styleFrom(fixedSize: const Size(256, 64)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 96.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return RepetitionSettings();
                })));
              },
              child: const Text(
                "Repetition Exercise",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(768, 96), primary: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return SliderExerciseSettings();
                })));
              },
              child: const Text(
                "Slider Exercise",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(768, 96), primary: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: ElevatedButton(
              onPressed: () async {
                await Provider.of<RepetitionRecordModel>(context, listen: false)
                    .fetch();
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return HistoryList();
                })));
              },
              child: const Text(
                "History",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(768, 96), primary: Colors.blue),
            ),
          ),
        ],
      )),
    );
  }
}

class EditName extends StatelessWidget {
  EditName({Key? key}) : super(key: key);

  final userNameController = TextEditingController();

  void setUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (userNameController.text != "") {
      userName = userNameController.text;
      await prefs.setString("userName", userNameController.text);
    }
  }

  Future<void> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("userName") ?? defaultUserName;
    if (userName == "") {
      userName = defaultUserName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //to keep the size, when opening the keyboard
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.only(left: 64, top: 128, right: 64),
            child: Container(
              width: 640,
              child: FutureBuilder(
                  future: getUserName(),
                  builder: (context, asyncSnapshot) {
                    return TextField(
                      controller: userNameController,
                      style: const TextStyle(fontSize: 32),
                      decoration: InputDecoration(
                          hintText: "$userName",
                          labelText: "Please enter your name here:"),
                    );
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 192, right: 32),
            child: ElevatedButton(
              onPressed: () {
                setUserName();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: ((context) {
                  return MainMenu();
                })));
              },
              child: const Text(
                "Confirmed My Name",
                style: TextStyle(fontSize: 32),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(768, 96), primary: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 64, right: 32),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Enter My Name Later",
                style: TextStyle(fontSize: 32),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(768, 96), primary: Colors.green),
            ),
          ),
        ]),
      ),
    );
  }
}

//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Column(children: [Expanded(child: Center(child: Text(text)))]));
  }
}
