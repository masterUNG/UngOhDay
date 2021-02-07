import 'dart:convert';

class SaveModel {
  final String typedoc;
  final String docid;
  final String tiemid;
  final String item;
  final String lot;
  final String boxqty;
  final String boxid;
  final String supplier;
  final String pdaid;
  final String empcode;
  final String statuscode;
  SaveModel({
    this.typedoc,
    this.docid,
    this.tiemid,
    this.item,
    this.lot,
    this.boxqty,
    this.boxid,
    this.supplier,
    this.pdaid,
    this.empcode,
    this.statuscode,
  });


  SaveModel copyWith({
    String typedoc,
    String docid,
    String tiemid,
    String item,
    String lot,
    String boxqty,
    String boxid,
    String supplier,
    String pdaid,
    String empcode,
    String statuscode,
  }) {
    return SaveModel(
      typedoc: typedoc ?? this.typedoc,
      docid: docid ?? this.docid,
      tiemid: tiemid ?? this.tiemid,
      item: item ?? this.item,
      lot: lot ?? this.lot,
      boxqty: boxqty ?? this.boxqty,
      boxid: boxid ?? this.boxid,
      supplier: supplier ?? this.supplier,
      pdaid: pdaid ?? this.pdaid,
      empcode: empcode ?? this.empcode,
      statuscode: statuscode ?? this.statuscode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'typedoc': typedoc,
      'docid': docid,
      'tiemid': tiemid,
      'item': item,
      'lot': lot,
      'boxqty': boxqty,
      'boxid': boxid,
      'supplier': supplier,
      'pdaid': pdaid,
      'empcode': empcode,
      'statuscode': statuscode,
    };
  }

  factory SaveModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return SaveModel(
      typedoc: map['typedoc'],
      docid: map['docid'],
      tiemid: map['tiemid'],
      item: map['item'],
      lot: map['lot'],
      boxqty: map['boxqty'],
      boxid: map['boxid'],
      supplier: map['supplier'],
      pdaid: map['pdaid'],
      empcode: map['empcode'],
      statuscode: map['statuscode'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SaveModel.fromJson(String source) => SaveModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SaveModel(typedoc: $typedoc, docid: $docid, tiemid: $tiemid, item: $item, lot: $lot, boxqty: $boxqty, boxid: $boxid, supplier: $supplier, pdaid: $pdaid, empcode: $empcode, statuscode: $statuscode)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is SaveModel &&
      o.typedoc == typedoc &&
      o.docid == docid &&
      o.tiemid == tiemid &&
      o.item == item &&
      o.lot == lot &&
      o.boxqty == boxqty &&
      o.boxid == boxid &&
      o.supplier == supplier &&
      o.pdaid == pdaid &&
      o.empcode == empcode &&
      o.statuscode == statuscode;
  }

  @override
  int get hashCode {
    return typedoc.hashCode ^
      docid.hashCode ^
      tiemid.hashCode ^
      item.hashCode ^
      lot.hashCode ^
      boxqty.hashCode ^
      boxid.hashCode ^
      supplier.hashCode ^
      pdaid.hashCode ^
      empcode.hashCode ^
      statuscode.hashCode;
  }
}
