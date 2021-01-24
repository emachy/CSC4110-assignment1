import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:projectname/Khaled/profile2.dart';
import 'package:projectname/subMainPages/user.dart';

// Author: Khaled
// This file was the old logic behind our first iteration of updating the Profile Page.  This file is no longer used and should be
// deleted during the next iteration.

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference profileCollection =
      Firestore.instance.collection('Profile');

  // final CollectionReference folderCollection =
  //   Firestore.instance.collection('Profile');

  Future<void> updateUserData(
      String name, int age, int phoneNumber, String prfileImage) async {
    return await profileCollection.document(uid).setData({
      'name': name,
      'age': age,
      'PhoneNumber': phoneNumber,
      'profileImage': prfileImage,
    });
  }

  // user data from snapshots
  UserData userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        uid: uid,
        name: snapshot.data['name'] ?? 'Khaled',
        age: snapshot.data['age'] ?? '33',
        phoneNumber: snapshot.data['phoneNumber'] ?? '0',
        profileImage: snapshot.data['profileImage'] ??
            'https://picsum.photos/250?image=9');
  }
}
