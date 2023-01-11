import 'dart:convert';

LoginUserModel loginUserModelFromJson(String str) => LoginUserModel.fromJson(json.decode(str));

String loginUserModelToJson(LoginUserModel data) => json.encode(data.toJson());

class LoginUserModel {
  LoginUserModel({
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

  factory LoginUserModel.fromJson(Map<String, dynamic> json) => LoginUserModel(
    userInfo: json["userInfo"] == null ? null : UserInfo.fromJson(json["userInfo"]),
    documentTypes: json["documentTypes"] == null ? null : List<DocumentType>.from(json["documentTypes"].map((x) => DocumentType.fromJson(x))),
    domainDetails: json["domainDetails"] == null ? null : List<DomainDetail>.from(json["domainDetails"].map((x) => DomainDetail.fromJson(x))),
    warehouse: json["warehouse"] == null ? null : List<Warehouse>.from(json["warehouse"].map((x) => Warehouse.fromJson(x))),
    currentCompany: json["current_company"] == null ? null : CurrentCompany.fromJson(json["current_company"]),
    authorization: json["Authorization"] == null ? null : json["Authorization"],
    redirectUrl: json["redirectUrl"] == null ? null : json["redirectUrl"],
    emailDataPawan: json["emailDataPawan"] == null ? null : List<dynamic>.from(json["emailDataPawan"].map((x) => x)),
    logId: json["logId"] == null ? null : json["logId"],
    refUrl: json["ref_url"] == null ? null : json["ref_url"],
    employeeAppUrl: json["employee_app_url"],
  );

  Map<String, dynamic> toJson() => {
    "userInfo": userInfo == null ? null : userInfo?.toJson(),
    "documentTypes": documentTypes == null ? null : List<dynamic>.from(documentTypes!.map((x) => x.toJson())),
    "domainDetails": domainDetails == null ? null : List<dynamic>.from(domainDetails!.map((x) => x.toJson())),
    "warehouse": warehouse == null ? null : List<dynamic>.from(warehouse!.map((x) => x.toJson())),
    "current_company": currentCompany == null ? null : currentCompany?.toJson(),
    "Authorization": authorization == null ? null : authorization,
    "redirectUrl": redirectUrl == null ? null : redirectUrl,
    "emailDataPawan": emailDataPawan == null ? null : List<dynamic>.from(emailDataPawan!.map((x) => x)),
    "logId": logId == null ? null : logId,
    "ref_url": refUrl == null ? null : refUrl,
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
  var pensionfundsumEnasarco;
  int? sdiAuthId;
  var code;

  factory CurrentCompany.fromJson(Map<String, dynamic> json) => CurrentCompany(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    subtitle: json["subtitle"] == null ? null : json["subtitle"],
    vat: json["vat"] == null ? null : json["vat"],
    companyNumber: json["company_number"] == null ? null : json["company_number"],
    website: json["website"] == null ? null : json["website"],
    businessSector: json["business_sector"] == null ? null : json["business_sector"],
    owner: json["owner"] == null ? null : json["owner"],
    multiWarehouse: json["multi_warehouse"] == null ? null : json["multi_warehouse"],
    created: json["created"] == null ? null : DateTime.parse(json["created"]),
    logoUri: json["logo_uri"] == null ? null : json["logo_uri"],
    withholding: json["withholding"] == null ? null : json["withholding"],
    withholdingOn: json["withholding_on"] == null ? null : json["withholding_on"],
    contributionText: json["contribution_text"] == null ? null : json["contribution_text"],
    contributionRate: json["contribution_rate"] == null ? null : json["contribution_rate"],
    contributionWithholding: json["contribution_withholding"] == null ? null : json["contribution_withholding"],
    taxRegime: json["tax_regime"],
    pensionFund: json["pension_fund"] == null ? null : json["pension_fund"],
    fiscalCode: json["fiscal_code"],
    isDelete: json["is_delete"] == null ? null : json["is_delete"],
    witholdingTaxVisibility: json["witholding_tax_visibility"] == null ? null : json["witholding_tax_visibility"],
    isProfessionalDocument: json["is_professional_document"] == null ? null : json["is_professional_document"],
    defaultNumeration: json["default_numeration"] == null ? null : json["default_numeration"],
    lastTypeOfDocumentLoadedId: json["last_type_of_document_loaded_id"] == null ? null : json["last_type_of_document_loaded_id"],
    companyPa: json["company_pa"] == null ? null : json["company_pa"],
    description: json["Description"] == null ? null : json["Description"],
    sdiEconding: json["sdi_econding"] == null ? null : json["sdi_econding"],
    pensionfundsumEnasarco: json["pensionfundsum_enasarco"] == null ? null : json["pensionfundsum_enasarco"],
    sdiAuthId: json["sdi_auth_id"] == null ? null : json["sdi_auth_id"],
    code: json["code"] == null ? "" : json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "first_name": firstName,
    "last_name": lastName,
    "subtitle": subtitle == null ? null : subtitle,
    "vat": vat == null ? null : vat,
    "company_number": companyNumber == null ? null : companyNumber,
    "website": website == null ? null : website,
    "business_sector": businessSector == null ? null : businessSector,
    "owner": owner == null ? null : owner,
    "multi_warehouse": multiWarehouse == null ? null : multiWarehouse,
    "created": created == null ? null : created?.toIso8601String(),
    "logo_uri": logoUri == null ? null : logoUri,
    "withholding": withholding == null ? null : withholding,
    "withholding_on": withholdingOn == null ? null : withholdingOn,
    "contribution_text": contributionText == null ? null : contributionText,
    "contribution_rate": contributionRate == null ? null : contributionRate,
    "contribution_withholding": contributionWithholding == null ? null : contributionWithholding,
    "tax_regime": taxRegime,
    "pension_fund": pensionFund == null ? null : pensionFund,
    "fiscal_code": fiscalCode,
    "is_delete": isDelete == null ? null : isDelete,
    "witholding_tax_visibility": witholdingTaxVisibility == null ? null : witholdingTaxVisibility,
    "is_professional_document": isProfessionalDocument == null ? null : isProfessionalDocument,
    "default_numeration": defaultNumeration == null ? null : defaultNumeration,
    "last_type_of_document_loaded_id": lastTypeOfDocumentLoadedId == null ? null : lastTypeOfDocumentLoadedId,
    "company_pa": companyPa == null ? null : companyPa,
    "Description": description == null ? null : description,
    "sdi_econding": sdiEconding == null ? null : sdiEconding,
    "pensionfundsum_enasarco": pensionfundsumEnasarco == null ? null : pensionfundsumEnasarco,
    "sdi_auth_id": sdiAuthId == null ? null : sdiAuthId,
    "code": code == null ? null : code,
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
  String? soggettoEmittente;
  String? text;

  factory DocumentType.fromJson(Map<String, dynamic> json) => DocumentType(
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
    text: json["text"] == null ? null : json["text"],
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
    "text": text == null ? null : text,
  };
}

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
    id: json["id"] == null ? null : json["id"],
    domainId: json["domain_id"] == null ? null : json["domain_id"],
    name: json["name"] == null ? null : json["name"],
    value: json["value"] == null ? null : json["value"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "domain_id": domainId == null ? null : domainId,
    "name": name == null ? null : name,
    "value": value == null ? null : value,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

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
    id: json["id"] == null ? null : json["id"],
    firstName: json["first_name"] == null ? null : json["first_name"],
    lastName: json["last_name"] == null ? null : json["last_name"],
    email: json["email"] == null ? null : json["email"],
    profileStatus: json["profile_status"],
    thumbPath: json["thumbPath"] == null ? null : json["thumbPath"],
    domainId: json["domain_id"] == null ? null : json["domain_id"],
    activeLang: json["active_lang"] == null ? null : json["active_lang"],
    userTypeSlug: json["user_type_slug"] == null ? null : json["user_type_slug"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "first_name": firstName == null ? null : firstName,
    "last_name": lastName == null ? null : lastName,
    "email": email == null ? null : email,
    "profile_status": profileStatus,
    "thumbPath": thumbPath == null ? null : thumbPath,
    "domain_id": domainId == null ? null : domainId,
    "active_lang": activeLang == null ? null : activeLang,
    "user_type_slug": userTypeSlug == null ? null : userTypeSlug,
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
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    isDefault: json["is_default"] == null ? null : json["is_default"],
    isDelete: json["is_delete"] == null ? null : json["is_delete"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "is_default": isDefault == null ? null : isDefault,
    "is_delete": isDelete == null ? null : isDelete,
  };
}