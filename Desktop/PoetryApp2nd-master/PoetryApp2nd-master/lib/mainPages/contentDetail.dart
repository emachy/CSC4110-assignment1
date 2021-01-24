import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/commons/fullPhoto.dart';
import 'package:projectname/controllers/FBCloudStore.dart';
import 'package:projectname/subViews/threadItem.dart';

import '../commons/const.dart';

import '../commons/utils.dart';
import '../subViews/commentItem.dart';

// Author: Birol
// This file deals with the comments page and some of the functions underlying it.

class ContentDetail extends StatefulWidget {
  // This class is initialized with data from another class in order to obtain
// Profile and Poem data.
  final DocumentSnapshot postData;
  final MyProfileData myData;
  final ValueChanged<MyProfileData> updateMyData;
  ContentDetail({this.postData, this.myData, this.updateMyData});
  @override
  State<StatefulWidget> createState() => _ContentDetail();
}

class _ContentDetail extends State<ContentDetail> {
  final TextEditingController _msgTextController = new TextEditingController();
  MyProfileData currentMyData;
  String _replyUserID;
  String _replyCommentID;
  String _replyUserFCMToken;
  FocusNode _writingTextFocus = FocusNode();

  @override
  void initState() {
    currentMyData = widget.myData; // Poem data is initialized.
    _msgTextController.addListener(
        _msgTextControllerListener); // Comment data is listened for.
    super.initState();
  }

  void _msgTextControllerListener() {
    // Comment data is null if comment is empty.
    if (_msgTextController.text.length == 0 ||
        _msgTextController.text.split(" ")[0] != _replyUserID) {
      _replyUserID = null;
      _replyCommentID = null;
      _replyUserFCMToken = null;
    }
  }

  void _replyComment(List<String> commentData) async {
    // Sets the comment data of a reply.

    _replyUserID = commentData[0];
    _replyCommentID = commentData[1];
    _replyUserFCMToken = commentData[2];
    FocusScope.of(context).requestFocus(_writingTextFocus);
    _msgTextController.text = '${commentData[0]} ';
  }

  void _moveToFullImage() => Navigator.push(
      // Grabs the image associated with the poem.
      context,
      MaterialPageRoute(
          builder: (context) => FullPhoto(
                imageUrl: widget.postData['postImage'],
              )));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Post Detail'),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore
                .instance // Comment data is grabbed from the relevant Firebase collection.
                .collection('thread')
                .document(widget.postData['postID'])
                .collection('comment')
                .orderBy('commentTimeStamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              return Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ThreadItem(
                                  // From the stream, the poem data is initialized so that the poem card can be created.
                                  viewCount: widget.postData['viewCount'],
                                  data: widget.postData,
                                  myData: widget.myData,
                                  updateMyDataToMain: widget.updateMyData,
                                  threadItemAction: _moveToFullImage,
                                  isFromThread: false,
                                  commentCount:
                                      widget.postData['postCommentCount'],
                                ),
                                snapshot.data.documents.length >
                                        0 // Creating a listview for comments.
                                    ? ListView(
                                        primary: false,
                                        shrinkWrap: true,
                                        children: Utils.sortDocumentsByComment(
                                                snapshot.data.documents)
                                            .map((document) {
                                          return CommentItem(
                                              data: document,
                                              myData: widget.myData,
                                              size: size,
                                              updateMyDataToMain:
                                                  widget.updateMyData,
                                              replyComment: _replyComment);
                                        }).toList(),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTextComposer()
                ],
              );
            }));
  }

  Widget _buildTextComposer() {
    // The bottom of the page where user comments are initialized.
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                focusNode:
                    _writingTextFocus, // Defines the keyboard focus for this widget.
                controller: _msgTextController, // Grabs comment text.
                onSubmitted:
                    _handleSubmitted, // Function that's run when the submit button is pressed.
                decoration:
                    new InputDecoration.collapsed(hintText: "Write a comment"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 2.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () {
                    _handleSubmitted(_msgTextController
                        .text); // Function that's run when the submit button is pressed.
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    // Initializing comment information so that it can be sent to Firebase for
    // further storage.
    try {
      await FBCloudStore.commentToPost(
          _replyUserID == null ? widget.postData['userName'] : _replyUserID,
          _replyCommentID == null
              ? widget.postData['commentID']
              : _replyCommentID,
          widget.postData['postID'],
          _msgTextController.text,
          widget.myData,
          _replyUserID == null
              ? widget.postData['FCMToken']
              : _replyUserFCMToken);
      await FBCloudStore.updatePostCommentCount(
          widget.postData); // update comment count
      FocusScope.of(context).requestFocus(FocusNode());
      _msgTextController.text = '';
    } catch (e) {
      print('error to submit comment');
    }
  }
}
