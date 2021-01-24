// Author: Ervin
// This is the updated version of the Profile object system.  It's reduced down
// and more readable.  It holds the Profile information of a user.

class Profile {
  final String name; // represents the three fields that can be edited
  final int age;
  final int phoneNumber;

  Profile({this.name, this.age, this.phoneNumber});
}
