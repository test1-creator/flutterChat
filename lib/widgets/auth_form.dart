import 'dart:io';

import 'package:flashchat/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);

  final void Function(String email, String password, String username, File? _userImageFile ,bool isLogin, BuildContext ctx) submitFn;
  final bool isLoading;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEmail = "";
  String _userName = "";
  String _userPassword = "";
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if(!_isLogin && _userImageFile == null ) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please pick an image")));
      return;
    }

    if(isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(), _userImageFile, _isLogin, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(!_isLogin)
                    UserImagePicker(_pickedImage),

                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email required';
                      } else if (!value.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email address",
                    ),
                    onSaved: (value) {
                      _userEmail = value.toString();
                    },
                  ),

                  if(!_isLogin)
                  TextFormField(
                    key: ValueKey('username'),
                    validator: (value) {
                      if(value!.isEmpty) {
                        return "Username required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Username",
                    ),
                    onSaved: (value) {
                      _userName = value.toString();
                    },
                  ),

                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password required';
                      } else if (value.length < 7) {
                        return 'Password is too short min 8 characters required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value.toString();
                    },
                  ),

                  SizedBox(
                    height: 12,
                  ),

                  if(widget.isLoading)
                    CircularProgressIndicator(),
                  if(!widget.isLoading)
                    ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(_isLogin ? 'Login' : 'Signup'),
                  ),

                  if(!widget.isLoading)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin ? 'Create new account' : 'I already have an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
