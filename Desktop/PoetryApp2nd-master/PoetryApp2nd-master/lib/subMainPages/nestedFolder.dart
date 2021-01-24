import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/subMainPages/folder.dart';
import 'package:projectname/subMainPages/user.dart';
import 'package:projectname/commons/const.dart';
import '../mainPages/tasks.dart';

// Author: Khaled
// This page displays the list of folders to the users

class Folder extends StatefulWidget {
  final MyProfileData myData;
  final ValueChanged<MyProfileData> updateMyData;
  Folder({this.myData, this.updateMyData});
  @override
  State<StatefulWidget> createState() => _Folder();
}

//global variable for the folder name, try make local, that was last min work, we did not have time to change it
String folderName;

class _Folder extends State<Folder> {
  MyProfileData myData;
  UserData userData;

//this function activates when the delete function is pressed
// this allows you to delete a folder
  Future<String> _deleteConfirm(var context) async {
    List<String> deleteChoices = [
      'Yes',
      'No',
    ];
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
            //the constrained box should make the alert dialog box smaller
            constraints: BoxConstraints(maxHeight: 100.0),
            child: AlertDialog(
              contentPadding: EdgeInsets.all(
                  0.0), //too get rid of the whitespace that Seyed didn't want
              title: Text('Delete Confirmation'),
              content: Container(
                width: double.minPositive,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: deleteChoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(deleteChoices[index]),
                      onTap: () {
                        Navigator.pop(context, deleteChoices[index]);
                        if (deleteChoices[index] == 'Yes') {
                          Firestore.instance
                              .collection('FolderName')
                              .document(uid)
                              .collection(uid)
                              .document(folderName)
                              .delete();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          );
        });
  }

  // this function creates a new folder when a button is pressed
  void _createFolder() async {
    TextEditingController _changeNameTextController = TextEditingController();
    await showDialog(
      context: this.context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Type the name of the Notebook',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Notebook name',
                    icon: Icon(Icons.edit)),
                controller: _changeNameTextController,
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(this.context);
              }),
          new FlatButton(
              child: const Text('SAVE'),
              onPressed: () {
                folderName = _changeNameTextController.text;
                Firestore.instance
                    .collection('FolderName')
                    .document(uid)
                    .collection(uid)
                    .document(folderName)
                    .setData({"folderName": folderName});
                Navigator.pop(this.context);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('FolderName')
              .document(uid)
              .collection(uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return new ListView(
                  children: snapshot.data.documents.map((document) {
                return new ListTile(
                  leading: Icon(Icons.note),
                  trailing: Icon(Icons.keyboard_arrow_right),

                  ///selected: true,
                  onTap: () {
                    // when you press on this button, you're led to the folder page which holds all of your poems.
                    folderName = document["folderName"].toString();
                    print("this is $folderName");

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Folder2(
                                  myData: widget.myData,
                                  updateMyData: widget.updateMyData,
                                )));
                  },

                  title: new Text(document["folderName"].toString()),

                  onLongPress: () {
                    // long pressing a folder activates the delete function
                    folderName = document["folderName"].toString();
                    _deleteConfirm(context);
                  },
                );
              }).toList());
            }
          }),
      // this is the button that when presses will take to the creat folder function
      floatingActionButton: FloatingActionButton(
        onPressed: _createFolder,
        tooltip: 'Increment',
        child: Icon(Icons.create_new_folder),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
