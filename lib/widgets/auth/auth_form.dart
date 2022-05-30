import 'package:flutter/material.dart';
import 'dart:io';

import '../picker/user_image.dart';

enum AuthState { LOGIN, SIGNUP }

class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String email, String password, String userName,
      AuthState authMode, File image, BuildContext context) submitFn;
  AuthForm(this.submitFn, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  AuthState _authMode = AuthState.LOGIN;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _switchMode() {
    if (_authMode == AuthState.LOGIN) {
      setState(() {
        _authMode = AuthState.SIGNUP;
      });
    } else {
      setState(() {
        _authMode = AuthState.LOGIN;
      });
    }
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (_userImageFile == null && _authMode == AuthState.SIGNUP) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _authMode, _userImageFile, context);
      // Send request to firebase
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_authMode == AuthState.SIGNUP) UserImage(_pickedImage),
                    TextFormField(
                      key: ValueKey('email'),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) {
                        if (value.isEmpty && !value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                      ),
                      onSaved: (newValue) {
                        _userEmail = newValue;
                      },
                    ),
                    if (_authMode == AuthState.SIGNUP)
                      TextFormField(
                        key: ValueKey('username'),
                        autocorrect: true,
                        textCapitalization: TextCapitalization.words,
                        enableSuggestions: true,
                        validator: _authMode == AuthState.SIGNUP
                            ? (value) {
                                if (value.isEmpty && value.length < 4) {
                                  return 'Username must be atleast 4 characters';
                                }
                                return null;
                              }
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                        onSaved: (newValue) {
                          _userName = newValue;
                        },
                      ),
                    TextFormField(
                      key: ValueKey('password'),
                      validator: (value) {
                        if (value.isEmpty && value.length < 7) {
                          return 'Password must be atleast 7 characters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      onSaved: (newValue) {
                        _userPassword = newValue;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    if (widget.isLoading) CircularProgressIndicator(),
                    if (!widget.isLoading)
                      RaisedButton(
                        onPressed: _trySubmit,
                        child: Text(
                            '${_authMode == AuthState.LOGIN ? 'LOGIN' : 'SIGNUP'}'),
                      ),
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: _switchMode,
                      child: Text(
                          '${_authMode == AuthState.LOGIN ? 'Create a new account!' : 'I already have an account?'}'),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
