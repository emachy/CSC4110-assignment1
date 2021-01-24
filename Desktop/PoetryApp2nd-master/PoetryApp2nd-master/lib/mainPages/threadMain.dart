import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/commons/const.dart';
import 'package:projectname/mainPages/contentDetail.dart';
import 'package:projectname/subViews/threadItem.dart';
import 'package:projectname/mainPages/writePost.dart';

import '../commons/utils.dart';

// Author: Ervin, Khaled, Birol
// This file deals with the Dashboard page and all of its functions.  This file is very similar to tasks.dart.  Read that file
// for more detail on the functions here and who made them.

//Author Birol ------------------

class ThreadMain extends StatefulWidget {
  final MyProfileData myData;
  final ValueChanged<MyProfileData> updateMyData;
  ThreadMain({this.myData, this.updateMyData});
  @override
  State<StatefulWidget> createState() => _ThreadMain();
}

class _ThreadMain extends State<ThreadMain> {
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

  //these variables are for the dropdown menu and for the poem searching tasks
  String type;
  String title;
  String dropdownValue = 'All';
  String search;

  void _searchPoem() async {
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
                    labelText: 'Search a poem',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Enter the title of the poem',
                    icon: Icon(Icons.search)),
                controller: _changeNameTextController,
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'), // this cancels the search
              onPressed: () {
                Navigator.pop(this.context);
              }),
          new FlatButton(
              child: const Text(
                  'Search'), // this only gives you poems with a certain title
              onPressed: () {
                setState(() {
                  search = _changeNameTextController.text;
                  if (search == '') search = null;
                });
                Navigator.pop(this.context);
              })
        ],
      ),
    );
  }

  // ------------------ Birol Done

  _searchBar() {
    // this function contains the search bar and the filter to allow you to either search for a poem or to filter for
    // certain poem types
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.cancel),
                  //onPressed: () => _searchPoem(),
                  onPressed: () {
                    setState(() {
                      search = null;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchPoem(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            //padding: const EdgeInsets.only(left: 170.0),
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 30,
              elevation: 16,
              style: TextStyle(color: Colors.blueAccent),
              underline: Container(
                height: 3,
                color: Colors.blueAccent,
              ),
              onChanged: (String newValue) {
                // once the type of the poem is changed, the where clause is changed as well to filter
                // results
                setState(() {
                  dropdownValue = newValue;
                  type = newValue;
                  if (type == 'All') type = null;
                });
              },
              items: <String>[
                // these are all of the different poem types
                'All',
                'General',
                'Free Verse',
                'Haiku',
                'Blank Verse',
                'Narrative',
                'Epic',
                'Lyric',
                'Rhyme',
                'Romanticism',
                'Shakespearean',
                'ABC'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

//Author Birol ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _searchBar(),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(
                        'thread') // there are two where clauses to search for the title and type specified
                    .where('type', isEqualTo: type)
                    .where('title', isEqualTo: search)
                    .orderBy('postTimeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return LinearProgressIndicator();
                  return Stack(
                    children: <Widget>[
                      snapshot.data.documents.length > 0 &&
                              snapshot.data.documents.isNotEmpty
                          ? ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot data) {
                                return ThreadItem(
                                  // From the stream, the poem data is initialized so that the poem card can be created.
                                  data: data,
                                  myData: widget.myData,
                                  updateMyDataToMain: widget.updateMyData,
                                  threadItemAction: _moveToContentDetail,
                                  isFromThread: true,
                                  commentCount: data['postCommentCount'],
                                  viewCount: data['viewCount'],
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
                                      'There is no post', // you get this post if there are no poems in the dashboard
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
        // button leads you to the page to write poems
        onPressed: _writePost,
        tooltip: 'Increment',
        child: Icon(Icons.create),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  //------------------Birol Done

//this function increments the views button
  void incrementViews(var data) async {
    data.reference.updateData({'viewCount': FieldValue.increment(1)});
  }

  void _moveToContentDetail(DocumentSnapshot data) {
    // allows you to see a poem in more detail
    incrementViews(data);
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
