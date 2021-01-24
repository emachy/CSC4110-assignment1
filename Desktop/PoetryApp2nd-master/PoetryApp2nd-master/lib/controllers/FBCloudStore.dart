import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectname/commons/const.dart';
import 'package:projectname/commons/utils.dart';
import 'package:projectname/controllers/FBCloudMessaging.dart';
import 'package:projectname/mainPages/tasks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Author: Ervin, Birol, Khaled
// This page deals with sending information to Firebase.

// Author Birol ---
class FBCloudStore {
  static Future<void> sendPostInFirebase(
      // This function sends a poem's information to Firebase
      String postID,
      String postContent,
      MyProfileData userProfile,
      String postImageURL,
      String title,
      String noteBookName,
      String type) async {
    String postFCMToken;
    if (userProfile.myFCMToken == null) {
      // FCMTokens are an important part of Firebase in order to keep things unique
      SharedPreferences prefs = await SharedPreferences.getInstance();
      postFCMToken = prefs.get('FCMToken');
    } else {
      postFCMToken = userProfile.myFCMToken;
    }
    //----------

    // Ervin ---
    FirebaseUser user = await FirebaseAuth.instance
        .currentUser(); // grabbing the user info from firebase to include in
    //the firebase fields

    Firestore.instance.collection('thread').document(postID).setData({
      // This is where all poems are initially stored, the
      // Dashboard page.
      'postID': postID, // for poem indentification
      'userID': user.uid, // identify who posted the poem
      'title': title,
      'type': type,
      'userName': userProfile
          .myName, // the username of the person who posted, this is different from the userID, userID
      // cannot be changed
      'userThumbnail': userProfile.myThumbnail,
      'postTimeStamp': DateTime.now()
          .millisecondsSinceEpoch, // the time since something was posted
      'postContent': postContent, // poem text
      'postImage': postImageURL, // picture uploaded with poem
      'postLikeCount': 0,
      'postCommentCount': 0,
      'FCMToken': postFCMToken, // firebase identification token
      'viewCount': 0,
      'reporters': [], // who reported on the poem
      'timestamp': DateFormat.yMMMd()
          .format(DateTime.now()), // the time of the poem creation
      'cannotReport': [] // who cant report on a poem anymore
    });
    // --------------

    // Author Birol ---
    Firestore
        .instance // Code for uploading poems to the Notebook folder.  All Notebooks are stored into a default Notebook at first.
        .collection('FolderName')
        .document(uid)
        .collection(uid)
        .document(noteBookName)
        .collection(uid)
        .document(postID)
        .get()
        .then((docSnapshot) => {
              if (docSnapshot.exists)
                {
                  Firestore.instance
                      .collection('FolderName')
                      .document(uid)
                      .collection(uid)
                      .document(noteBookName)
                      .collection(uid)
                      .document(postID)
                      .delete(),
                }
              else
                {
                  Firestore.instance
                      .collection('FolderName')
                      .document(uid)
                      .collection(uid)
                      .document(noteBookName)
                      .collection(uid)
                      .document(postID)
                      .setData({
                    'folderName': noteBookName,
                    'postID': postID,
                    'userID': user.uid,
                    'title': title,
                    'type': type,
                    'userName': userProfile.myName,
                    'userThumbnail': userProfile.myThumbnail,
                    'postTimeStamp': DateTime.now().millisecondsSinceEpoch,
                    'postContent': postContent,
                    'postImage': postImageURL,
                    'postLikeCount': 0,
                    'postCommentCount': 0,
                    'FCMToken': postFCMToken,
                    'viewCount': 0,
                    'reporters': []
                  }),
                }
            });
  }

  //-------------

  // Ervin
  //this function is for updating the post text and the title when you edit a post.
  // The previous text is grabbed and the data is updated on the Firebase folder.
  static Future<void> postUpdate(
    String postID,
    String postContent,
    String titleInside, // title should be initialized as a string
    String type,
  ) async {
    Firestore.instance.collection('thread').document(postID).updateData({
      'postContent':
          postContent, // the content, title, and poem type are all updated when you edit a post
      'title': titleInside,
      'type': type,
    });
  }
  //---------------

  // Author Birol ---
  static Future<void> likeToPost(
      // Creates a list of people who have liked a certain post.
      String postID,
      MyProfileData userProfile,
      bool isLikePost) async {
    if (isLikePost) {
      DocumentReference likeReference = Firestore.instance
          .collection('thread')
          .document(postID)
          .collection('like')
          .document(userProfile.myName); //username stored here
      await Firestore.instance
          .runTransaction((Transaction myTransaction) async {
        await myTransaction.delete(likeReference);
      });
    } else {
      await Firestore.instance
          .collection('thread')
          .document(postID)
          .collection('like')
          .document(userProfile.myName)
          .setData({
        'userName': userProfile.myName,
        'userThumbnail': userProfile.myThumbnail,
      });
    }
  }

  static Future<void> updatePostLikeCount(DocumentSnapshot postData,
      bool isLikePost, MyProfileData myProfileData) async {
    postData.reference.updateData({
      'postLikeCount': FieldValue.increment(isLikePost ? -1 : 1)
    }); // This part of the function updates the like count on the
    // Firebase field.
    if (!isLikePost) {
      // This part was to be used to send notifications of who liked your post, but this function has been abandoned.
      await FBCloudMessaging.instance.sendNotificationMessageToPeerUser(
          '${myProfileData.myName} likes your post',
          '${myProfileData.myName}',
          postData['FCMToken']);
    }
  }

  static Future<void> updatePostCommentCount(
    // This post updates the number of comments on a poem.
    DocumentSnapshot postData,
  ) async {
    postData.reference
        .updateData({'postCommentCount': FieldValue.increment(1)});
  }

  static Future<void> updateCommentLikeCount(
      DocumentSnapshot postData,
      // This part of the function updates the like count on the
      // Firebase field for comments.
      bool isLikePost,
      MyProfileData myProfileData) async {
    postData.reference.updateData(
        {'commentLikeCount': FieldValue.increment(isLikePost ? -1 : 1)});
    if (!isLikePost) {
      // This part was to be used to send notifications of who liked your post, but this function has been abandoned.
      await FBCloudMessaging.instance.sendNotificationMessageToPeerUser(
          '${myProfileData.myName} likes your comment',
          '${myProfileData.myName}',
          postData['FCMToken']);
    }
  }

  //--------------

  // Ervin
  static Future<void> commentToPost(
      // This store a comment's data onto Firebase
      String toUserID, // user id
      String toCommentID, // comment id to identify the post
      String postID, // the id of the poem
      String commentContent,
      MyProfileData userProfile, // grabbing user profile data
      String postFCMToken) async {
    String commentID = Utils.getRandomString(8) +
        Random().nextInt(500).toString(); // create a random ID
    String myFCMToken;
    if (userProfile.myFCMToken == null) {
      //creating an FCMToken for Firebase identification purposes
      SharedPreferences prefs = await SharedPreferences.getInstance();
      myFCMToken = prefs.get('FCMToken');
    } else {
      myFCMToken = userProfile.myFCMToken;
    }
    //comment the comment to Firebase
    Firestore.instance
        .collection('thread')
        .document(postID)
        .collection(
            'comment') //comments are stored in a subcollection within a poem
        .document(commentID)
        .setData({
      'toUserID': toUserID,
      'commentID': commentID,
      'toCommentID': toCommentID,
      'userName': userProfile.myName,
      'userThumbnail': userProfile.myThumbnail,
      'commentTimeStamp': DateTime.now().millisecondsSinceEpoch,
      'commentContent': commentContent,
      'commentLikeCount': 0,
      'FCMToken': myFCMToken,
    });
    //// ----------
  }
}
