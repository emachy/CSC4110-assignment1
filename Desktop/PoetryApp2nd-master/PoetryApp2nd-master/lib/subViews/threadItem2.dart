import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/commons/const.dart';
import 'package:projectname/commons/utils.dart';
import 'package:projectname/mainPages/tasks.dart';
import 'package:projectname/mainPages/editPost.dart';
import 'package:share/share.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:koukicons/thumbUp.dart';
import 'package:koukicons/edit.dart';
import 'package:koukicons/trash2.dart';
import 'package:koukicons/favourite2.dart';
import 'package:koukicons/folderX.dart';
import 'package:koukicons/share.dart';
import 'package:koukicons/collaboration.dart';
import 'package:koukicons/reading.dart';
import 'package:koukicons/report.dart';
import 'package:expandable_text/expandable_text.dart';

import "package:intl/intl.dart";

// Authors: Ervin, Birol, Khaled
// This program creates the poem cards for the My Poems card.  Look at the threadItem.dart for more documentation.

class ThreadItem extends StatefulWidget {
  final DocumentSnapshot data;
  final MyProfileData myData;

  final ValueChanged<MyProfileData> updateMyDataToMain;
  final bool isFromThread;
  final Function threadItemAction;
  final int commentCount;
  final int viewCount;
  ThreadItem(
      {this.data,
      this.myData,
      this.updateMyDataToMain,
      this.threadItemAction,
      this.isFromThread,
      this.commentCount,
      this.viewCount});
  @override
  State<StatefulWidget> createState() => _ThreadItem();
}

class _ThreadItem extends State<ThreadItem> {
  String title = "title";
  MyProfileData _currentMyData;
  int _likeCount;
  String folderName;

  //int _favoriteCount;
  bool _favoriteColor = false;

  @override
  void initState() {
    _currentMyData = widget.myData;
    _likeCount = widget.data['postLikeCount'];
    //_favoriteCount = widget.data['favorite'];

    super.initState();
  }

  void _updateLikeCount(bool isLikePost) async {
    MyProfileData _newProfileData = await Utils.updateLikeCount(
        widget.data,
        widget.myData.myLikeList != null &&
                widget.myData.myLikeList.contains(widget.data['postID'])
            ? true
            : false,
        widget.myData,
        widget.updateMyDataToMain,
        true);
    setState(() {
      _currentMyData = _newProfileData;
    });
    setState(() {
      isLikePost ? _likeCount-- : _likeCount++;
    });
  }

  void _selectFolder() async {
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
                    labelText: 'Type the name of the folder',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Add a folder name',
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
                print(folderName);

                Firestore.instance
                    .collection('FolderName')
                    .document(uid)
                    .collection(uid)
                    .document(folderName)
                    .collection(uid)
                    .document(widget.data['postID'])
                    .get()
                    .then((docSnapshot) => {
                          if (docSnapshot.exists)
                            {
                              Firestore.instance
                                  .collection('FolderName')
                                  .document(uid)
                                  .collection(uid)
                                  .document(folderName)
                                  .collection(uid)
                                  .document(widget.data['postID'])
                                  .delete(),
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'The poem has been removed from your Folder list')))
                            }
                          else
                            {
                              Firestore.instance
                                  .collection('FolderName')
                                  .document(uid)
                                  .collection(uid)
                                  .document(folderName)
                                  .collection(uid)
                                  .document(widget.data['postID'])
                                  .setData({
                                'folderName': folderName,
                                'postID': widget.data['postID'],
                                'userID': uid,
                                'title': widget.data['title'],
                                'type': widget.data['type'],
                                'userName': widget.data['userName'],
                                'userThumbnail': widget.data['userThumbnail'],
                                'postTimeStamp':
                                    DateTime.now().millisecondsSinceEpoch,
                                'postContent': widget.data['postContent'],
                                'postImage': widget.data['postImage'],
                                'postLikeCount': 0,
                                'postCommentCount': 0,
                                'FCMToken': widget.data['FCMToken'],
                                'viewCount': 0,
                                'reporters': [],
                                'timestamp': widget.data['timestamp'],
                              }),
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'The poem has been added to Folder List ')))
                            }
                        });

                Navigator.pop(this.context);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var docData1 = widget.data;
    var docID1 = docData1.documentID;

    //navigate to the write post page

    void _writePost(var text, var postID, var titleText) {
      poemText = text;
      titleMain = titleText;
      currentPostID = postID;
      print('sonicMan $titleMain');
      // print('$title');

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditPost(
                    myData: widget.myData,
                  )));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => widget.isFromThread
                    ? widget.threadItemAction(widget.data)
                    : null,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 2.0, 10.0, 2.0),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xff476cfb),
                        child: ClipOval(
                          child: new SizedBox(
                            width: 45.0,
                            height: 45.0,

                            //stream builders are nestable
                            child: StreamBuilder(
                                stream: Firestore.instance
                                    .collection('Profile')
                                    .document(widget.data['userID'])
                                    .snapshots(),
                                builder: (context, snapshot2) {
                                  if (!snapshot2.hasData)
                                    return LinearProgressIndicator();

                                  return Image.network(
                                    //'${widget.data['userThumbnail']}',
                                    '${snapshot2.data['profileImage']}',

                                    //??
                                    //'${widget.myData.myThumbnail}',
                                    fit: BoxFit.fill,
                                  );
                                }),
                            // : Image.asset(
                            //     "images/$_myThumbnail",
                            //     fit: BoxFit.fill,
                            //   ),
                          ),
                        ),
                      ),

                      // Container(width: 48, height: 48, child: Image.network(
                      //     //'${widget.myData.myThumbnail}')),

                      //     '${widget.data['userThumbnail']}')),
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            StreamBuilder(
                                stream: Firestore.instance
                                    .collection('Profile')
                                    .document(widget.data['userID'])
                                    .snapshots(),
                                builder: (context, snapshot3) {
                                  if (!snapshot3.hasData)
                                    return LinearProgressIndicator();

                                  return Text(
                                    snapshot3.data['name'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  );
                                }),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                Utils.readTimestamp(
                                    widget.data['postTimeStamp']),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ),
                            Text(
                              widget.data['timestamp'],
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 100),
                          child: Text(
                            //Utils.readTimestamp(widget.data['postTimeStamp']),
                            //'$title',
                            widget.data['type'],

                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 150.0, top: 20.0),
                    child: Text(
                      //Utils.readTimestamp(widget.data['postTimeStamp']),
                      //'$title',
                      (widget.data['title'] as String).length > 1
                          ? 'Title: ${widget.data['title']}'
                          : widget.data['title'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                          color: Colors.black87),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => widget.isFromThread
                    ? widget.threadItemAction(widget.data)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
                  child: ExpandableText(
                    (widget.data['postContent'] as String),

                    style: TextStyle(
                      fontSize: 16,
                    ),
                    collapseText: 'Show Less',
                    expandText: 'Show More',
                    maxLines: 5,
                    linkColor: Colors.blue,

                    //maxLines: 3,
                  ),
                ),
              ),
              widget.data['postImage'] != 'NONE'
                  ? GestureDetector(
                      onTap: () => widget.isFromThread
                          ? widget.threadItemAction(widget.data)
                          : widget.threadItemAction(),
                      child: Utils.cacheNetworkImageWithEvent(
                          context, widget.data['postImage'], 0, 0))
                  : Container(),
              Divider(
                height: 2,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _updateLikeCount(
                          _currentMyData.myLikeList != null &&
                                  _currentMyData.myLikeList
                                      .contains(widget.data['postID'])
                              ? true
                              : false),
                      child: Row(
                        children: <Widget>[
                          KoukiconsThumbUp(
                              height: 20.0,
                              width: 20.0,
                              //size: 18,
                              color: widget.myData.myLikeList != null &&
                                      widget.myData.myLikeList
                                          .contains(widget.data['postID'])
                                  ? Colors.blue[900]
                                  : null),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 0.0, top: 10.0),
                            child: Text(
                              '${NumberFormat.compact().format(widget.isFromThread ? widget.data['postLikeCount'] : _likeCount)}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: widget.myData.myLikeList != null &&
                                          widget.myData.myLikeList
                                              .contains(widget.data['postID'])
                                      ? Colors.blue[900]
                                      : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: <Widget>[
                          //this is the Views Function
                          Padding(padding: const EdgeInsets.only(left: 0.0)),
                          KoukiconsReading(
                            height: 20.0,
                            width: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              //'${widget.viewCount}',
                              '${NumberFormat.compact().format(widget.viewCount)}',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      //this gesture is for the REPORT button

                      onTap: () {
                        if (widget.data['reporters'].contains(uid)) {
                          _unreportPoem(context, widget.data);
                        }
                        //you should be only able to report a poem once, no more no less
                        else if (widget.data['cannotReport'].contains(uid) &&
                            !widget.data['reporters'].contains(uid)) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('You can only report a poem once.')));
                        } else {
                          _reportPoem(context, widget.data);
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          KoukiconsReport(
                              height: 20.0,
                              width: 20.0,
                              //color: reportColor,
                              color: widget.data['reporters'].contains(uid)
                                  ? Colors.blue
                                  : null),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      //this gesture is for the add favoirte button
                      onTap: () {
                        setState(() {
                          if (_favoriteColor)
                            _favoriteColor = false;
                          else
                            _favoriteColor = true;
                        });

                        Firestore.instance
                          ..collection('Favorite')
                              .document(uid)
                              .collection(uid)
                              .document(widget.data['postID'])
                              .get()
                              .then((docSnapshot) => {
                                    if (docSnapshot.exists)
                                      {
                                        Firestore.instance
                                            .collection('Favorite')
                                            .document(uid)
                                            .collection(uid)
                                            .document(widget.data['postID'])
                                            .delete(),
                                        Scaffold.of(context).showSnackBar(SnackBar(
                                            content: Text(
                                                'The poem has been removed from your favorite list')))
                                      }
                                    else
                                      {
                                        Firestore.instance
                                            .collection('Favorite')
                                            .document(uid)
                                            .collection(uid)
                                            .document(widget.data['postID'])
                                            .setData({
                                          'postID': widget.data['postID'],
                                          'userID': uid,
                                          'title': widget.data['title'],
                                          'type': widget.data['type'],
                                          'userName': widget.data['userName'],
                                          'userThumbnail':
                                              widget.data['userThumbnail'],
                                          'postTimeStamp': DateTime.now()
                                              .millisecondsSinceEpoch,
                                          'postContent':
                                              widget.data['postContent'],
                                          'postImage': widget.data['postImage'],
                                          'postLikeCount': 0,
                                          'postCommentCount': 0,
                                          'FCMToken': widget.data['FCMToken'],
                                          'viewCount': 0,
                                          'reporters': []
                                        }),
                                        Scaffold.of(context).showSnackBar(SnackBar(
                                            content: Text(
                                                'The poem has been added to favorite List $_favoriteColor')))
                                      }
                                  });
                      },

                      child: Row(
                        children: <Widget>[
                          KoukiconsFavourite2(
                            height: 20.0,
                            width: 20.0,
                            color:
                                _favoriteColor ? Colors.yellow.shade600 : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      //this gesture is for the add Folder button
                      onTap: () {
                        _selectFolder();
                      },

                      child: Row(
                        children: <Widget>[
                          KoukiconsFolderX(
                            height: 20.0,
                            width: 20.0,

                            // color: _favoriteColor
                            //     ? Colors.yellow.shade600
                            //     : Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      //this gesture is for the SHARE button

                      onTap: () => share(widget.data, context),
                      child: Row(
                        children: <Widget>[
                          KoukiconsShare(
                            height: 20.0,
                            width: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.isFromThread
                          ? widget.threadItemAction(widget.data)
                          : null,
                      child: Row(
                        children: <Widget>[
                          KoukiconsCollaboration(
                            height: 20.0,
                            width: 20.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 2.0, top: 10.0),
                            child: Text(
                              //'${widget.commentCount}',
                              '${NumberFormat.compact().format(widget.commentCount)}',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //This is a second row for the icons so everything isn't as cluttered
              Row(
                children: <Widget>[
                  GestureDetector(
                    //this gesture is for the EDIT button

                    //this is the needed syntax to send arguments
                    onTap: () {
                      //only allow function to trigger if this is the user's poem
                      if (visible(docData1, docID1)) {
                        _writePost(widget.data['postContent'],
                            widget.data['postID'], widget.data['title']);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                        ),
                        KoukiconsEdit(
                            height: 20.0,
                            width: 20.0,
                            color:
                                visible(docData1, docID1) ? null : Colors.grey),
                        Padding(
                          padding: const EdgeInsets.only(left: 37.0),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    //this gesture is for the DELETE button

                    onTap: () {
                      //determines if the user can use the function or not
                      if (visible2(docData1, docID1)) {
                        if (widget.isFromThread) {
                          //widget.threadItemAction(widget.data);
                          var docData = widget.data;
                          var docID = docData.documentID;
                          _deleteConfirm(context, docID, widget);
                        }
                        //don't use null as an else or else it won't delete on the first time
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        KoukiconsTrash2(
                            height: 20.0,
                            width: 20.0,
                            color: visible2(docData1, docID1)
                                ? null
                                : Colors.grey),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//this is the edit button
bool visible(var docData, var docID) {
  bool vis = true;
  if (docData['userID'] == uid) {
    //if a comment exists on your poem, you cannot edit it
    if (docData['postCommentCount'] == 0) {
      vis = true;
    } else {
      vis = false;
    }
  } else {
    vis = false;
  }
  return vis;
}

//this is for the delete button
bool visible2(var docData, var docID) {
  bool vis = true;
  if (docData['userID'] == uid) {
    vis = true;
  } else {
    vis = false;
  }
  return vis;
}

bool deleteBool;

//this function activates when the delete function is pressed
Future<String> _deleteConfirm(var context, var docID, var widget) async {
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
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
                        //deleteBool = true;
                        Firestore.instance
                            .collection("thread")
                            .document(docID)
                            .delete();
                        Firestore.instance
                            .collection(uid)
                            .document(docID)
                            .delete();
                        Firestore.instance
                          ..collection('Favorite')
                              .document(uid)
                              .collection(uid)
                              .document(widget.data['postID'])
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

//global variable to hold the previously saved text
//for edit post function
var poemText;
var currentPostID;
var titleMain;

//this function will be modified later to include pictures
void share(var poemText, var context) {
  //renderer to accomodate different screen sizes
  final RenderBox box = context.findRenderObject();
  Share.share(poemText['postContent'],
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}

//this is a list of options that list all of the possible reporting categories
List<String> reportOptions = [
  'Illegal',
  'Spam',
  'Offensive',
  'Uncivil',
  'Not relevant'
];

List<String> unreportOptions = ['Un-Report the Poem'];

//this function activates when the reporting function is pressed
Future<String> _reportPoem(var context, var accused) async {
  //the accused variable is for the email function
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Content'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: reportOptions.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(reportOptions[index]),
                  onTap: () {
                    sendComplaint(
                        "shenshenlisp1999@gmail.com",
                        reportOptions[index],
                        uid,
                        accused); //this is the admin email

                    Navigator.pop(context, reportOptions[index]);
                  },
                );
              },
            ),
          ),
        );
      });
}

Future<String> _unreportPoem(var context, var accused) async {
  //the accused variable is for the email function
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Un-Report Content'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: unreportOptions.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(unreportOptions[index]),
                  onTap: () {
                    sendComplaint(
                        "shenshenlisp1999@gmail.com",
                        unreportOptions[index],
                        uid,
                        accused); //this is the admin email
                    Navigator.pop(context, unreportOptions[index]);
                  },
                );
              },
            ),
          ),
        );
      });
}

//this function opens up a gmail for the user to send their complaint
void sendComplaint(
    String emailID, String complaint, String userUID, var accused) async {
  //subject: complaint : Defendant-> name ; Accuser-> name ; PostID -> name;
  changeReportColor(accused);
  var accused1 = accused['userID'];
  var accused2 = accused['postID'];

  String username = 'shenshenlisp1999@gmail.com';
  String password = 'ahlucuvprahmjlap';

  final smtpServer = gmail(username, password);

  // Create our message.
  final message = Message()
    ..from = Address(username, accused1)
    ..recipients.add('shenshenlisp1999@gmail.com')
    ..subject = 'Reported Poem :: ${DateTime.now()}'
    ..text =
        'Complaint: $complaint\nReporter: $accused1\nReported User: $userUID\nReported Content: $accused2';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

void undo(String emailID, String complaint, String userUID, var accused) async {
  var accused1 = accused['userID'];
  var accused2 = accused['postID'];
  changeReportColor(accused);

  String username = 'shenshenlisp1999@gmail.com';
  String password = 'ahlucuvprahmjlap';

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
    ..from = Address(username, accused1)
    ..recipients.add('shenshenlisp1999@gmail.com')
    ..subject = 'Unreport Poem :: ${DateTime.now()}'
    ..text =
        'Un-Reporter: $accused1\nUn-Reported User: $userUID\nUn-Reported Content: $accused2';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

//this variable is for the report button color
//the report button should change color depending on if you reported a poem or not
//black = default ; blue = reported
var reportColor = Colors.black;

void changeReportColor(var data) async {
  List<String> names = List.from(data['reporters']);
  if (names.contains(uid)) {
    List<String> temp = [uid];
    data.reference.updateData({'reporters': FieldValue.arrayRemove(temp)});
  } else {
    List<String> temp = [uid];
    data.reference.updateData({
      'reporters': FieldValue.arrayUnion(temp),
      'cannotReport': FieldValue.arrayUnion(temp)
    });
  }
}
