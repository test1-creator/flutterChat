import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashchat/widgets/auth_form.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  UserCredential? userCredential;
  String errorMessage = "Error";
  var _isLoading = false;

  void _submitAuthForm(String email, String password, String username, bool isLogin, BuildContext ctx) async {
    if (isLogin) {
      try {
        setState(() {
          _isLoading = true;
        });
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        }
        final snackBar = SnackBar(content: Text(errorMessage));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
        setState(() {
          _isLoading = false;
        });
      } catch (err) {
        setState(() {
          _isLoading = false;
        });
        print(err);
      }
    } else {
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await FirebaseFirestore.instance.collection('users').doc(userCredential!.user!.uid).set(
            {
              'username': username,
              'email': email,
            });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        }
        final snackBar = SnackBar(content: Text(errorMessage));
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
