import 'package:flutter/material.dart';
import 'package:ungohday/state/recieving.dart';
import 'package:ungohday/state/storing.dart';
import 'package:ungohday/state/supplying.dart';

class MyConstant {
  String domain = 'https://9ed2619cc439.ngrok.io';
  List<String> titleMenus = ['RECIEVING', 'STORING', 'SUPPLYING'];
  List<IconData> iconMenus = [Icons.filter_1, Icons.filter_2, Icons.filter_3];
  List<Widget> currentWidgets = [Recieving(), Storing(), Supplying()];
  List<List<String>> subTitles = [
    [],
    ['BOX BY BOX', 'BIN TO BIN'],
    []
  ];

  String tagQRcode = 'GX759BWKHS10N*22 (2348)|AISIN ASIA PACIFFIC Co.,Ltd.|||1200|5|||         2020090003760019|NUL||';
  // String tagQRcode = 'GX759BWKHS10N*22 (2348)|AISIN ASIA PACIFFIC Co.,Ltd.|||1200|5|||2020090003760015|010||';


  MyConstant();
}
