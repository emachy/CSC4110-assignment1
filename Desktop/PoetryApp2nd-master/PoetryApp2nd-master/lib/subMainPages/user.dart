// Author: Khaled
// This is most likely dead code.  In the past, this code held information on a
// user's profile information.

class User {
  final String uid;

  User({this.uid});
}

class UserData {
  String uid;
  String name;
  String age;
  String phoneNumber;
  String profileImage;

  UserData(
      {this.uid, this.age, this.phoneNumber, this.name, this.profileImage});
}
