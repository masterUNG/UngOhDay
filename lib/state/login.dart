import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungohday/models/user_model.dart';
import 'package:ungohday/state/main_menu.dart';
import 'package:ungohday/utility/my_style.dart';
import 'package:ungohday/utility/normal_dialog.dart';
import 'package:crypto/crypto.dart' as crypto;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool statusRedEye = true;
  String user, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 110, left: 16, right: 16),
        decoration: BoxDecoration(color: MyStyle().darkBackgroud),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              buildTitle(),
              buildUser(),
              buildPassword(),
              buildRaisedButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRaisedButton() => Container(
      width: MediaQuery.of(context).size.width * 0.5,
      margin: EdgeInsets.only(top: 32),
      child: RaisedButton(
        color: MyStyle().buttonColor1,
        shape: MyStyle().roundType1(),
        onPressed: () {
          print('user = $user, password = $password');
          if (user == null || user.isEmpty) {
            normalDialog(context, 'Please Fill Every Blank');
          } else {
            var content = utf8.encode(password);
            var md5 = crypto.md5;

            String passwordMd5 = md5.convert(content).toString();
            print('passwordMd5 ===>>> $passwordMd5');
            checkAuthen(passwordMd5);
          }
        },
        child: Text(
          'LOG IN',
          style: MyStyle().titelH2(),
        ),
      ));

  Future<Null> checkAuthen(String passwordMd5) async {
    String path =
        'http://183.88.213.12/wsvvpack/wsvvpack.asmx/GETLOGIN?EMPCODE=$user&EMPPASSWORD=$passwordMd5';
    await Dio().get(path).then((value) {
      var result = json.decode(value.data);
      List<Map<String, dynamic>> maps = List();
      for (var item in result) {
        maps.add(item);
      }
      print('maps[0] ==>> ${maps[0]}');
      if (maps[0]['Status'] == 'Successful...') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenu(),
            ),
            (route) => false);
      } else {
        normalDialog(context, maps[0]['Status']);
      }
    });
  }

  Future<Null> savePrefer(UserModel model) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('name', model.name);
    preferences.setString('type', model.type);
    preferences.setString('storing', model.storing);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenu(
            name: model.name,
            type: model.type,
            storing: model.storing,
          ),
        ),
        (route) => false);
  }

  Widget buildUser() => Container(
        margin: EdgeInsets.only(top: 16),
        decoration: MyStyle().boxDecorationTextField(),
        height: 50,
        child: TextField(
          onChanged: (value) => user = value.trim(),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.account_box),
            contentPadding: EdgeInsets.only(left: 16, top: 14),
            hintText: 'Username :',
            border: InputBorder.none,
          ),
        ),
      );

  Widget buildPassword() => Container(
        margin: EdgeInsets.only(top: 16),
        decoration: MyStyle().boxDecorationTextField(),
        height: 50,
        child: TextField(
          onChanged: (value) => password = value.trim(),
          obscureText: statusRedEye,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            suffixIcon: IconButton(
                icon: statusRedEye
                    ? Icon(Icons.remove_red_eye)
                    : Icon(Icons.remove_red_eye_outlined),
                onPressed: () {
                  setState(() {
                    statusRedEye = !statusRedEye;
                  });
                }),
            prefixIcon: Icon(Icons.lock),
            contentPadding: EdgeInsets.only(left: 16, top: 14),
            hintText: 'Password :',
            border: InputBorder.none,
          ),
        ),
      );

  Widget buildTitle() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            'Log in',
            style: MyStyle().titelH1(),
          ),
        ],
      ),
    );
  }
}
