import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/commons/const.dart';
import 'package:projectname/mainPages/contentDetail.dart';
import 'package:projectname/subViews/threadItem.dart';
import 'package:projectname/mainPages/writePost.dart';
//import 'main.dart';

import '../commons/utils.dart';
import '../mainPages/tasks.dart';

// Author: Khaled
// This is the favorite page.  This page is the same as the threadMain.dart page except with a different where clause
// and a different stream.

class Favorite extends StatefulWidget {
  final MyProfileData myData;
  final ValueChanged<MyProfileData> updateMyData;
  Favorite({this.myData, this.updateMyData});
  @override
  State<StatefulWidget> createState() => _Favorite();
}

class _Favorite extends State<Favorite> {
  bool _isLoading = false;

// that is function that call when you presse the th floating buttion on the mypoem page
// it will take you to the wtiting the poem page
  void _writePost() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WritePost(
                  myData: widget.myData,
                )));
  }

// that wherr we build the list view that will list all poem cards
// it calls the collection from firestor if there is an a poem it will call thread item to list the poem
// if there is no poem in firestore then it will give you a messgae on the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //  _searchBar(),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('Favorite')
                    .document(uid)
                    .collection(uid)
                    .orderBy('postTimeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return LinearProgressIndicator();
                  return Stack(
                    children: <Widget>[
                      snapshot.data.documents.length > 0
                          ? ListView(
                              shrinkWrap: true,
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot data) {
                                return ThreadItem(
                                    data: data,
                                    myData: widget.myData,
                                    updateMyDataToMain: widget.updateMyData,
                                    threadItemAction: _moveToContentDetail,
                                    isFromThread: true,
                                    commentCount: data['postCommentCount'],
                                    viewCount: data['viewCount']);
                              }).toList(),
                            )
                          : Container(
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
                                      'There is no post',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700]),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _writePost,
        tooltip: 'Increment',
        child: Icon(Icons.create),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // this function is to move detials to the nect page
  void _moveToContentDetail(DocumentSnapshot data) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContentDetail(
                  postData: data,
                  myData: widget.myData,
                  updateMyData: widget.updateMyData,
                )));
  }
}
