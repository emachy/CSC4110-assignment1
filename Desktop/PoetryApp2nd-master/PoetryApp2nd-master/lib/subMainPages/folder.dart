import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/subMainPages/nestedFolder.dart';
import 'package:projectname/commons/const.dart';
import 'package:projectname/mainPages/contentDetail.dart';
import 'package:projectname/subViews/threadIteamNotebook.dart';
import '../commons/utils.dart';
import '../mainPages/tasks.dart';

// Author: Khaled
// This file details the page that shows the content of a certain folder.  It is the same as the threadMain page except
// with a different stream.  Read that documentation for more details.

class Folder2 extends StatefulWidget {
  final MyProfileData myData;

  final ValueChanged<MyProfileData> updateMyData;
  Folder2({this.myData, this.updateMyData});

  @override
  State<StatefulWidget> createState() => _Folder();
}

class _Folder extends State<Folder2> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('FolderName')
                    .document(uid)
                    .collection(uid)
                    .document(folderName)
                    .collection(uid)
                    //.where('type', isEqualTo: type)
                    //.where('favorite', isEqualTo: 1)
                    // .where('title', isEqualTo: search)
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
                                return ThreadItemNotebook(
                                  data: data,
                                  myData: widget.myData,
                                  updateMyDataToMain: widget.updateMyData,
                                  threadItemAction: _moveToContentDetail,
                                  isFromThread: true,
                                  commentCount: data['postCommentCount'],
                                );
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
