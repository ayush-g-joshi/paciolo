
class Constant {

  static const String euroSign = "\u{20AC}";

  // static const String LANG = "EN";
  static const String LANG = "IT";

  static const String EN = "EN";
  static const String IT = "IT";

  static const String ANDROID = "android";
  static const String IOS = "ios";


  static const String GOOGLE_API_KEY = "7331701182-vv54aafi8dgkb74um2j5peguej60brmg.apps.googleusercontent.com";
  static const String GOOGLE_API_KEY_IOS = "7331701182-jngp6lql135k2p4dk3tj19ofc6rgmp3q.apps.googleusercontent.com";

  // local URL
  // static const String SERVER_URL = "http://192.168.1.28:3000/";
  // server URL
  static const String SERVER_URL = "https://devapi.paciolo.it/";
  static const String ORIGIN_URL = "http://dev.paciolo.com";
  static const String TERMS_URL = "https://www.paciolo.com/terms";
  static const String PRIVACY_URL = "https://www.paciolo.com/privacy";
  static const String GOOGLE = "GOOGLE";
  static const String FACEBOOK = "FACEBOOK";
  static const String STATUS = "success";
  static const String loginEmail = "login_email";
  static const String loginPassword = "login_password";
  static const String first_name = "first_name";
  static const String last_name = "last_name";
  static const String email = "email";
  static const String password = "password";
  static const String password_verify = "password_verify";
  static const String reminderEmail = "reminder_email";
  static const String firstName = "firstName";
  static const String lastName = "lastName";
  static const String id = "id";
  static const String idToken = "idToken";
  static const String name = "name";
  static const String photoUrl = "photoUrl";
  static const String provider = "provider";
  static const String msg = "msg";
  static const String loginSuccessData = "loginSuccessData";
  static const String data = "data";
  static const String list = "list";
  static const String total = "total";
  static const String total_paid = "total_paid";
  static const String total_give = "total_give";
  static const String documentList = "documentList";


  // shared pref keys
  static const String userObject = "userObject";
  static const String document = "document";
  static const String documentName = "documentName";

}

class RequestCmd {

  static const String notificationTokenUpdate = "mobile-device-token";

  static const String login = "auth/login";
  static const String register = "auth/register";
  static const String forgotPassword = "auth/forgot_password";
  static const String socialLogin = "auth/social-register-login";
  static const String companyAll = "company/all";
  static const String getYears = "document/get-years";
  static const String getPaymentData = "account/list";
  static const String getWalletData = "wallet/get-wallet-with-total";
  static const String setCompanyId = "company/set/";
  static const String getInvoiceData = "document/";
  static const String getInvoiceDocFilter = "document/getdocumentfilterlistwithoutfilter";
  static const String updateSelectedDocFilter = "document/docTypeVisited";
  static const String getCurrentCompany = "company/update/";
  static const String getInvoiceDocInfo = "document/";
  static const String checkAccessCreateCompany = "plan-subscription/check_access/company";
  static const String pensionFund = "pension_fund";
  static const String companyCombination = "company-option/get-combinations";
  static const String companyUpdate = "company/update/";
  static const String getNewsAlert = "news-alert/get-all-news-alert/";
  static const String insertCombination = "company-option/insert-combinations";
  static const String sdiEnable = "sdi/enable";
  static const String userUpdateEmail = "user/update_email_option";
  static const String deleteCompany = "company/";
  static const String companyADD = "company/add";

  static const String getAssociateSubject = "customer/customer-list-details/";
  static const String getAssociateDocument = "document/search_by_customer_with_details/";
  static const String getWalletList = "wallet/list";
  static const String getPaymentMode = "agent/popup";
  static const String getCustomerDocPreference = "custom_doc_pref/fetch";
  static const String saveRegistryPayment = "account/transaction-mobile";
  static const String getPaymentCategory = "payment-category";
  static const String getPaymentCategoryCost = "payment-category/cost";
  static const String savePaymentCategoryCost = "payment-category/save-payment-mobile";
  static const String savePaymentTransfer = "account/transfer-mobile";
  static const String checkCustomerSubscription = "plan-subscription/check_access/customers";
  static const String getCustomerList = "customer/";
  static const String getCustomerById = "customer/";
  static const String getTotalInvoiceAmount = "warehouse_timeline/invoice_amounts";
  static const String getTotalDocumentInvoiceAmount = "warehouse_timeline/total_rem_document";
  static const String getUnPaidInvoiceList = "timeline/customer-document-data";
  static const String getCustomerPriceList = "customer/tarif/list";
  static const String deleteCustomer = "customer/";
  static const String editCustomer = "customer/edit-customer-mobile/";
  static const String saveCustomer = "customer/save-customer-mobile";
  static const String getAllInvoiceAmountMonthWise = "warehouse_timeline/invoice_amounts";
  static const String getDocumentVats = "vats";
  static const String getWithHoldings = "helper/with_holding";
  static const String getDocumentTypes = "document/types";
  static const String getDocumentNumber = "document/get-document-number";
  static const String getProductList = "product/get-products";
  static const String getMeasureUnit = "product/measure_unit";

  static const String getPaymentModeType = "payment/modes";
  static const String getPaymentMethodType = "payment/types";
  static const String saveDocument = "document/Fattura/save";

  static const String getWithHoldingTypes = "document/get-withholding-types";
  static const String getProductFilters = "product/get-product-custom-filter";

  static const String getPaymentExtraCost = "account/transaction-extra-cost";
  static const String getPositivePayment = "account/transaction";
  static const String getDocumentByCustomer = "document/search_by_customer";

  static const String deletePayment = "document/delete-payment";
  static const String deleteExtraCost = "payment-category/delete-extracost-payment";
  static const String deleteInvoice = "document/unlink";
  static const String getWalletById = "wallet";
  static const String getDocumentDetail = "document/";
  static const String saveCustomerCreateInvoice = "customer";

}

class AllColors {

  static const int colorDarkBlue = 0xFF0F699A;
  static const int colorBlue = 0xFF1383C0;
  static const int colorLightBlue = 0xFF2F9BC3;
  static const int colorRed = 0xFFFF4000;
  static const int colorGreen = 0xFF339966;
  static const int colorGrey = 0xFF949494;
  static const int colorBalanceRed = 0xFFE54355;
  static const int colorSubTotalOrange = 0xFFFF8959;
  static const int colorTotalBackGrey = 0xFFE3E3E3;
  static const int colorNoResult = 0xFF293E56;
  static const int colorLightGrey = 0xFFE4E4E4;
  static const int colorBorderLight = 0xFFF1F1F1;

  static const int colorText = 0xFF4b4b4b;
  static const int colorTextBalance = 0xFF212121;
  static const int colorBackBalance = 0xFFEBEBF5;

  static const int colorInvoicePayment = 0xFFF5F7FC;
  static const int color = 0xFF707070;
  static const int colorTabs = 0xFFBBBBBB;
  static const int colorListBack = 0xFFF4F4F4;
  static const int colorPink = 0xFFD900D9;
  static const int colorDocumentText = 0xFFbdc6cf;

  static const int swipeDelete = 0xffEF4035;
}