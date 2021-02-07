import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungohday/models/save_model.dart';
import 'package:ungohday/models/suppliying_model.dart';
import 'package:ungohday/models/supply_detail_model.dart';
import 'package:ungohday/models/supply_detail_sqlite_model.dart';
import 'package:ungohday/state/lot_detail.dart';
import 'package:ungohday/utility/my_constant.dart';
import 'package:ungohday/utility/my_style.dart';
import 'package:ungohday/utility/normal_dialog.dart';
import 'package:ungohday/utility/sqlite_helper.dart';

class SuppliyingDetail extends StatefulWidget {
  final SuppliyingModel model;
  SuppliyingDetail({Key key, this.model}) : super(key: key);

  @override
  _SuppliyingDetailState createState() => _SuppliyingDetailState();
}

class _SuppliyingDetailState extends State<SuppliyingDetail> {
  SuppliyingModel suppliyingModel;
  bool checkStatus;
  String status;

  List<SupplyDetailModel> supplyDetailModels = List();
  List<String> lots = List();
  Map<String, int> mapBoxQTYs = Map();

  List<SupplyDetailSQLiteModel> supplyDetailSQLiteModels = List();

  int remainingInt;
  String tagQRcode;
  TextEditingController textEdittingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    textEdittingController.addListener(() {
      tagQRcode = textEdittingController.text;
    });

    suppliyingModel = widget.model;
    if (suppliyingModel != null) {
      readData();
    }
  }

  void calculateRemaining() {
    // print('lots ==>> ${lots}');
    // print('######### mapBoxqtys ==>> ${mapBoxQTYs}');
    remainingInt = 0;
    for (var item in lots) {
      setState(() {
        remainingInt = remainingInt + mapBoxQTYs[item];
      });
    }
    remainingInt = int.parse(suppliyingModel.qty) - remainingInt;
  }

  Future<Null> readData() async {
    SQLiteHelper().deleteAllValueSQLite();
    String path =
        'http://183.88.213.12/wsvvpack/wsvvpack.asmx/GETSUPPLYDETAIL?DOCID=${suppliyingModel.dOCID}&PDAID=${suppliyingModel.pDAID}&ITEMID=';
    // print('path --->> $path');
    await Dio().get(path).then((value) {
      // print('value =====>>> $value');
      var result = json.decode(value.data);
      int index = 0;
      for (var item in result) {
        if (index == 0) {
          status = item['Status'];
          // print('status ==>> $status');
          if (status == 'Successful...') {
            setState(() {
              checkStatus = false;
            });
          } else {
            setState(() {
              checkStatus = true;
            });
          }
        } else {
          SupplyDetailModel model = SupplyDetailModel.fromJson(item);
          supplyDetailModels.add(model);

          // ######################  Insert to SQLite
          SupplyDetailSQLiteModel modelSQLite = SupplyDetailSQLiteModel(
              iTEMID: model.iTEMID,
              dOCID: model.dOCID,
              sUPPLIER: model.sUPPLIER,
              bOXID: model.bOXID,
              bOXQTY: model.bOXQTY,
              lOT: model.lOT,
              status: '',
              typeCode: '');

          SQLiteHelper().insertValueToSQLite(modelSQLite);

          // createLot(model);
        }
        index++;
      } // for
      createLot();
    });
  }

  Future<Null> createLot() async {
    if (supplyDetailSQLiteModels.length != 0) {
      supplyDetailSQLiteModels.clear();
      lots.clear();
    }

    List<SupplyDetailSQLiteModel> models = await SQLiteHelper().readSQLite();

    if (models.length != 0) {
      for (var model in models) {
        // print('######### model on CreateLot ==>> ${model.toMap()}');

        if (model.status != 'delete') {
          supplyDetailSQLiteModels.add(model);
          if (lots.length == 0) {
            setState(() {
              lots.add(model.lOT);
              mapBoxQTYs[model.lOT] = model.bOXQTY;
            });
          } else {
            bool addStatus = true;
            for (var item in lots) {
              if (item == model.lOT) {
                // Lot Dulucate
                addStatus = false;
                mapBoxQTYs[model.lOT] = mapBoxQTYs[model.lOT] + model.bOXQTY;
              }
            }
            if (addStatus) {
              setState(() {
                // Non Lot Dulucape
                lots.add(model.lOT);
                mapBoxQTYs[model.lOT] = model.bOXQTY;
              });
            }
          }
        }
      } // for
      calculateRemaining();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle().darkBackgroud,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildRow1(),
            buildRow('From Location', suppliyingModel.fromLocation,
                MyStyle().titelH2red()),
            buildRow(
                'From BIN', suppliyingModel.fromBin, MyStyle().titelH2red()),
            Divider(
              color: Colors.grey,
            ),
            buildRow('To Location', suppliyingModel.toLocation,
                MyStyle().titelH2green()),
            buildRow('To BIN', suppliyingModel.toBin, MyStyle().titelH2green()),
            Divider(
              color: Colors.grey,
            ),
            buildRow('ITEM', suppliyingModel.item, MyStyle().titelH2()),
            buildRow('Quality', suppliyingModel.qty, MyStyle().titelH2()),
            buildRow(
              'Remaining',
              remainingInt == null
                  ? suppliyingModel.qty
                  : remainingInt.toString(),
              remainingInt == 0 ? MyStyle().titelH2() : MyStyle().titelH2red(),
            ),
            Divider(
              color: Colors.grey,
            ),
            showListView(),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      actions: [
        TextButton.icon(
          onPressed: () {
            saveThread();
          },
          icon: Icon(
            Icons.save,
            color: Colors.white,
          ),
          label: Text(
            'Save',
            style: MyStyle().titelH3(),
          ),
        ),
      ],
      backgroundColor: MyStyle().darkBackgroud,
      title: Text('Suppliying'),
    );
  }

  Widget showListView() {
    return checkStatus == null
        ? Expanded(child: MyStyle().showProgress())
        : checkStatus
            ? Container(
                margin: EdgeInsets.only(top: 100),
                child: Text(
                  status,
                  style: MyStyle().titelH3(),
                ),
              )
            : lots.length == 0
                ? SizedBox()
                : listViewLot();
  }

  ListView listViewLot() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: lots.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LotDetail(
                  lot: lots[index],
                  models: supplyDetailSQLiteModels,
                ),
              )).then((value) {
            setState(() {
              remainingInt = null;
              createLot();
            });
          });
        },
        child: Card(
          color: Colors.yellow[700],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('Lot'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        lots[index],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('Quality'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(mapBoxQTYs[lots[index]].toString()),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildRow(String title, String value, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildRow1() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Description :',
              style: MyStyle().titelH3(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: MyStyle().boxDecorationTextField(),
              child: TextField(
                  // initialValue: MyConstant().tagQRcode,
                  controller: textEdittingController),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                icon: Icon(
                  Icons.collections,
                  color: Colors.white,
                ),
                onPressed: () {
                  textEdittingController.text = MyConstant().tagQRcode;
                  print('tagQRcode ===>> $tagQRcode');
                  readDataQR(tagQRcode);
                }),
          ),
        ],
      ),
    );
  }

  Future<Null> readDataQR(String qrString) async {
    String path =
        'http://183.88.213.12/wsvvpack/wsvvpack.asmx/GETBARCODE?Data=$qrString';
    await Dio().get(path).then(
      (value) async {
        print('value readDataQR ==>> $value');

        var result = json.decode(value.data);

        if (result[0]['Status'] == 'Successful...') {
          print('Success');
          SupplyDetailModel model = SupplyDetailModel.fromJson(result[1]);

          List<SupplyDetailSQLiteModel> supplyDetailSQLiteModel2 =
              await SQLiteHelper().readSQLiteWhereLot(model.lOT, model.bOXID);
          print('supply.lenght ==>> ${supplyDetailSQLiteModel2.length}');
          if (supplyDetailSQLiteModel2.length != 0) {
            if (model.bOXID == 'NUL') {
              print(
                  'บวกค่าไปที่ lot ที่ตรง id at ==>> ${supplyDetailSQLiteModel2[0].id}');
              int id = supplyDetailSQLiteModel2[0].id;
              int newQTY = model.bOXQTY + supplyDetailSQLiteModel2[0].bOXQTY;

              print('curent iTemid ==>> ${supplyDetailSQLiteModel2[0].iTEMID}');

              if (int.parse(supplyDetailSQLiteModel2[0].iTEMID.trim()) == 0) {
                // insert status
                await SQLiteHelper()
                    .editBoxQTYWhereId(id, newQTY, '\$NEWDOC')
                    .then((value) {
                  setState(() {
                    createLot();
                  });
                });
              } else {
                // update status
                print('work at update Status');
                await SQLiteHelper()
                    .editBoxQTYWhereId(id, newQTY, '\$UPDDOC')
                    .then((value) {
                  setState(() {
                    createLot();
                  });
                });
              }
            } else {
              // print('ไม่ใช่ NUL รอเช็คว่า boxid เป็น อะไร ?');
              normalDialog(context, 'มีการยิง รับงานนี่ไปแย้ววว');
            }
          } else {
            print('มี lot ใหม่');

            SupplyDetailSQLiteModel supplyDetailSQLiteModel3 =
                SupplyDetailSQLiteModel(
                    iTEMID: '0',
                    dOCID: suppliyingModel.dOCID,
                    sUPPLIER: model.sUPPLIER,
                    bOXID: model.bOXID,
                    bOXQTY: model.bOXQTY,
                    lOT: model.lOT,
                    status: '\$NEWDOC',
                    typeCode: '0');

            await SQLiteHelper()
                .insertValueToSQLite(supplyDetailSQLiteModel3)
                .then((value) {
              setState(() {
                createLot();
              });
            });
          }
        } else {
          normalDialog(context, result[0]['Status']);
        }
      },
    );
  }

  Future<Null> saveThread() async {
    List<SupplyDetailSQLiteModel> models = await SQLiteHelper().readSQLite();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String user = 'e01';

    for (var item in models) {
      print('########## models ==>> ${item.toMap()}');
      if (item.status.isNotEmpty) {
        String typedoc = ' \$aaa';

        print('typedoc ==>>> $typedoc');

        SaveModel saveModel = SaveModel(
            typedoc: item.status,
            docid: item.dOCID,
            tiemid: item.iTEMID,
            item: suppliyingModel.item,
            lot: item.lOT,
            boxqty: item.bOXQTY.toString(),
            boxid: item.bOXID,
            supplier: item.sUPPLIER,
            pdaid: suppliyingModel.pDAID,
            empcode: user,
            statuscode: '');

        String path =
            'http://183.88.213.12/wsvvpack/wsvvpack.asmx/POSTSUPPLYDETAIL?TYPEDOC=${saveModel.typedoc}&DOCID=${saveModel.docid}&ITEMID=${saveModel..tiemid}&ITEM=${saveModel.item}&LOT=${saveModel.lot}&BOXQTY=${saveModel.boxqty}&BOXID=${saveModel.boxid}&SUPPLIER=${saveModel.supplier}&PDAID=${saveModel.pdaid}&EMPCODE=${saveModel.empcode}&STATUSCODE=${saveModel.statuscode}';

        await Dio().get(path).then((value) => print('Up Success'));
      }
    }
  }
}
