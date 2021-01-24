import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:projectname/mainPages/editProfile.dart';
import 'package:projectname/subMainPages/user.dart';
import 'package:projectname/mainPages/tasks.dart';
import '../commons/const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Author: Ervin
// This page deals with the profile page code.  This profile had to be done many times, therefore there is a lot of dead
// code that can be removed from it in another iteration.

class UserProfile extends StatefulWidget {
  final MyProfileData
      myData; // grabbing user data in order to more efficiently navigate to the user's profile info
  final UserData userData; // holds the user info

  final ValueChanged<MyProfileData> updateMyDataToMain;
  UserProfile({this.myData, this.updateMyDataToMain, this.userData});
  @override
  State<StatefulWidget> createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  MyProfileData myData;

  File _image; // image file
  final picker = ImagePicker(); // object to allow picking an image

  @override
  void initState() {
    // initializing class space
    super.initState();
  }

  Future getImage(BuildContext context) async {
    // This function grabs a picture that the user gives it so the thumbnail can
    // be changed.
    var pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });

    uploadPic2(context); // uploads the picture
  }

  Future uploadPic2(BuildContext context) async {
    // uploads the picture to firebase
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref().child(
        "profilePics/$uid"); // grabbing where the picture should be located
    StorageUploadTask uploadTask = reference.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String url =
        await taskSnapshot.ref.getDownloadURL(); // creates a url for the image

    Firestore.instance // image is uploaded and saved to the profile database
        .collection('Profile')
        .document(uid)
        .updateData({'profileImage': url});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder(
                stream: Firestore.instance // the stream for the Profile info
                    .collection('Profile')
                    .document(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return LinearProgressIndicator();

                  return Container(
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.center,
                                          child: CircleAvatar(
                                            radius: 100,
                                            backgroundColor: Color(0xff476cfb),
                                            child: ClipOval(
                                              child: new SizedBox(
                                                width: 180.0,
                                                height: 180.0,
                                                child: (_image != null)
                                                    ? Image.file(
                                                        _image,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Image.network(
                                                        // shows the profile image

                                                        '${snapshot.data['profileImage']}',
                                                        fit: BoxFit.fill,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 60.0),
                                          child: IconButton(
                                            icon: Icon(Icons.photo_camera,
                                                size: 40.0, color: Colors.blue),
                                            onPressed: () {
                                              getImage(
                                                  context); // can change the image here
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {},
                            ),
                            SizedBox(
                              height: 5.0,
                            ),

                            Text('Profile Information',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),

                            SizedBox(
                                height: 20), //to add space between text widgets

                            Column(
                              // down here all of profile image info is displayed
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //this is the name card

                                Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.white,
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            child: Text(
                                          'Username: ${snapshot.data['name']}',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.left,
                                        ))
                                      ],
                                    ),
                                  ),
                                ),

                                //this is the phonenumber card
                                Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.white,
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            child: Text(
                                                'Phone Number: ${snapshot.data['PhoneNumber']}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold)))
                                      ],
                                    ),
                                  ),
                                ),

                                Card(
                                  //this is the age card
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.white,
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            child: Text(
                                          'Age: ${snapshot.data['age']}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ))
                                      ],
                                    ),
                                  ),
                                ),

                                Card(
                                  //this is the email card
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.white,
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            child: Text('Email: ${emailEmail}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold)))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  // this button lets you edit the profile fields
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Edit(snapData: snapshot.data)));
                                  },
                                  child: Text('Edit Field',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold)),
                                  textColor: Colors.white,
                                  color: Colors.blue,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
