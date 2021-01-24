import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectname/controllers/FBStorage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:projectname/mainPages/tasks.dart';
import '../commons/const.dart';
import '../commons/utils.dart';
import '../controllers/FBCloudStore.dart';
import '../controllers/FBStorage.dart';

// Author: Ervin and Khaled
// This file deals with writing the poem.

class WritePost extends StatefulWidget {
  final MyProfileData myData;
  WritePost({this.myData});
  @override
  State<StatefulWidget> createState() => _WritePost();
}

class _WritePost extends State<WritePost> {
  TextEditingController writingTextController = TextEditingController();
  TextEditingController titleTextController = TextEditingController();

  String typeTextController = 'General'; // the default category
  String folderName;

  final FocusNode _nodeText1 = FocusNode();
  FocusNode writingTextFocus = FocusNode();
  bool _isLoading = false;
  File _postImageFile;
  Future<String> _addToNote(var context) async {
    // the accused variable is for the email function

    final QuerySnapshot result = await Firestore
        .instance // All of the folders are grabbed so that you can choose which one you want to store your poem in

        .collection('FolderName')
        .document(uid)
        .collection(uid)
        .getDocuments();
    final List<DocumentSnapshot> noteBookoption = result.documents;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add the poem to a notebook'),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: noteBookoption.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(noteBookoption[index]
                        .data
                        .values
                        .toString()
                        .replaceAll('(', "")
                        .replaceAll(")", "")),
                    onTap: () {
                      folderName = noteBookoption[index]
                          .data
                          .values
                          .toString()
                          .replaceAll('(', "")
                          .replaceAll(")", "");
                      print(folderName);

                      Navigator.pop(this.context);

                      // Navigator.pop(context, noteBookoption[index]);
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          displayArrows: false,
          focusNode: _nodeText1,
        ),
        KeyboardActionsItem(
          displayArrows: false,
          focusNode: writingTextFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  print('Select Image');
                  _getImageAndCrop(); // an image is grabbed for the poem
                },
                child: Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.add_photo_alternate, size: 28),
                      Text(
                        "Add Image",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  void _postToFB() async {
    // when the post button is pressed, the poem is sent to a function which uploads it to firebase
    setState(() {
      _isLoading = true;
    });
    String postID = Utils.getRandomString(8) + Random().nextInt(500).toString();
    String postImageURL;
    if (_postImageFile != null) {
      postImageURL = await FBStorage.uploadPostImages(
          postID: postID, postImageFile: _postImageFile);
    }
    FBCloudStore.sendPostInFirebase(
        postID,
        writingTextController.text,
        widget.myData,
        postImageURL ?? 'NONE',
        titleTextController.text ?? 'NONE',
        folderName ?? 'General',
        typeTextController ?? 'None');

    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Your Poem'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
              onPressed: () => _postToFB(),
              child: Text(
                'Post',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
      body: Stack(
        children: <Widget>[
          KeyboardActions(
            config: _buildConfig(context),
            child: Column(
              children: <Widget>[
                Container(
                    width: size.width,
                    height: size.height -
                        MediaQuery.of(context).viewInsets.bottom -
                        80,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14.0, left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Image.network(
                                        '${widget.myData.myThumbnail}')),
                              ),
                              /*Text(
                                widget.myData.myName,
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),*/
                            ],
                          ),
                          Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          TextFormField(
                            autofocus: true,
                            focusNode: writingTextFocus,
                            decoration: InputDecoration(
                              border:
                                  InputBorder.none, // Here you can add a title.
                              hintText: 'Add title.',
                              hintMaxLines: 4,
                            ),
                            controller: titleTextController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          FlatButton.icon(
                            onPressed: () => _addToNote(context),
                            icon: Icon(Icons.book),
                            label: Text("Select Notebook"),
                            color: Colors.lightBlue,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          DropdownButton<String>(
                            value: typeTextController,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                //dropdownValue = newValue;
                                typeTextController = newValue;
                              });
                            },
                            items: <String>[
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
                          Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          TextFormField(
                            autofocus: true,
                            focusNode: writingTextFocus,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Writing anything.',
                              hintMaxLines: 4,
                            ),
                            controller: writingTextController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                          _postImageFile != null
                              ? Image.file(
                                  _postImageFile,
                                  fit: BoxFit.fill,
                                )
                              : Container(),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Utils.loadingCircle(_isLoading),
        ],
      ),
    );
  }

  Future<void> _getImageAndCrop() async {
    // this function grabs and gets the image so that it can be added to the poem
    File imageFileFromGallery =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFileFromGallery != null) {
      File cropImageFile = await Utils.cropImageFile(
          imageFileFromGallery); //await cropImageFile(imageFileFromGallery);
      if (cropImageFile != null) {
        setState(() {
          _postImageFile = cropImageFile;
        });
      }
    }
  }
}
