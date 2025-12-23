import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_loading.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';
import '../../../main.dart';
import '../../../services/apimethod.dart';

import '../../../utils/component/component_appbar.dart';
import 'otpPageMobile.dart';

class RegisterGrupPageMobile extends StatefulWidget {
  RegisterGrupPageMobile({super.key});

  @override
  State<RegisterGrupPageMobile> createState() => _RegisterGrupPageMobileState();
}

class _RegisterGrupPageMobileState extends State<RegisterGrupPageMobile> {
  var phoneController = TextEditingController();
  var nameController = TextEditingController();
  var emailController = TextEditingController();

  Color onOffButton = bnw300;
  bool bttnValidate = false;

  refreshData() {
    if (phoneController.text.isNotEmpty &&
        nameController.text.isNotEmpty) {
      bttnValidate = true;
    } else {
      bttnValidate = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: bnw100,

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size32),
          child: Column(
            children: [
              appbar(context, false),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Sebagai Pemilik Toko',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Isikan data anda dengan lengkap',
                        style: heading3(FontWeight.w500, bnw500, 'Outfit'),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Nama Lengkap ',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          Text(
                            '*',
                            style: heading4(FontWeight.w700, red500, 'Outfit'),
                          ),
                        ],
                      ),
                      fieldMethod(
                        'Cth : Muhammad Nabil Musyaffa',
                        nameController,
                      ),
                      SizedBox(height: size16),
                      Row(
                        children: [
                          Text(
                            'Nomor Telepon ',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          Text(
                            '*',
                            style: heading4(FontWeight.w700, red500, 'Outfit'),
                          ),
                        ],
                      ),
                      fieldMethodPhone('08123456789', phoneController),
                      SizedBox(height: size16),
                      Text(
                        'Email ',
                        style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                      ),
                      fieldMethod('Cth: nabil@gmail.com', emailController),
                    ],
                  ),
                ),
              ),
              bttnValidate
                  ? Column(
                      children: [
                        SizedBox(height: size48),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: GestureDetector(
                            onTap: () => register(
                              context,
                              OtpPageMobile(
                                phone: phoneController.text,
                                name: nameController.text,
                                email: emailController.text,
                                pageidentify: 'register_page',
                              ),
                            ),
                            child: buttonXXLonOff(
                              Center(
                                child: Text(
                                  'Daftar',
                                  style: heading2(
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
                                ),
                              ),
                              double.infinity,
                              onOffButton,
                            ),
                          ),
                        ),
                        SizedBox(height: size32),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox fieldMethod(String text, mycontroller) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
        onChanged: (value) {
          setState(() {
            refreshData();
            if (value.contains('@') || value.endsWith('.com')) {
              onOffButton = primary500;
            } else if (value.startsWith('08') || value.length < 10) {
              onOffButton = primary500;
            }
          });
        },
        controller: mycontroller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: size12),
          hintText: text,
          hintStyle: heading2(FontWeight.w600, bnw400, 'Outfit'),
          errorStyle: body1(FontWeight.w500, red500, 'Outfit'),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 2, color: primary500),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 1, color: bnw400),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 2, color: red500),
          ),
        ),
      ),
    );
  }

  fieldMethodPhone(String text, mycontroller) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            if (value.contains('@') || value.endsWith('.com')) {
              onOffButton = primary500;
            } else if (value.startsWith('08') || value.length < 10) {
              onOffButton = primary500;
            }
          });
        },
        controller: mycontroller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: size12),
          hintText: text,
          hintStyle: heading2(FontWeight.w600, bnw400, 'Outfit'),
          errorStyle: body1(FontWeight.w500, red500, 'Outfit'),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 2, color: primary500),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 1, color: bnw400),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 2, color: red500),
          ),
        ),
      ),
    );
  }

  Future register(context, page) async {
    whenLoading(context);
    try {
      final response = await http.post(
        Uri.parse(registerLink),
        body: {
          'deviceid': identifier,
          'fullname': nameController.text,
          'phonenumber': phoneController.text,
          'email': emailController.text,
          'type': "Group_Merchant", //Group_Merchant
          // 'password': passController.text,
        },
      );
      var jsonResponse = jsonDecode(response.body);

      print('response body ${response.body}');
      if (response.statusCode == 200) {
        closeLoading(context);
        // log(jsonResponse['data']);
        print("succes");
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      } else {
        closeLoading(context);
        showSnackbar(context, jsonResponse);
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
