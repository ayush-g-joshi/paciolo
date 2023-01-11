// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  LoginResponse({
    this.success,
    this.msg,
    this.loginSuccessData,
    this.title,
    this.type,
  });

  bool? success;
  String? msg;
  LoginSuccessData? loginSuccessData;
  String? title;
  int? type;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json["success"],
    msg: json["msg"],
    loginSuccessData: LoginSuccessData.fromJson(json["loginSuccessData"]),
    title: json["title"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "msg": msg,
    "loginSuccessData": loginSuccessData!.toJson(),
    "title": title,
    "type": type,
  };
}

class LoginSuccessData {
  LoginSuccessData({
    this.userInfo,
    this.documentTypes,
    this.domainDetails,
    this.warehouse,
    this.currentCompany,
    this.authorization,
    this.redirectUrl,
    this.emailDataPawan,
    this.logId,
    this.refUrl,
    this.employeeAppUrl,
  });

  UserInfo? userInfo;
  List<DocumentType>? documentTypes;
  List<DomainDetail>? domainDetails;
  List<Warehouse>? warehouse;
  CurrentCompany? currentCompany;
  String? authorization;
  String? redirectUrl;
  List<dynamic>? emailDataPawan;
  String? logId;
  String? refUrl;
  dynamic employeeAppUrl;

  factory LoginSuccessData.fromJson(Map<String, dynamic> json) => LoginSuccessData(
    userInfo: UserInfo.fromJson(json["userInfo"]),
    documentTypes: List<DocumentType>.from(json["documentTypes"].map((x) => DocumentType.fromJson(x))),
    domainDetails: List<DomainDetail>.from(json["domainDetails"].map((x) => DomainDetail.fromJson(x))),
    warehouse: List<Warehouse>.from(json["warehouse"].map((x) => Warehouse.fromJson(x))),
    currentCompany: CurrentCompany.fromJson(json["current_company"]),
    authorization: json["Authorization"],
    redirectUrl: json["redirectUrl"],
    emailDataPawan: List<dynamic>.from(json["emailDataPawan"].map((x) => x)),
    logId: json["logId"],
    refUrl: json["ref_url"],
    employeeAppUrl: json["employee_app_url"],
  );

  Map<String, dynamic> toJson() => {
    "userInfo": userInfo!.toJson(),
    "documentTypes": List<dynamic>.from(documentTypes!.map((x) => x.toJson())),
    "domainDetails": List<dynamic>.from(domainDetails!.map((x) => x.toJson())),
    "warehouse": List<dynamic>.from(warehouse!.map((x) => x.toJson())),
    "current_company": currentCompany!.toJson(),
    "Authorization": authorization,
    "redirectUrl": redirectUrl,
    "emailDataPawan": List<dynamic>.from(emailDataPawan!.map((x) => x)),
    "logId": logId,
    "ref_url": refUrl,
    "employee_app_url": employeeAppUrl,
  };
}

class CurrentCompany {
  CurrentCompany({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.subtitle,
    this.vat,
    this.companyNumber,
    this.website,
    this.businessSector,
    this.owner,
    this.multiWarehouse,
    this.created,
    this.logoUri,
    this.withholding,
    this.withholdingOn,
    this.contributionText,
    this.contributionRate,
    this.contributionWithholding,
    this.taxRegime,
    this.pensionFund,
    this.fiscalCode,
    this.isDelete,
    this.witholdingTaxVisibility,
    this.isProfessionalDocument,
    this.defaultNumeration,
    this.lastTypeOfDocumentLoadedId,
    this.companyPa,
    this.description,
    this.sdiEconding,
    this.pensionfundsumEnasarco,
    this.sdiAuthId,
    this.code,
  });

  int? id;
  String? name;
  dynamic firstName;
  dynamic lastName;
  String? subtitle;
  String? vat;
  String? companyNumber;
  String? website;
  int? businessSector;
  int? owner;
  int? multiWarehouse;
  DateTime? created;
  String? logoUri;
  String? withholding;
  int? withholdingOn;
  String? contributionText;
  int? contributionRate;
  int? contributionWithholding;
  dynamic taxRegime;
  int? pensionFund;
  dynamic fiscalCode;
  int? isDelete;
  int? witholdingTaxVisibility;
  int? isProfessionalDocument;
  String? defaultNumeration;
  int? lastTypeOfDocumentLoadedId;
  int? companyPa;
  String? description;
  String? sdiEconding;
  int? pensionfundsumEnasarco;
  int? sdiAuthId;
  bool? code;

  factory CurrentCompany.fromJson(Map<String, dynamic> json) => CurrentCompany(
    id: json["id"],
    name: json["name"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    subtitle: json["subtitle"],
    vat: json["vat"],
    companyNumber: json["company_number"],
    website: json["website"],
    businessSector: json["business_sector"],
    owner: json["owner"],
    multiWarehouse: json["multi_warehouse"],
    created: DateTime.parse(json["created"]),
    logoUri: json["logo_uri"],
    withholding: json["withholding"],
    withholdingOn: json["withholding_on"],
    contributionText: json["contribution_text"],
    contributionRate: json["contribution_rate"],
    contributionWithholding: json["contribution_withholding"],
    taxRegime: json["tax_regime"],
    pensionFund: json["pension_fund"],
    fiscalCode: json["fiscal_code"],
    isDelete: json["is_delete"],
    witholdingTaxVisibility: json["witholding_tax_visibility"],
    isProfessionalDocument: json["is_professional_document"],
    defaultNumeration: json["default_numeration"],
    lastTypeOfDocumentLoadedId: json["last_type_of_document_loaded_id"],
    companyPa: json["company_pa"],
    description: json["Description"],
    sdiEconding: json["sdi_econding"],
    pensionfundsumEnasarco: json["pensionfundsum_enasarco"],
    sdiAuthId: json["sdi_auth_id"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "first_name": firstName,
    "last_name": lastName,
    "subtitle": subtitle,
    "vat": vat,
    "company_number": companyNumber,
    "website": website,
    "business_sector": businessSector,
    "owner": owner,
    "multi_warehouse": multiWarehouse,
    "created": created!.toIso8601String(),
    "logo_uri": logoUri,
    "withholding": withholding,
    "withholding_on": withholdingOn,
    "contribution_text": contributionText,
    "contribution_rate": contributionRate,
    "contribution_withholding": contributionWithholding,
    "tax_regime": taxRegime,
    "pension_fund": pensionFund,
    "fiscal_code": fiscalCode,
    "is_delete": isDelete,
    "witholding_tax_visibility": witholdingTaxVisibility,
    "is_professional_document": isProfessionalDocument,
    "default_numeration": defaultNumeration,
    "last_type_of_document_loaded_id": lastTypeOfDocumentLoadedId,
    "company_pa": companyPa,
    "Description": description,
    "sdi_econding": sdiEconding,
    "pensionfundsum_enasarco": pensionfundsumEnasarco,
    "sdi_auth_id": sdiAuthId,
    "code": code,
  };
}

class DocumentType {
  DocumentType({
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
    this.text,
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
  SoggettoEmittente? soggettoEmittente;
  String? text;

  factory DocumentType.fromJson(Map<String, dynamic> json) => DocumentType(
    id: json["id"],
    name: json["name"],
    movProducts: json["mov_products"],
    expiryDate: json["expiry_date"],
    positive: json["positive"],
    cancelable: json["cancelable"],
    partial: json["partial"],
    transportType: json["transport_type"],
    oppositeDocument: json["opposite_document"],
    sdiEconding: json["sdi_econding"] == null ? null : json["sdi_econding"],
    pensionFundExpireDate: json["pension_fund_expire_date"],
    type: json["type"],
    isRecivedType: json["is_recived_type"] == null ? null : json["is_recived_type"],
    isInverted: json["is_inverted"],
    soggettoEmittente: soggettoEmittenteValues.map[json["soggetto_emittente"]],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mov_products": movProducts,
    "expiry_date": expiryDate,
    "positive": positive,
    "cancelable": cancelable,
    "partial": partial,
    "transport_type": transportType,
    "opposite_document": oppositeDocument,
    "sdi_econding": sdiEconding == null ? null : sdiEconding,
    "pension_fund_expire_date": pensionFundExpireDate,
    "type": type,
    "is_recived_type": isRecivedType == null ? null : isRecivedType,
    "is_inverted": isInverted,
    "soggetto_emittente": soggettoEmittenteValues.reverse![soggettoEmittente],
    "text": text,
  };
}

enum SoggettoEmittente { TZ, CC }

final soggettoEmittenteValues = EnumValues({
  "CC": SoggettoEmittente.CC,
  "TZ": SoggettoEmittente.TZ
});

class DomainDetail {
  DomainDetail({
    this.id,
    this.domainId,
    this.name,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  int? domainId;
  String? name;
  String? value;
  dynamic createdAt;
  dynamic updatedAt;

  factory DomainDetail.fromJson(Map<String, dynamic> json) => DomainDetail(
    id: json["id"],
    domainId: json["domain_id"],
    name: json["name"],
    value: json["value"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "domain_id": domainId,
    "name": name,
    "value": value,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

enum CreatedAtEnum { THE_00000000000000 }

final createdAtEnumValues = EnumValues({
  "0000-00-00 00:00:00": CreatedAtEnum.THE_00000000000000
});

class UserInfo {
  UserInfo({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.profileStatus,
    this.thumbPath,
    this.domainId,
    this.activeLang,
    this.userTypeSlug,
  });

  int? id;
  String? firstName;
  String? lastName;
  String? email;
  dynamic profileStatus;
  String? thumbPath;
  int? domainId;
  String? activeLang;
  String? userTypeSlug;

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    profileStatus: json["profile_status"],
    thumbPath: json["thumbPath"],
    domainId: json["domain_id"],
    activeLang: json["active_lang"],
    userTypeSlug: json["user_type_slug"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "profile_status": profileStatus,
    "thumbPath": thumbPath,
    "domain_id": domainId,
    "active_lang": activeLang,
    "user_type_slug": userTypeSlug,
  };
}

class Warehouse {
  Warehouse({
    this.id,
    this.name,
    this.isDefault,
    this.isDelete,
  });

  int? id;
  String? name;
  int? isDefault;
  int? isDelete;

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
    id: json["id"],
    name: json["name"],
    isDefault: json["is_default"],
    isDelete: json["is_delete"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_default": isDefault,
    "is_delete": isDelete,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
