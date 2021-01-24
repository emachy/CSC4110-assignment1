import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectname/mainPages/tasks.dart';

// Author: Ervin
// This file deals with editing the Profile information.

enum SingingCharacter {
  username,
  phone,
  age
} // The possible fields that can be edited are defined here.

class Edit extends StatefulWidget {
  final snapData;
  Edit({Key key, this.snapData}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _Edit();
}

class _Edit extends State<Edit> {
  SingingCharacter _character =
      SingingCharacter.username; // Radio button character is defined.
  TextEditingController writingTextController =
      TextEditingController(); // grabbing the editing text
  FocusNode writingTextFocus =
      FocusNode(); // creating a docus node for the text

  @override // This build defines a GUI with 3 radio buttons that allow you to change your username, age, or phone number.
  // Everytime a different radio option is chosen, the state of the enum is changed.
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Change the Desired Field'),
          centerTitle: true,
          actions: <Widget>[],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            ListTile(
              title: const Text(
                'Username',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              leading: Radio(
                value: SingingCharacter.username,
                groupValue: _character,
                onChanged: (SingingCharacter value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text(
                'Phone Number',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              leading: Radio(
                value: SingingCharacter.phone,
                groupValue: _character,
                onChanged: (SingingCharacter value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text(
                'Age',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              leading: Radio(
                value: SingingCharacter.age,
                groupValue: _character,
                onChanged: (SingingCharacter value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
            ),
            TextFormField(
              autofocus: true,
              focusNode: writingTextFocus,
              decoration: InputDecoration(
                hintText:
                    'Enter a new field', // The value of the field that you want to change is defined here.
                hintMaxLines: 4,
              ),
              controller: writingTextController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    // When the value of the field is chosen, the field is updated on Firebase.

                    print('The value is ${_character.toString()}');
                    _editInfo(context, widget.snapData, _character.toString(),
                        writingTextController.text);
                  },
                  child: Text('Confirm',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  textColor: Colors.white,
                  color: Colors.blue,
                )
              ],
            )
          ],
        ));
  }
}

Future<String> _editInfo(
    // This function updates the profile page on Firebase depending on what field is chosen.
    var context,
    var widget,
    String option,
    String newField) async {
  var option2 = option.toString();
  String field;
  if (option2 == "SingingCharacter.username") {
    field = "name";
    Firestore.instance
        .collection('Profile')
        .document(uid)
        .updateData({field: newField});
  } else if (option2 == "SingingCharacter.phone") {
    field = "PhoneNumber";
    Firestore.instance
        .collection('Profile')
        .document(uid)
        .updateData({field: newField});
  } else if (option2 == "SingingCharacter.age") {
    field = "age";
    Firestore.instance
        .collection('Profile')
        .document(uid)
        .updateData({field: newField});
  }

  Navigator.pop(context);
}
