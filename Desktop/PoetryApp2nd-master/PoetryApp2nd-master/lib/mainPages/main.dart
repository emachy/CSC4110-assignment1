import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projectname/subMainPages/favorite.dart';
import 'package:projectname/subMainPages/nestedFolder.dart';
import 'package:projectname/subMainPages/user.dart';
import 'package:projectname/commons/const.dart';
import 'package:projectname/mainPages/authentication.dart';
import 'package:projectname/localization/l10n/demo_localization.dart';
import 'package:projectname/localization/l10n/language_constants.dart';
import 'package:projectname/mainPages/userprofile2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commons/utils.dart';
import '../controllers/FBCloudMessaging.dart';
import 'threadMain.dart';
import 'package:projectname/mainPages/loginScreen.dart';
import 'package:projectname/mainPages/tasks.dart';
import 'package:projectname/blocks/auth_bloc.dart';

// Author: Ervin, Khaled, Birol
// This is the main page, where all of the app's logic originates.  This page also has links to all of Argot's main pages
// as well.

// Ervin
void main() =>
    runApp(MyApp()); // Main startup logic.  Comes with every Flutter program

class MyApp extends StatefulWidget {
  final String initialRoute;
  MyApp({this.initialRoute});

  static void setLocale(BuildContext context, Locale newLocale) {
    // Khaled added this setLocale here
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}
// -------------------------------

// Author Birol -------------------

class _MyAppState extends State<MyApp> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
        ),
      );
    } else {
      return Provider(
        create: (context) => AuthBloc(),
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.indigo,
          ),
          home: LoginScreen(), // This is where the app will start off from.
          locale: _locale, // Grabbing the language information.
          supportedLocales: [
            Locale("en", "US"),
            Locale("fa", "IR"),
            Locale("ar", "YE"),
            Locale("tr", "TR")
          ],
          localizationsDelegates: [
            DemoLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
        ),
      );
    }
  }
}

// another page
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TabController _tabController;
  MyProfileData myData;
  UserData userData;

  bool _isLoading = false;

  @override
  void initState() {
    _tabController = new TabController(
        vsync: this, length: 5); // Controls the different "tabs" of the app.
    _tabController.addListener(
        _handleTabSelection); // Listens for the different tab changes
    _takeMyData(); // Grabs user data from the database and local storage.
    super.initState();
  }

  Future<void> _takeMyData() async {
    // Grabs user data from the database and local storage.
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myThumbnail;
    String myName;

    if (prefs.get('myName') == null) {
      String tempName = Utils.getRandomString(8);
      prefs.setString('myName', tempName);
      myName = tempName;
    } else {
      myName = prefs.get('myName');
    }

    final Firestore database = Firestore.instance;
    Future<DocumentSnapshot> snapshot =
        database.collection('Profile').document(uid).get();

    setState(() {
      snapshot.then((DocumentSnapshot userSnapshot) async {});

      myData = MyProfileData(
        // This initializes the like list so that the user cannot like something more than once.
        myThumbnail: myThumbnail,
        myName: myName,
        myLikeList: prefs.getStringList('likeList'),
        myLikeCommnetList: prefs.getStringList('likeCommnetList'),
        myFCMToken: prefs.getString('FCMToken'),
      );
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _handleTabSelection() =>
      setState(() {}); // Handles the selecting of tabs.

  void onTabTapped(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  void updateMyData(MyProfileData newMyData) {
    // Updates profile page info
    setState(() {
      myData = newMyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'title')),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => signOutUser().then((value) {
              // The sign out page icon that allows you to sign out almost anywhere
              // in the app.
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false);
            }),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          TabBarView(controller: _tabController, children: [
            // handles the different tabs
            // Tabs include the Dashboard page, My Poems Page, Favorite page, Folder page, and User Profile.
            // Each tab is initialized with user data so that it is shared between tabs.
            ThreadMain(
              myData: myData,
              updateMyData: updateMyData,
            ),
            Your(
              myData: myData,
              updateMyData: updateMyData,
            ),
            Favorite(
              myData: myData,
              updateMyData: updateMyData,
            ),
            Folder(
              myData: myData,
              updateMyData: updateMyData,
            ),
            UserProfile(
              myData: myData,
              userData: userData,
            ),
          ]),
          Utils.loadingCircle(_isLoading),
        ],
      ),
//----------------------------------Birol Done

      // Ervin
      bottomNavigationBar: BottomNavigationBar(
        // The tabs are located in the bottom navigation bar.
        onTap: onTabTapped,
        currentIndex: _tabController.index,
        selectedItemColor: Colors.amber[900],
        unselectedItemColor: Colors.grey[800],
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            // The titles and icons for each tab are defined here.
            icon: new Icon(Icons.people), // icons associated with each tab
            title: new Text(getTranslated(context, 'dashBoard')),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.face),
            title: new Text(getTranslated(context, 'poems')),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.star),
            title: new Text(getTranslated(context, 'favorite')),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.library_books),
            title: new Text(getTranslated(context, 'folder')),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.account_circle),
            title: new Text(getTranslated(context, 'profile')),
          ),
          // ------------------------------------------
        ],
      ),
    );
  }
}

String globalProfileName;
