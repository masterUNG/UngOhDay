import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ungohday/models/suppliying_model.dart';
import 'package:ungohday/utility/my_style.dart';

class SuppliyingPage extends StatefulWidget {
  @override
  _SuppliyingPageState createState() => _SuppliyingPageState();
}

class _SuppliyingPageState extends State<SuppliyingPage> {
  String DOCID = '', PDAID = '02:00:00:44:55:66';
  String status;
  bool checkStatus = true;
  List<SuppliyingModel> suppliyingModels = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  Future<Null> readData() async {
    String path =
        'http://183.88.213.12/wsvvpack/wsvvpack.asmx/GETSUPPLYHEADER?DOCID=$DOCID&PDAID=$PDAID';

    print('path = $path');

    await Dio().get(path).then((value) {
      print('value = $value');

      int index = 0;
      for (var item in json.decode(value.data)) {
        if (index == 0) {
          // print('item ==>> $item');
          setState(() {
            status = item['Status'];
          });
          print('status = $status');
          if (status == 'Successful...') {
            // Show ListView
            setState(() {
              checkStatus = false;
            });
          }
        } else {
          SuppliyingModel model = SuppliyingModel.fromJson(item);
          setState(() {
            suppliyingModels.add(model);
          });
        }
        index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNewDoc(),
          buildTranfer(),
        ],
      ),
      backgroundColor: MyStyle().darkBackgroud,
      body: status == null
          ? MyStyle().showProgress()
          : checkStatus
              ? buildShowNoData()
              : buildListView(),
    );
  }

  OutlineButton buildNewDoc() {
    return OutlineButton(
      child: Text(
        'New doc.',
        style: TextStyle(color: Colors.white),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      borderSide: BorderSide(color: Colors.white),
      onPressed: () {},
    );
  }

  OutlineButton buildTranfer() {
    return OutlineButton(
      child: Text(
        'Tranfer',
        style: TextStyle(color: Colors.white),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      borderSide: BorderSide(color: Colors.white),
      onPressed: () {},
    );
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: suppliyingModels.length,
      itemBuilder: (context, index) => Card(
        color: suppliyingModels[index].statusCode == 'Remaining'
            ? Colors.orange.shade200
            : Colors.green.shade200,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Doc.'),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(suppliyingModels[index].dOCID),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Location'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      suppliyingModels[index].fromLocation,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      suppliyingModels[index].toLocation,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('BIN'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      suppliyingModels[index].fromBin,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      suppliyingModels[index].toBin,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('ITEM'),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(suppliyingModels[index].item),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('DATE'),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(suppliyingModels[index].dOCDATE),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('STATUS'),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(suppliyingModels[index].statusCode),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Center buildShowNoData() => Center(child: Text(status == null ? '' : status));
}