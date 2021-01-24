import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/commons/const.dart';
import 'package:projectname/mainPages/contentDetail.dart';
import 'package:projectname/subViews/threadItem2.dart';
import 'package:projectname/mainPages/writePost.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../commons/utils.dart';

// Author: Ervin, Khaled, Birol
// This file deals with the My Poems Page and all of its functions.  This file also sets the global uid and sets up the
// profile page for new users.

// Ervin
// Simple Creation of the class state based off of the standard Flutter template
class Your extends StatefulWidget {
  final MyProfileData myData;
  final ValueChanged<MyProfileData> updateMyData;
  Your({this.myData, this.updateMyData});
  @override
  State<StatefulWidget> createState() => _ThreadMain();
}

class _ThreadMain extends State<Your> {
  bool _isLoading = false;

  void _writePost() {
    // This leads to the page where you can write new poems.
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WritePost(
                  myData: widget.myData,
                )));
  }
// ------------------------------------------

  @override
  Widget build(BuildContext context) {
    profileSet(); //this sets up a new profile if needed
    return Scaffold(
      // Ervin
      // I created the stream here
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('thread')
              .where('userID',
                  isEqualTo:
                      uid) // The where clause makes it so only your poems are displayed.
              .orderBy('postTimeStamp', descending: true)
              .snapshots(),
          //---------------------------------------------

          // Author Birol ---------------------

          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            return Stack(
              children: <Widget>[
                snapshot.data.documents.length > 0
                    ? ListView(
                        shrinkWrap: true,
                        children: snapshot.data.documents

                            // --------------------------------Birol Done

                            .map((DocumentSnapshot data) {
                          // Ervin
                          return ThreadItem(
                            // From the stream, the poem data is initialized so that the poem card can be created.
                            data: data, // data from the snapshot
                            myData: widget
                                .myData, // data from the widget to add widget specific data
                            updateMyDataToMain: widget
                                .updateMyData, // data from the widget that allows you to update the data
                            threadItemAction:
                                _moveToContentDetail, // adding a function to the widget that allows you to move to
                            // the comment thread
                            isFromThread:
                                true, // checking to make sure that a pome actually belongs in a thread
                            commentCount: data[
                                'postCommentCount'], // sending info on how many comments there are
                            viewCount: data[
                                'viewCount'], // sending how many views there are on the poem
                          );
                        }).toList(),
                        //----------------------------
                      )
                    : Container(
                        //Author Birol ------------------
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.error,
                              color: Colors.grey[700],
                              size: 64,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(
                                'There is no post', // Message if you have no poems currently
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )),
                      ),
                Utils.loadingCircle(_isLoading),
              ],
            );
          }),
      //----------------------------------Birol Done
      // Ervin
      floatingActionButton: FloatingActionButton(
        // button leads you to the page to write poems
        onPressed: _writePost,
        tooltip: ' ',
        child: Icon(Icons.create),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
    // ------------------------------------------------
  }

// Ervin
  void _moveToContentDetail(DocumentSnapshot data) {
    // allows you to see a poem in more detail by going to the comment thread
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContentDetail(
                  postData: data, // look above for what these variables mean
                  myData: widget.myData,
                  updateMyData: widget.updateMyData,
                )));
  }
// ------------------------------------------
}

// Ervin
String uid; // global uid for Firebase purposes
String emailName; // Email name for the profile page
String emailEmail; // Email's email name for the profile page

Future<Void> inputData1() async {
  // grabs the uid and sets it globally for further use
  final FirebaseUser user = await FirebaseAuth.instance.currentUser();
  //print(user);
  uid = user.uid.toString();
  emailName = user.displayName.toString();
  emailEmail = user.email.toString();
}
//--------------------------------------

Future<Void> profileSet() async {
  // sets up the profile page for new users if needed.
  await Firestore.instance
      .collection('Profile')
      .document(uid)
      .get()
      .then((docSnapshot) async {
    if (!docSnapshot.exists) {
      await Firestore.instance.collection('Profile').document(uid).setData({
        'name': "name",
        'age': "age",
        'PhoneNumber': "phoneNumber",
        'profileImage': 'https://picsum.photos/250?image=9',
      });
    }
  });
}
