// import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_distributor/details.dart';
import 'package:food_distributor/refugees.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

@immutable
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: "Camp Food Distro",
      home: RefugeePage(),
    );
  }
}

class RefugeePage extends StatelessWidget {
  RefugeePage({Key? key}) : super(key: key);
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camp List"), //home title
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(children: [
            // text box to enter refugee name
            Expanded(
                child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "Enter New Name"),
            )),
            //to save the name on database (ony name for now)
            TextButton(
              onPressed: () {
                _saveTask();
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ), // color: Colors.blue,
            )
          ]),
          //show list of saved refugees
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("Refugees").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Expanded(
                child: _buildList(snapshot.requireData),
              );
            },
          )
        ]),
      ),
    );
  }

  //save name function called at button click to save refugee name
  void _saveTask() {
    final refugeeName = _controller.text;
    double _points = 0;
    double totalPoints = 0;

    FirebaseFirestore.instance.collection("Refugees").add({
      "name": refugeeName,
      "Points": _points,
      // "Total Point": totalPoints,
      "Age": "-",
      "weight": "-",
      "Gender": "-",
      "Contribution": "-",
    });

    _controller.clear();
  }

  //buildlist function called in StreamBuilder to display refugee list
  Widget _buildList(QuerySnapshot snapshot) {
    return ListView.builder(
        itemCount: snapshot.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.docs[index];

          return Dismissible(
            key: Key(doc.id),
            background: Container(
              color: Colors.red, //colour on slide deleting
            ),
            onDismissed: (direction) {
              //delete doc from database by sliding sideways
              FirebaseFirestore.instance
                  .collection("Refugees")
                  .doc(doc.id)
                  .delete();
            },
            //navigate to more refugee details on name click
            child: ListTile(
              title: Text(doc["name"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //passing refugee name and id along...
                    builder: (context) => DetailScreen(
                        refugee: Refugee(doc["name"]), refugeeid: doc.id),
                  ),
                );
              },
            ),
          );
        });
  }
}
