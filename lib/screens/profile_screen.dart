import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formkey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //home icon

        title: const Text('Profile Screen'),
      ),
      resizeToAvoidBottomInset: false,

      //for floating button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          shape: const StadiumBorder(),
          backgroundColor: const Color.fromARGB(255, 238, 99, 99),
          onPressed: () async {
            Dialogs.showProgressBar(context);
            await APIs.auth.signOut().then(
              (value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);

                  //2 times
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              },
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ),

      body: Form(
        key: formkey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .1),
          child: Column(children: [
            SizedBox(
              width: mq.width,
              height: mq.height * .05,
            ),
            Stack(
              children: [
                _image != null
                    ?
                    //local image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .20,
                          height: mq.height * .20,
                          fit: BoxFit.cover,
                        ),
                      )
                    :
                    //image from server
                    ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: CachedNetworkImage(
                          imageUrl: widget.user.image,
                          width: mq.height * .20,
                          height: mq.height * .20,
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: MaterialButton(
                    elevation: 1,
                    onPressed: () {
                      showBottomSheet();
                    },
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.edit, color: Colors.blue),
                  ),
                )
              ],
            ),
            SizedBox(
              height: mq.height * .03,
            ),
            Text(
              widget.user.email,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            SizedBox(
              height: mq.height * .05,
            ),
            TextFormField(
              initialValue: widget.user.name,
              onSaved: (val) => APIs.me.name = val ?? '',
              validator: (val) =>
                  val != null && val.isNotEmpty ? null : 'Required Field',
              decoration: InputDecoration(
                hintText: 'eg. Happy Singh',
                label: const Text('Name'),
                prefixIcon: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            TextFormField(
              initialValue: widget.user.about,
              onSaved: (val) => APIs.me.about = val ?? '',
              validator: (val) =>
                  val != null && val.isNotEmpty ? null : 'Required Field',
              decoration: InputDecoration(
                hintText: 'eg. Feeling Happy',
                label: const Text('About'),
                prefixIcon: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(
              height: mq.height * .05,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  minimumSize: Size(mq.width * .5, mq.height * 0.06)),
              onPressed: () {
                if (formkey.currentState!.validate()) {
                  formkey.currentState!.save();
                  APIs.updateUserInfo().then((value) => {
                        Dialogs.showSnackBar(
                            context, 'Profile Updated Successfully!')
                      });
                  log('inside validate');
                }
              },
              icon: const Icon(
                Icons.edit,
                size: 28,
              ),
              label: const Text(
                'Update',
                style: TextStyle(fontSize: 16),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .07),
            children: [
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mq.height * .01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePICTURE(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera,imageQuality: 80);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePICTURE(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
