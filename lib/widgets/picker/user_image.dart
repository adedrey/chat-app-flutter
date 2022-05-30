import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  UserImage(this.imagePickFn);

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  File _pickedImage;

  Future<void> _pickImage() async {
    final pickedImageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(_pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage) : null,
        ),
        FlatButton.icon(
          icon: Icon(Icons.image),
          onPressed: _pickImage,
          textColor: Theme.of(context).primaryColor,
          label: Text('Add Photo'),
        ),
      ],
    );
  }
}
