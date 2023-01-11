
import 'dart:convert';

DocumentTypeData documentTypeDataFromJson(String str) => DocumentTypeData.fromJson(json.decode(str));

String documentTypeDataToJson(DocumentTypeData data) => json.encode(data.toJson());

class DocumentTypeData {
  DocumentTypeData({
    this.data,
    this.msg,
    this.title,
    this.type,
  });

  Data? data;
  dynamic msg;
  dynamic title;
  int? type;

  factory DocumentTypeData.fromJson(Map<String, dynamic> json) => DocumentTypeData(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    msg: json["msg"],
    title: json["title"],
    type: json["type"] == null ? null : json["type"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : data!.toJson(),
    "msg": msg,
    "title": title,
    "type": type == null ? null : type,
  };
}

class Data {
  Data({
    this.types,
    this.sdiAuth,
    this.isDocumentEncodingExist,
    this.movimentTypes,
    this.isSdiBtnEnable,
  });

  Types? types;
  List<dynamic>? sdiAuth;
  bool? isDocumentEncodingExist;
  List<MovimentType>? movimentTypes;
  bool? isSdiBtnEnable;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    types: json["types"] == null ? null : Types.fromJson(json["types"]),
    sdiAuth: json["sdiAuth"] == null ? null : List<dynamic>.from(json["sdiAuth"].map((x) => x)),
    isDocumentEncodingExist: json["is_document_encoding_exist"] == null ? null : json["is_document_encoding_exist"],
    movimentTypes: json["movimentTypes"] == null ? null : List<MovimentType>.from(json["movimentTypes"].map((x) => MovimentType.fromJson(x))),
    isSdiBtnEnable: json["is_sdi_btn_enable"] == null ? null : json["is_sdi_btn_enable"],
  );

  Map<String, dynamic> toJson() => {
    "types": types == null ? null : types!.toJson(),
    "sdiAuth": sdiAuth == null ? null : List<dynamic>.from(sdiAuth!.map((x) => x)),
    "is_document_encoding_exist": isDocumentEncodingExist == null ? null : isDocumentEncodingExist,
    "movimentTypes": movimentTypes == null ? null : List<dynamic>.from(movimentTypes!.map((x) => x.toJson())),
    "is_sdi_btn_enable": isSdiBtnEnable == null ? null : isSdiBtnEnable,
  };
}

class MovimentType {
  MovimentType({
    this.id,
    this.name,
    this.tooltipMessage,
    this.iconName,
    this.companyId,
    this.domainId,
    this.warehouse,
    this.reserved,
    this.available,
    this.ordered,
    this.typeOperation,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  String? tooltipMessage;
  String? iconName;
  dynamic companyId;
  dynamic domainId;
  int? warehouse;
  int? reserved;
  int? available;
  int? ordered;
  String? typeOperation;
  DateTime? createdAt;
  String? updatedAt;

  factory MovimentType.fromJson(Map<String, dynamic> json) => MovimentType(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    tooltipMessage: json["tooltip_message"] == null ? null : json["tooltip_message"],
    iconName: json["icon_name"] == null ? null : json["icon_name"],
    companyId: json["company_id"],
    domainId: json["domain_id"],
    warehouse: json["warehouse"] == null ? null : json["warehouse"],
    reserved: json["reserved"] == null ? null : json["reserved"],
    available: json["available"] == null ? null : json["available"],
    ordered: json["ordered"] == null ? null : json["ordered"],
    typeOperation: json["type_operation"] == null ? null : json["type_operation"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "tooltip_message": tooltipMessage == null ? null : tooltipMessage,
    "icon_name": iconName == null ? null : iconName,
    "company_id": companyId,
    "domain_id": domainId,
    "warehouse": warehouse == null ? null : warehouse,
    "reserved": reserved == null ? null : reserved,
    "available": available == null ? null : available,
    "ordered": ordered == null ? null : ordered,
    "type_operation": typeOperation == null ? null : typeOperation,
    "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt,
  };
}

class Types {
  Types({
    this.id,
    this.name,
    this.movProducts,
    this.expiryDate,
    this.positive,
    this.cancelable,
    this.partial,
    this.transportType,
    this.oppositeDocument,
    this.sdiEconding,
    this.pensionFundExpireDate,
    this.type,
    this.isRecivedType,
    this.isInverted,
    this.soggettoEmittente,
    this.integratioj,
  });

  int? id;
  String? name;
  int? movProducts;
  int? expiryDate;
  int? positive;
  int? cancelable;
  int? partial;
  int? transportType;
  int? oppositeDocument;
  String? sdiEconding;
  String? pensionFundExpireDate;
  int? type;
  int? isRecivedType;
  int? isInverted;
  String? soggettoEmittente;
  int? integratioj;

  factory Types.fromJson(Map<String, dynamic> json) => Types(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    movProducts: json["mov_products"] == null ? null : json["mov_products"],
    expiryDate: json["expiry_date"] == null ? null : json["expiry_date"],
    positive: json["positive"] == null ? null : json["positive"],
    cancelable: json["cancelable"] == null ? null : json["cancelable"],
    partial: json["partial"] == null ? null : json["partial"],
    transportType: json["transport_type"] == null ? null : json["transport_type"],
    oppositeDocument: json["opposite_document"] == null ? null : json["opposite_document"],
    sdiEconding: json["sdi_econding"] == null ? null : json["sdi_econding"],
    pensionFundExpireDate: json["pension_fund_expire_date"] == null ? null : json["pension_fund_expire_date"],
    type: json["type"] == null ? null : json["type"],
    isRecivedType: json["is_recived_type"] == null ? null : json["is_recived_type"],
    isInverted: json["is_inverted"] == null ? null : json["is_inverted"],
    soggettoEmittente: json["soggetto_emittente"] == null ? null : json["soggetto_emittente"],
    integratioj: json["integratioj"] == null ? null : json["integratioj"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "mov_products": movProducts == null ? null : movProducts,
    "expiry_date": expiryDate == null ? null : expiryDate,
    "positive": positive == null ? null : positive,
    "cancelable": cancelable == null ? null : cancelable,
    "partial": partial == null ? null : partial,
    "transport_type": transportType == null ? null : transportType,
    "opposite_document": oppositeDocument == null ? null : oppositeDocument,
    "sdi_econding": sdiEconding == null ? null : sdiEconding,
    "pension_fund_expire_date": pensionFundExpireDate == null ? null : pensionFundExpireDate,
    "type": type == null ? null : type,
    "is_recived_type": isRecivedType == null ? null : isRecivedType,
    "is_inverted": isInverted == null ? null : isInverted,
    "soggetto_emittente": soggettoEmittente == null ? null : soggettoEmittente,
    "integratioj": integratioj == null ? null : integratioj,
  };
}