import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// Author: Birol
// This class deals with pictures that are added to a poem.  Once an image has been chosen, it is uploaded to a folder in Firebase,
// and its url is stored for future use.

class FBStorage {
  static Future<String> uploadPostImages(
      {@required String postID, @required File postImageFile}) async {
    try {
      String fileName = 'images/$postID/postImage';
      StorageReference reference =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putFile(postImageFile);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String postIageURL = await storageTaskSnapshot.ref.getDownloadURL();
      return postIageURL;
    } catch (e) {
      return null;
    }
  }
}
