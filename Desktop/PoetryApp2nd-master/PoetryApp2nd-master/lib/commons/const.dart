// Author: Khaled and Birol
// This class holds all of the "constant" information that's used in the application.  This includes profile information,
// Firebase connections, and password character information.

const String firebaseCloudserverToken = //  Firebase server connection.
    'AAAAt7GY6Lo:APA91bHEq2Xi6m4716ciM8KgnGcHYw7YJ8K5X3_pFnzbzRkZzyX4nKRkbQFn8pKceSWVFXoYjYuToqGZcnrEhHqhI9gRG7OxQHtrjypm8o2LElq5v0zhOw0Sb64itx54DtpDfb9Du86H';
const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

class MyProfileData {
  // Class that represents the essence of the Profile Page.
  final String myThumbnail;
  final String myName;
  final List<String> myLikeList;
  final List<String> myLikeCommnetList;
  final String myFCMToken;
  MyProfileData(
      {this.myName,
      this.myThumbnail,
      this.myLikeList,
      this.myLikeCommnetList,
      this.myFCMToken});
}
