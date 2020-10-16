import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var com;
  var data;
  var out;
  @override
  Widget build(BuildContext context) {
    var fsconnect = FirebaseFirestore.instance;

    myfbget() async {
      var c = await fsconnect.collection("Linux_Command").get();
      for (var i in c.docs) {
        print(i.data());
      }
    }

    myapiget(q) async {
      var url = "http://192.168.43.245/cgi-bin/firebase.py?cmnd=$q";
      var r = await http.get(url);
      // var data = r.body;
      setState(() {
        data = r.body;
      });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Command Line"),
          leading: Icon(Icons.apps),
        ),
        body: Center(
          child: Container(
            width: 250,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                TextField(
                  onChanged: (x) {
                    com = x;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      await myapiget(com);
                      fsconnect.collection("Linux_Command").add({
                        '$com': '$data',
                      });
                      print('submitting');
                    }),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                    child: Text("Get"),
                    onPressed: () {
                      print("getting");
                      try {
                        out = myfbget();
                        print(data);
                      } catch (e) {
                        print("error");
                      }
                    }),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder<QuerySnapshot>(
                  builder: (context, snapshot) {
                    var c = snapshot.data.docs;
                    // print(c);
                    List<Widget> y = [];
                    for (var d in c) {
                      var output = d.data();
                      var cmnds = Text(
                        "$output",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      );
                      y.add(cmnds);
                    }

                    return Container(
                      child: Column(
                        children: y,
                      ),
                      color: Colors.grey[700],
                      padding: EdgeInsets.all(4),
                      alignment: Alignment.center,
                      width: 255,
                    );
                  },
                  stream: fsconnect.collection("Linux_Command").snapshots(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
