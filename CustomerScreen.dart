import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paciolo/innerscreens/CustomerSearchScreen.dart';

import '../innerscreens/CreateCustomerScreen.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(AllColors.colorBlue),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.CUSTOMER_TITLE : IT.CUSTOMER_TITLE,
          style: gothamMedium.copyWith(
              color: Colors.white,
              fontSize: Dimensions.FONT_L
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const CreateCustomerScreen();
              },));
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // customer view
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CustomerSearchScreen(customerType: 1,);
                  },
                ));
              },
              child: Container(
                height: 65.h,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(AllColors.colorBlue),
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.5,
                          color: const Color(AllColors.colorDarkBlue),
                        )
                      ),
                      child: Text(
                        "C",
                        style: gothamRegular.copyWith(
                          fontSize: Dimensions.FONT_XL,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.PADDING_L.h,),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.CUSTOMER_PAGE_FILTER_1 : IT.CUSTOMER_PAGE_FILTER_1,
                      style: gothamRegular.copyWith(
                        color: const Color(AllColors.colorText),
                        letterSpacing: 0.5,
                        fontSize: Dimensions.FONT_XL.sp,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Color(AllColors.colorText),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black54,),
            // supplier view
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CustomerSearchScreen(customerType: 2,);
                  },
                ));
              },
              child: Container(
                height: 65.h,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: const Color(AllColors.colorBlue),
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1.5,
                            color: const Color(AllColors.colorDarkBlue),
                          )
                      ),
                      child: Text(
                        "S",
                        style: gothamRegular.copyWith(
                          fontSize: Dimensions.FONT_XL,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.PADDING_L.h,),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.CUSTOMER_PAGE_FILTER_2 : IT.CUSTOMER_PAGE_FILTER_2,
                      style: gothamRegular.copyWith(
                        color: const Color(AllColors.colorText),
                        letterSpacing: 0.5,
                        fontSize: Dimensions.FONT_XL.sp,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Color(AllColors.colorText),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black54,),
            // both view
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CustomerSearchScreen(customerType: 3,);
                  },
                ));
              },
              child: Container(
                height: 65.h,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: const Color(AllColors.colorBlue),
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1.5,
                            color: const Color(AllColors.colorDarkBlue),
                          )
                      ),
                      child: Text(
                        "B",
                        style: gothamRegular.copyWith(
                          fontSize: Dimensions.FONT_XL,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.PADDING_L.h,),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.CUSTOMER_PAGE_FILTER_3 : IT.CUSTOMER_PAGE_FILTER_3,
                      style: gothamRegular.copyWith(
                          color: const Color(AllColors.colorText),
                          letterSpacing: 0.5,
                          fontSize: Dimensions.FONT_XL.sp,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Color(AllColors.colorText),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black54,),
          ],
        ),
      ),
    );
  }
}
