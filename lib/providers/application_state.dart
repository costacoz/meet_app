import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gtk_flutter/helpers/attending.dart';
import 'package:gtk_flutter/models/guest_book_message.dart';
import 'package:gtk_flutter/widgets/authentication.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;

  ApplicationLoginState get loginState => _loginState;

  String? _email;

  String? get email => _email;

  String? _userUid;

  String? get userUid => _userUid;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];

  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  StreamSubscription<DocumentSnapshot>? _attendingSubscription;

  int _attendees = 0;

  int get attendees => _attendees;

  Attending _attending = Attending.unknown;

  Attending get attending => _attending;

  set attending(Attending attending) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, bool>{'attending': true});
    } else {
      userDoc.set(<String, bool>{'attending': false});
    }
  }

  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _attendees = snapshot.docs.length;
      notifyListeners();
    });

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _userUid = user.uid;
        fetchAndSetGuestBookMessages();
        initAttendingSubscription(user);
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _userUid = null;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  void initAttendingSubscription(User user) {
    _attendingSubscription = FirebaseFirestore.instance
        .collection('attendees')
        .doc(user.uid)
        .snapshots()
        .listen(
          (snapshot) {
        if (snapshot.data() != null) {
          if (snapshot.data()!['attending'] == true) {
            _attending = Attending.yes;
          } else {
            _attending = Attending.no;
          }
        } else {
          _attending = Attending.unknown;
        }
        notifyListeners();
      },
    );
  }

  void fetchAndSetGuestBookMessages() {
    _guestBookSubscription = FirebaseFirestore.instance
        .collection('guestbook')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        _guestBookMessages = [];
        snapshot.docs.forEach(addGuestBookMessageFromDocument);
        notifyListeners();
      },
    );
  }

  void addGuestBookMessageFromDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    _guestBookMessages.add(
      GuestBookMessage(
        id: document.id,
        name: document.data()['name'] as String,
        message: document.data()['text'] as String,
        author: document.data()['userId'] as String,
      ),
    );
  }

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void verifyEmail(
      String email,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      var methods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signInWithEmailAndPassword(
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void resetPassword() {
    if (email != null) {
      FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Future<void> deleteMessageFromGuestBook(String messageId) async {
    await FirebaseFirestore.instance
        .collection('guestbook')
        .doc(messageId)
        .delete();
    notifyListeners();
  }
}