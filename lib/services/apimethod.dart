import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:amio/main.dart';
import 'package:amio/models/diskonModel.dart';
import 'package:amio/models/lihatakunmodel.dart';
import 'package:amio/models/produkmodel.dart';
import 'package:amio/models/tokoModel/calculateCart.dart';
import 'package:amio/models/tokoModel/riwayatTransaksiTokoModel.dart';
import 'package:amio/models/tokoModel/singletokomodel.dart';
import 'package:amio/models/tokoModel/tokomodel.dart';
import 'package:amio/models/tokoModel/transaksiTokoModel.dart';
import 'package:amio/pagehelper/loginregis/lupaSandiPage/buat_sandi_baru.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chartModelData.dart';
import '../models/dashboardItemModel.dart';
import '../models/dropdowntokomodel.dart';
import '../models/pelangganDataModel.dart';
import '../models/promosiModel.dart';
import '../models/tokoModel/keuanganModel.dart';
import '../models/tokoModel/rekonModel.dart';
import '../models/tokoModel/singleRiwayatModel.dart';
import '../models/tokomodel.dart';
import '../pageTablet/home/sidebar/profile_page.dart';
import '../pageTablet/tokopage/dashboardtoko.dart';
import '../pageTablet/tokopage/sidebar/transaksiToko/transaksi.dart';
import '../utils/component.dart';
import '../utils/providerModel/refreshTampilanModel.dart';

String url = 'https://api.prod.amio.my.id';
// String url =
// 'https://0e15-2001-448a-2011-3535-9503-78da-1cfb-3a79.ngrok-free.app';

String registerbyotp = '$url/api/user/registerbyotp',
    registerentryotp = '$url/api/register/verify',
    registerLink = '$url/api/register',
    loginEmailLink = '$url/api/login',
    loginbyotp = '$url/api/user/loginbyotp',
    loginentryotp = '$url/api/user/loginentryotp',
    checkpass = '$url/api/user/checkPassword',
    forgotPassRequestLink = '$url/api/forgot-password/request',
    forgotPassRequestOtpLink = '$url/api/forgot-password/request/otp',
    forgotPassVerifyLink = '$url/api/forgot-password/verify',
    forgotPassChangeLink = '$url/api/forgot-password/change',
    myaccout = '$url/api/profile/myaccount',
    dashboardNumber = '$url/api/user/dashboardNumber',
    dashboardChart = '$url/api/user/dashboardChart',
    createMerchan = '$url/api/merchant/create',
    createProdukUrl = '$url/api/product/create',
    createVoucherUrl = '$url/api/voucher/create',
    updateVoucherUrl = '$url/api/voucher/update',
    approveTransaksiUrl = '$url/api/transaction/approve/reference',
    createTransaksiUrl = '$url/api/transaction/create',
    deleteTransaksiUrl = '$url/api/transaction/delete',
    headerTagihanUrl = '$url/api/transaction/create/reference/tagihan',
    deleteTagihanUrl = '$url/api/transaction/delete/reference/tagihan',
    getTransaksiRiwayatUrl = '$url/api/transaction/',
    getPendapatanUrl = '$url/api/ppm/get',
    getRekonUrl = '$url/api/rekon/',
    saveRekonUrl = '$url/api/rekon/save',
    postingRekonUrl = '$url/api/rekon/posting',
    getYearRekonUrl = '$url/api/rekon/year',
    getMonthRekonUrl = '$url/api/rekon/month',
    getTransaksiSingleRiwayatUrl = '$url/api/transaction/receipt',
    calculateTransaksiUrl = '$url/api/transaction/calculating',
    updateAkunUrl = '$url/api/user/update',
    deleteAkunUrl = '$url/api/user/delete',
    deleteMerchan = '$url/api/merchant/delete',
    deleteProdukUrl = '$url/api/product/delete',
    deletePelangganUrl = '$url/api/member/delete',
    createPelangganUrl = '$url/api/member/create',
    createPemasukanUrl = '$url/api/ppm/create',
    ubahPemasukanUrl = '$url/api/ppm/update',
    editPelangganUrl = '$url/api/member/edit',
    changeProfileName = '$url/api/profile/change',
    changeImage = '$url/api/profile/upload/image',
    changeProfilePhone = '$url/api/profile/changephonenumber',
    changeProfilePhoneOtp = '$url/api/profile/changenumberentryotp',
    getMerch = '$url/api/merchant',
    getSingleProductUrl = '$url/api/product/single',
    getSinglePromosiUrl = '$url/api/voucher/single',
    getSingleAkunUrl = '$url/api/user/single',
    getProductUrl = '$url/api/product',
    getVoucherUrl = '$url/api/voucher',
    getPelanggantUrl = '$url/api/member/',
    getAllAkun = '$url/api/merchant/account',
    getSingleMerchant = '$url/api/merchant/single',
    checkEmailVerified = '$url/api/user/isEmailVerified',
    verifiedEmailLink = '$url/api/user/email/verfied',
    verifiedEmailOtpLink = '$url/api/user/email/verfied/otp',
    registerGlobalMerchbyOtp = '$url/api/register/single',
    registerGlobalMerchEntry = '$url/api/register/single/entry',
    updateMerchant = '$url/api/merchant/update',
    updateProdukUrl = '$url/api/product/update',
    changeActiveUrl = '$url/api/product/changeActive',
    changePpnUrl = '$url/api/product/changePPN',
    changeActiveAkunUrl = '$url/api/user/changeStatus',
    laporanDailyUrl = '$url/api/report/income/daily',
    laporanMerchUrl = '$url/api/report/income/merchant',
    laporanProdukUrl = '$url/api/report/income/product',
    transaksiViewReferenceLink = '$url/api/transaction/view/reference',
    uploadQrisLink = '$url/api/merchant/qris/save',
    deleteQrisLink = '$url/api/merchant/qris/delete',
    getQrisLink = '$url/api/merchant/qris/view',
    getStrukLink = '$url/api/merchant/struk/view',
    uploadStrukLink = '$url/api/merchant/struk/save',
    deleteStrukLink = '$url/api/merchant/struk/delete',
    getOtpSandiLink = '$url/api/user/password/otp',
    validasiOtpSandiLink = '$url/api/user/password/otp/verified',
    changeSandiLink = '$url/api/user/password/change',
    valOtpEmailLink = '$url/api/user/email/otp',
    valOtpEmailTahap1Link = '$url/api/user/email/otp/verified',
    changeEmailLink = '$url/api/user/email/change',
    changeEmailTahap2Link = '$url/api/user/email/change/verified',
    tambahKategoriLink = '$url/api/typeproduct/store',
    ubahKategoriLink = '$url/api/typeproduct/update',
    hapusKategoriLink = '$url/api/typeproduct/delete',
    tipeUsaha = '$url/api/tipeusaha',
    diskonLink = '$url/api/discount',
    createDiskonLink = '$url/api/discount/store',
    deleteDiskonLink = '$url/api/discount/delete',
    updateDiskonLink = '$url/api/discount/update',
    getSingleDiskonLink = '$url/api/discount/show',
    getProdukDiskonLink = '$url/api/discount/get-products',
    aktifDiskonLink = '$url/api/discount/change-is-active',
    diskonTransaksiLink = '$url/api/discount/transaction';

String out = '$url/api/logout';
String firebaseTokenUrl = '$url/api/user/update/firebasetoken';

const background = Color(0xFF1363DF);
const primaryColor = Color(0xFF1363DF);
const canvasColor = Colors.white;

const scaffoldBackgroundColor = Color(0xFFF5F5F5);
// const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;

final divider = Divider(
  color: bnw100,
  thickness: 8,
);

Future firebaseToken(tokenFirebase, token) async {
  try {
    var response = await Dio().post(
      firebaseTokenUrl,
      data: {
        'deviceid': identifier,
        'token': tokenFirebase,
      },
      options: Options(
        headers: {
          "token": "$token",
        },
      ),
    );

    if (response.statusCode == 200) {
      print('berhasil mengupload firebase token');
    } else {
      print('gagal mengupload firebase token');
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future logout(token, id, context, page) async {
  try {
    final response = await http.post(
      Uri.parse(changeProfileName),
      body: {
        'deviceid': identifier,
      },
      headers: {
        'token': token,
      },
    );
    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("succes aman tentram logout");
      // print(response.data['token']);

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => page,
      //   ),
      // );
    } else {}
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

//* profile *//
var nameProfile,
    nameToko,
    statusProfile,
    emailProfile,
    phoneProfile,
    imageProfile;

Future myprofile(token) async {
  try {
    var response = await Dio().post(
      myaccout,
      data: {
        'deviceid': identifier,
      },
      options: Options(
        headers: {
          "token": token,
        },
      ),
    );

    if (response.statusCode == 200) {
      print("succes aman tentram di profile");
      var responseValue = response.data['data'];

      print(responseValue);
      nameProfile = responseValue['fullname'];
      nameToko = responseValue['nama_toko'];
      statusProfile = responseValue['usertype'];
      emailProfile = responseValue['email'];
      phoneProfile = responseValue['phonenumber'];
      imageProfile = responseValue['account_image'];
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future tambahKategoriForm(context, name, token) async {
  try {
    final response = await http.post(
      Uri.parse(tambahKategoriLink),
      body: {
        'name': name,
      },
      headers: {
        'token': token,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(response.body.toString());
    if (response.statusCode == 200) {
      print("succes tambah kategori");
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future hapusKategoriForm(context, token, idkategori) async {
  try {
    final response = await http.post(
      Uri.parse(hapusKategoriLink),
      body: {
        'id': idkategori,
      },
      headers: {
        'token': token,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(response.body.toString());
    if (response.statusCode == 200) {
      print("succes hapus kategori");

      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future ubahKategoriForm(context, token, idkategori, name) async {
  try {
    final response = await http.post(
      Uri.parse(ubahKategoriLink),
      body: {
        'id': idkategori,
        'name': name,
      },
      headers: {
        'token': token,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    // log(response.body.toString());
    if (response.statusCode == 200) {
      print("succes hapus kategori");

      closeLoading(context);

      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future changeName(token, id, context, mycontroller) async {
  try {
    final response = await http.post(
      Uri.parse(changeProfileName),
      body: {
        'fullname': mycontroller,
        'deviceid': id.toString(),
      },
      headers: {
        'token': token,
      },
    );
    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("succes aman tentram");

      Navigator.pop(context);
      showSnackbar(context, jsonResponse);
    } else {
      showSnackbar(context, jsonResponse);
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

String userPhone = '', userEmail = '', userId = '';
Future changePasswordRequest(context, type, id) async {
  whenLoading(context);
  try {
    final response = await http.post(
      Uri.parse(forgotPassRequestLink),
      body: {
        'type': type,
        'identifier': id,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      userPhone = jsonResponse['user']['phonenumber'];
      userEmail = jsonResponse['user']['email'];
      userId = jsonResponse['data']['id'];
      errorText = '';
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      errorText = '';
      showSnackbar(context, jsonResponse);
      errorText = jsonResponse['message'];
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future changePasswordRequestOtp(context, type, id) async {
  try {
    final response = await http.post(
      Uri.parse(forgotPassRequestOtpLink),
      body: {
        'type': type,
        'id': id,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    // log(jsonResponse.toString());
    if (response.statusCode == 200) {
      errorText = '';
      // closeLoading(context);
      // showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      errorText = '';
      // closeLoading(context);
      // showSnackbar(context, jsonResponse);
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future changePasswordVerify(context, id, otp) async {
  try {
    final response = await http.post(
      Uri.parse(forgotPassVerifyLink),
      body: {
        'id': id,
        'otp': otp,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      errorText = '';
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BuatSandiBaruPage(userid: id),
          ));
      return jsonResponse['rc'];
    } else {
      errorText = jsonResponse['message'];
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future changePasswordChange(context, id, pass, conPass) async {
  try {
    whenLoading(context);
    final response = await http.post(
      Uri.parse(forgotPassChangeLink),
      body: {
        'id': id,
        'passsword': pass,
        'password_confirmation': conPass,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      errorText = '';
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      // errorText = jsonResponse['message'];
      closeLoading(context);
      showSnackbar(context, jsonResponse);
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future changePhoneByOtp(token, context, mycontroller, password) async {
  try {
    var response = await Dio().post(
      changeProfilePhone,
      data: {
        "deviceid": identifier,
        "phonenumber": mycontroller,
        "password": password,
      },
      options: Options(
        headers: {
          "token": "$token",
        },
      ),
    );

    if (response.statusCode == 200) {
      print("succes aman tentram");
      print(response.data);

      Navigator.pop(context);
    } else {
      print(response.data['message']);
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future changePhoneEntryOtp(token, id, context, fieldController, pin) async {
  try {
    var response = await Dio().post(
      changeProfilePhoneOtp,
      data: {
        'phonenumber': fieldController.text,
        'otp': pin,
        'deviceid': id.toString(),
      },
      options: Options(
        headers: {
          "token": "$token",
        },
      ),
    );

    if (response.statusCode == 200) {
      print("succes aman tentram");

      Navigator.pop(context);
    } else {}
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

int? getAllMerch;

Future<List?> getMerchant(token, id, context) async {
  try {
    var response = await Dio().post(
      getMerch,
      data: {
        'deviceid': id.toString(),
      },
      options: Options(
        headers: {
          "token": "$token",
        },
      ),
    );
    int? responseLength = response.data?.length;
    getAllMerch = responseLength;

    if (response.statusCode == 200) {
      print("succes aman tentram di toko");

      // print(categoriesList);
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

int emailChecker = 0;
var statusVerified, statusPw;
Future checkEmail(token, setState) async {
  try {
    var response = await Dio().post(
      checkEmailVerified,
      data: {
        'email': emailProfile,
        'deviceid': identifier,
      },
      options: Options(
        headers: {
          "token": "$token",
        },
      ),
    );

    if (response.statusCode == 200) {
      print("succes aman tentram check email");

      statusVerified = response.data['data'].toString();
      statusPw = response.data['data'].toString();

      setState(() {});
    } else {}
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future valOtpEmail(context, token, typeotp) async {
  try {
    whenLoading(context);
    var response = await Dio().post(
      valOtpEmailLink,
      data: {
        'deviceid': identifier,
        'typeotp': typeotp,
      },
      options: Options(
        headers: {
          "token": token,
        },
      ),
    );

    if (response.statusCode == 200) {
      print("succes aman tentram kirim otp : $typeotp");
      closeLoading(context);
      print(response.data["data"]);
    } else {
      closeLoading(context);
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future valOtpEmailtahap1(context, token, typeotp, otp) async {
  var response = await http.post(
    Uri.parse(valOtpEmailTahap1Link),
    body: {
      'deviceid': identifier,
      'otp': otp,
      'typeotp': typeotp,
    },
    headers: {
      "token": token,
    },
  );
  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print("succes aman tentram validasi otp : $typeotp");

    print(jsonResponse['data']);
  } else {
    // showSnackbar(context, jsonResponse);
    errorText = jsonResponse['message'];
  }
  return jsonResponse['rc'];
}

Future changeEmail(context, token, email, typeotp) async {
  try {
    var response = await Dio().post(
      changeEmailLink,
      data: {
        "deviceid": identifier,
        "email": email,
        "typeotp": typeotp,
      },
      options: Options(
        headers: {
          "token": "$token",
        },
      ),
    );
    print(email);
    print(response.data["data"]);
    if (response.statusCode == 200) {
    } else {}
    return response.data['rc'];
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future changeEmailtahap2(context, token, typeotp, otp) async {
  var response = await http.post(
    Uri.parse(changeEmailTahap2Link),
    body: {
      'deviceid': identifier,
      'otp': otp,
      'typeotp': typeotp,
    },
    headers: {
      "token": token,
    },
  );
  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print(jsonResponse['data']);
    Navigator.pop(context);
    Navigator.pop(context);
    showSnackbar(context, jsonResponse);
  } else {
    // showSnackbar(context, jsonResponse);
    errorText = jsonResponse['message'];
  }
  return jsonResponse['rc'];
}

Future changePhoto(token, id, context, imageCon, reload) async {
  try {
    var response = await Dio().post(
      changeImage,
      data: {
        'deviceid': id.toString(),
        'image': "data:image/png;base64," + imageCon.toString(),
      },
      options: Options(
        headers: {
          "token": "$token",
        },
      ),
    );

    if (response.statusCode == 200) {
      print("succes aman tentram upload image");
      print(response.data);
      // myprofile(token);
      Navigator.pop(context);
      showSnackbar(context, response.data);
    } else {}
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future getAllToko(context, token, name, orderby) async {
  final response = await http.post(
    Uri.parse(getMerch),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "name": name,
      "address": "",
      "orderby": orderby,
    },
  );

  if (response.statusCode == 200) {
    print('succes');

    final List<ModelDataToko> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = ModelDataToko.fromJson(item);
      result.add(model);

      // print(model.toJson());
    }

    return result;
  }
}

Future<TokoModelToko> getToko(token) async {
  final response = await http.post(
    Uri.parse(getMerch),
    // Uri.parse('$url/api/groupmerchant/user'),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
    },
  );

  if (response.statusCode == 200) {
    return TokoModelToko.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

Future getUserAkun(token, id, orderby) async {
  final response = await http.post(
    Uri.parse(getAllAkun),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": id,
      'orderby': orderby,
    },
  );

  if (response.statusCode == 200) {
    print('succes');

    final List<ModelDataAkun> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = ModelDataAkun.fromJson(item);
      result.add(model);

      // print(model.toJson());
    }

    return result;
  }
}

late String nameMerchantUbah,
    addressMerchantUbah,
    zipMerchantUbah,
    nameProvUbah,
    kodeProvUbah,
    nameregUbah,
    kodeRegUbah,
    nameDisUbah,
    kodeDisUbah,
    nameVillageUbah,
    kodeVillageUbah,
    zipcodeUbah,
    tipeUbah,
    idtipeUbah,
    imageEditToko;

Future getSingleMerch(context, token, String merchid) async {
  final response = await http.post(
    Uri.parse(getSingleMerchant),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  var data = jsonResponse['data'];
  log(data.toString());
  if (response.statusCode == 200) {
    nameMerchantUbah = data['name'];
    addressMerchantUbah = data['address'];
    zipMerchantUbah = data['zipcode'];
    nameProvUbah = data['nama_province'];
    kodeProvUbah = data['kode_province'];
    nameregUbah = data['nama_regencies'];
    kodeRegUbah = data['kode_regencies'];
    nameDisUbah = data['nama_district'];
    kodeDisUbah = data['kode_district'];
    nameVillageUbah = data['nama_village'];
    kodeVillageUbah = data['kode_village'];
    zipcodeUbah = data['zipcode'];
    tipeUbah = data['nama_tipe_usaha'] ?? '';
    idtipeUbah = data['tipeusaha'];
    imageEditToko = data['logomerchant_url'];

    return jsonResponse;
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future createMerch(
  context,
  token,
  String nameMerch,
  address,
  province,
  regencies,
  district,
  village,
  zipcode,
  image,
  PageController pageController,
  businesstype,
) async {
  try {
    final response = await http.post(
      Uri.parse(createMerchan),
      body: {
        "deviceid": identifier,
        "merchantid": "",
        "fullname": "",
        "userid": "",
        "usertype": "",
        "phonenumber": "",
        "email": "",
        "namemerchant": nameMerch,
        "address": address,
        "province": province,
        "regencies": regencies,
        "district": district,
        "village": village,
        "zipcode": zipcode,
        "businesstype": businesstype,
        "logomerchant_url": "data:image/png;base64,$image"
      },
      headers: {
        "token": "$token",
      },
    );
    // print(response.data['rc']);

    var jsonResponse = jsonDecode(response.body);
    // print(jsonResponse['rc']);

    if (response.statusCode == 200) {
      // print("succes aman tentram");
      // print(response.data['data']);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      showSnackbar(context, jsonResponse);
    }
    return jsonResponse['message'];
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future createAkun(
  context,
  token,
  String merchId,
  fullName,
  phoneNumber,
  email,
  nameMerchant,
  address,
  province,
  regencies,
  district,
  village,
  zipcode,
  String image,
  isactive,
) async {
  try {
    final response = await http.post(
      Uri.parse(createMerchan),
      body: {
        "deviceid": identifier,
        "merchantid": merchId,
        "fullname": fullName,
        "usertype": "Merchant",
        "role": "user",
        "phonenumber": phoneNumber,
        "email": email,
        "namemerchant": nameMerchant,
        "address": address,
        "province": province,
        "regencies": regencies,
        "district": district,
        "village": village,
        "zipcode": zipcode,
        "businesstype": "",
        "status": isactive,
        "image": "data:image/png;base64,$image"
      },
      headers: {
        "token": "$token",
      },
    );
    // print(response.data['rc']);

    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);

    if (response.statusCode == 200) {
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      showSnackbar(context, jsonResponse);
    }
    return jsonResponse['message'];
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future updateAkun(
  context,
  token,
  String userId,
  fullName,
  email,
  phonenumber,
  String image,
  isactive,
) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(updateAkunUrl),
    body: {
      "deviceid": identifier,
      "userid": userId,
      "fullname": fullName,
      "email": email,
      "phonenumber": phonenumber,
      "image": "data:image/png;base64,$image",
      "status": isactive,
    },
    headers: {
      "token": "$token",
    },
  );
  // print(response.data['rc']);

  var jsonResponse = jsonDecode(response.body);

  print(jsonResponse['data']);
  if (response.statusCode == 200) {
    print("succes aman tentram");
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
  return jsonResponse;
}

Future updateMerch(
  context,
  token,
  merchid,
  String nameMerch,
  address,
  province,
  regencies,
  district,
  village,
  zipcode,
  image,
  PageController pageController,
  type,
) async {
  try {
    final response = await http.post(
      Uri.parse(updateMerchant),
      body: {
        "deviceid": identifier,
        "merchantid": merchid,
        "name": nameMerch,
        "userid": "",
        "usertype": "",
        "phonenumber": "",
        "email": "",
        "namemerchant": nameMerch,
        "address": address,
        "province": province,
        "regencies": regencies,
        "district": district,
        "village": village,
        "zipcode": zipcode,
        "businesstype": type,
        "logomerchant_url": "data:image/png;base64,$image"
      },
      headers: {
        "token": "$token",
      },
    );
    // print(response.data['rc']);

    var jsonResponse = jsonDecode(response.body);
    // print(jsonResponse['rc']);

    if (response.statusCode == 200) {
      print("Succes Update Merchant");
      // print(response.data['data']);
      pageController.jumpTo(0);
      showSnackbar(context, jsonResponse);
    } else {
      showSnackbar(context, jsonResponse);
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future updateProduk(
    context,
    token,
    name,
    merchid,
    productid,
    typeproducts,
    price,
    onlinePrice,
    PageController pageController,
    isActive,
    isPPN,
    img) async {
  String imgFix = '';
  if (img == '') {
    imgFix = '';
  } else {
    imgFix = 'data:image/jpeg;base64,$img';
  }

  try {
    whenLoading(context);
    final response = await http.post(
      Uri.parse(updateProdukUrl),
      body: {
        "deviceid": identifier,
        "productid": productid,
        "name": name,
        "typeproducts": typeproducts,
        "merchantid": merchid,
        "price": price,
        "price_online_shop": onlinePrice,
        "isActive": isActive,
        "isPPN": isPPN,
        // "product_image": 'data:image/jpeg;base64,$img',
        "product_image": imgFix,
      },
      headers: {
        "token": "$token",
      },
    );

    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("succes aman tentram");
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      print(jsonResponse['data']);
      pageController.jumpTo(0);
    } else {
      closeLoading(context);
      print(jsonResponse['rc']);
      showSnackbar(context, jsonResponse);
    }
    return null;
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future deleteMerchant(
  BuildContext context,
  var token,
  List<String> merchid,
) async {
  whenLoading(context);
  final String jsonTest = json.encode(merchid);

  final response = await http.post(
    Uri.parse(deleteMerchan),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": jsonTest,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    errorText = jsonResponse['message'];
    Navigator.pop(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  }
}

Future deleteAkun(
  BuildContext context,
  token,
  List userid,
) async {
  whenLoading(context);
  final String jsonTest = json.encode(userid);

  final response = await http.post(
    Uri.parse(deleteAkunUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "userid": jsonTest,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print('Sukses Delete Data');
    print(jsonResponse['data'].toString());
    Navigator.pop(context);
    closeLoading(context);
    return jsonResponse['rc'];
  } else {
    print(jsonResponse['message'].toString());
    Navigator.pop(context);
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future deleteProduk(
  BuildContext context,
  var token,
  List productid,
  merchid,
) async {
  String jsonData = jsonEncode(productid);
  whenLoading(context);
  final response = await http.post(
    Uri.parse(deleteProdukUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      'productid': jsonData,
      // 'productid': jsonEncode(productid),
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    print('Sukses Delete Data');
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    // print(jsonResponse['data'].toString());
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    // print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future deletePelanggan(
  BuildContext context,
  var token,
  List memberid,
) async {
  var jsonData = jsonEncode(memberid);

  final response = await http.post(
    Uri.parse(deletePelangganUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "memberid": jsonData,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    Navigator.pop(context);
    showSnackbar(context, jsonResponse);
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future changeActiveAkun(
  BuildContext context,
  token,
  status,
  userid,
) async {
  whenLoading(context);
  final String jsonTest = json.encode(userid);
  final response = await http.put(
    Uri.parse('$url/api/user/changeStatus'),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "userid": jsonTest,
      "status": status,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('Sukses Ganti Keatifan');

    print(jsonResponse['data'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  } else {
    print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future changePpn(
  BuildContext context,
  var token,
  isPPN,
  List productid,
  merchid,
) async {
  whenLoading(context);
  String jsonData = jsonEncode(productid);

  final response = await http.post(
    Uri.parse(changePpnUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      "isPPN": isPPN,
      'productid': jsonData,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('Sukses Ganti Data');
    // Navigator.pop(context);

    print(jsonResponse['data'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  } else {
    print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future changeActive(
  BuildContext context,
  var token,
  isActive,
  List productid,
  merchid,
) async {
  whenLoading(context);
  String jsonData = jsonEncode(productid);

  final response = await http.post(
    Uri.parse(changeActiveUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      "isActive": isActive,
      'productid': jsonData,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    //print('Sukses Ganti Data');
    // Navigator.pop(context);

    //print(jsonResponse['data'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  } else {
    //print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future changeActiveDiskon(
  BuildContext context,
  var token,
  isActive,
  productid,
  merchid,
) async {
  whenLoading(context);
  String jsonData = jsonEncode(productid);

  final response = await http.post(
    Uri.parse(aktifDiskonLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      "is_active": isActive,
      // 'id': productid,
      'id': jsonData,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    //print('Sukses Ganti Data');
    // Navigator.pop(context);

    //print(jsonResponse['data'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  } else {
    //print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future getAllProvince(token, id) async {
  final response = await http.post(
    Uri.parse('$url/api/province'),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": id,
    },
  );

  if (response.statusCode == 200) {
    print('succes');

    final List<DataProvince> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = DataProvince.fromJson(item);
      result.add(model);

      print(model.toJson());
    }

    return result;
  }
}

Future getTipeUsaha(token, id) async {
  final response = await http.post(
    Uri.parse(tipeUsaha),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": id,
    },
  );

  if (response.statusCode == 200) {
    print('succes');

    final List<DataProvince> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = DataProvince.fromJson(item);
      result.add(model);

      print(model.toJson());
    }

    return result;
  }
}

Future verifiedEmail(context, token, emailCon, passCon) async {
  final response = await http.post(
    Uri.parse(verifiedEmailLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "email": emailCon,
      "password": passCon,
      "confirmPassword": passCon
    },
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print(jsonResponse.toString());
  } else {
    // showSnackbar(context, jsonResponse);
    return jsonResponse['message'];
  }

  return jsonResponse['rc'];
}

Future verifiedEmailbyOTP(context, token, otp) async {
  final response = await http.post(
    Uri.parse(verifiedEmailOtpLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "otp": otp,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    Navigator.of(context).pop();
    print("succes aman tentram verified email");
    // print(jsonResponse.toString());
    showSnackbar(context, jsonResponse);
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
  return jsonResponse['rc'];
}

Future changePassword(
    BuildContext context, token, newPass, conPass, typeotp) async {
  var response = await http.post(
    Uri.parse(changeSandiLink),
    headers: {
      "token": "$token",
    },
    body: {
      "deviceid": identifier,
      "typeotp": typeotp,
      "newPass": newPass,
      "confirmPass": conPass,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print(jsonResponse["data"]);
    Navigator.pop(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    // showSnackbar(context, jsonResponse);
  }
  return jsonResponse['message'];
}

int? pendapatanDas, membersDas, transaksiDas, rataTransaksiDas;
Future dashboard(id, token) async {
  try {
    var response = await Dio().post(
      dashboardNumber,
      // dashboardValue,
      data: {
        'deviceid': id.toString(),
      },
      options: Options(
        headers: {
          "token": token,
        },
      ),
    );

    if (response.statusCode == 200) {
      pendapatanDas = response.data['data']['income'];
      print("succes aman tentram di profile");

      var responseValue = response.data['data'];

      print(membersDas.toString());
      // pendapatanDas = responseValue['income'];
      membersDas = responseValue['members'];
      transaksiDas = responseValue['transaction'];
      rataTransaksiDas = responseValue['averageTransaction'];
    }
    return response.data['data'];
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<Map<String, dynamic>> dashboardSide(BuildContext context, token) async {
  final response = await http.post(
    Uri.parse(dashboardNumber),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
    },
  );

  var jsonResponseThrow = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('behasil get side');
    return json.decode(response.body);
  } else {
    // print(jsonResponse['message'].toString());
    throw Exception(jsonResponseThrow['message'].toString());
    // print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

Future<Map<String, dynamic>> getDataChart(BuildContext context, token) async {
  final response = await http.post(
    Uri.parse(dashboardChart),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "tipe": "1W",
    },
  );

  var jsonResponseThrow = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('behasil get chart');
    return json.decode(response.body);
  } else {
    // print(jsonResponse['message'].toString());
    throw Exception(jsonResponseThrow['message'].toString());
    // print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

Future getPelanggan(BuildContext context, token, orderby) async {
  final response = await http.post(
    Uri.parse(getPelanggantUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "orderby": orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes get pelanggan');
    var dataku = jsonResponse['data'];

    // namaPelangganEdit,
    // phonePelangganEdit,
    // emailPelangganEdit,
    // instagramPelangganEdit;

    print(dataku);

    final List<PelangganModelData> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = PelangganModelData.fromJson(item);
      result.add(model);

      // print(model.toJson());
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getVoucher(context, token, orderby, merchantid) async {
  final response = await http.post(
    Uri.parse(getVoucherUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      'orderby': orderby,
      'merchantid': merchantid
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    print(jsonResponse['data'].toString());

    final List<ModelDataPromosi> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = ModelDataPromosi.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse['message'].toString());
  }
}

Future getDiskon(context, token, merchantid, orderby) async {
  final response = await http.post(
    Uri.parse(diskonLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchantid,
      'orderby': orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    print(jsonResponse['data'].toString());

    final List<ModelDataDiskon> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = ModelDataDiskon.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse['message'].toString());
  }
}

Future tambahDiskon(
  BuildContext context,
  token,
  merchantid,
  productid,
  name,
  discount,
  discount_type,
  start_date,
  end_date,
  is_active,
  active_period,
) async {
  whenLoading(context);
  String productidList;
  if (productid == '') {
    productidList = '';
  } else {
    productidList = json.encode(productid);
  }
  final String merchantidList = json.encode(merchantid);
  final response = await http.post(
    Uri.parse(createDiskonLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      'merchantid': merchantidList,
      'productid': productidList,
      'name': name,
      'discount': discount,
      'discount_type': discount_type,
      'start_date': start_date,
      'end_date': end_date,
      'is_active': is_active,
      "active_period": active_period,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('Sukses Tambah Diskon $jsonResponse');

    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse['data'].toString());
    return jsonResponse['rc'];
  } else {
    print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  }
}

Future ubahDiskon(
  BuildContext context,
  token,
  diskonId,
  merchantid,
  productid,
  name,
  discount,
  discount_type,
  start_date,
  end_date,
  is_active,
  active_period,
) async {
  whenLoading(context);
  final String merchantidList = json.encode(merchantid);
  final String productidList = json.encode(productid);
  final response = await http.post(
    Uri.parse(updateDiskonLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      'id': diskonId,
      'merchantid': merchantidList,
      'productid': productidList,
      'name': name,
      'discount': discount,
      'discount_type': discount_type,
      'start_date': start_date,
      'end_date': end_date,
      'is_active': is_active,
      "active_period": active_period,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('Sukses Tambah Diskon $jsonResponse');
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse['data'].toString());
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  }
}

Future deleteDiskon(
  BuildContext context,
  token,
  id,
) async {
  whenLoading(context);
  final String productidList = json.encode(id);
  final response = await http.post(
    Uri.parse(deleteDiskonLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      'id': productidList,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('Sukses Delete Data');
    // Navigator.pop(context);
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse['data'].toString());
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getProduct(BuildContext context, token, String name,
    List<String> merchid, orderby) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(getProductUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": jsonTest,
      "name": name,
      "orderby": orderby,
      "isActive": "false",
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    // print(jsonResponse.toString());

    final List<ModelDataProduk> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = ModelDataProduk.fromJson(item);
      result.add(model);

      // print(model.toJson());
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

Future getProductGrup(
    BuildContext context, token, String name, merchid, orderby) async {
  final response = await http.post(
    Uri.parse(getProductUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      "name": name,
      "orderby": orderby,
      // "isActive": "false",
    },
  );

  var jsonResponse = jsonDecode(response.body);
  print(jsonResponse);
  if (response.statusCode == 200) {
    print('succes');

    // print(jsonResponse.toString());

    final List<ModelDataProdukGrup> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = ModelDataProdukGrup.fromJson(item);
      result.add(model);

      // print(model.toJson());
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future createPelanggan(
  BuildContext context,
  token,
  String name,
  address,
  String phone,
  email,
  instagram,
) async {
  final response = await http.post(
    Uri.parse(createPelangganUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "nama_member": name,
      "alamat_member": address,
      "phonenumber": phone,
      "email": email,
      "twitter": '',
      "instagram": instagram,
      "facebook": ''
    },
  );

  var jsonResponse = jsonDecode(response.body);
  print(jsonResponse);
  if (response.statusCode == 200) {
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
  return jsonResponse;
}

Future createPendapatan(
  BuildContext context,
  token,
  ppm,
  jenis,
  keterangan,
  jumlah,
  merchid,
  PageController controller,
) async {
  var body = {
    "deviceid": identifier,
    "tanggal": "27-01-2023",
    "ppm": ppm,
    "jenis": jenis,
    "keterangan": keterangan,
    "jumlah": jumlah,
    "merchantid": ""
  };

  final response = await http.post(
    Uri.parse(createPemasukanUrl),
    headers: {
      'token': token,
    },
    body: body,
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    // print(jsonResponse.toString());
    controller.jumpToPage(0);
  } else {
    print(jsonResponse['rc'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future ubahPendapatan(
  BuildContext context,
  token,
  id,
  ppm,
  keterangan,
  jumlah,
  merchid,
  PageController controller,
) async {
  var body = {
    "deviceid": identifier,
    "PPM_ID": "OUT-202301270003",
    "tanggal": "27-01-2023",
    "ppm": "Investasi",
    "keterangan": "pembelian saham indomie",
    "jumlah": "1500000",
    "merchantid": ""
  };

  final response = await http.post(
    Uri.parse(ubahPemasukanUrl),
    headers: {
      'token': token,
    },
    body: body,
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    // print(jsonResponse.toString());
    controller.jumpToPage(0);
  } else {
    print(jsonResponse['rc'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future editPelanggan(
  BuildContext context,
  token,
  String memberid,
  name,
  address,
  phone,
  email,
  instagram,
) async {
  var body = {
    "deviceid": identifier,
    "memberid": memberid,
    "nama_member": name,
    "alamat_member": address,
    "phonenumber": phone,
    "email": email,
    "twitter": "",
    "instagram": instagram,
    "facebook": ""
  };

  final response = await http.post(
    Uri.parse(editPelangganUrl),
    headers: {
      'token': token,
    },
    body: body,
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print('succes');

    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    // print(jsonResponse['rc'].toString());
    // showSnackbar(context, jsonResponse);
  }
  return jsonResponse['message'];
}

Future createVoucher(
  BuildContext context,
  token,
  String name,
  isActive,
  price,
  point,
  merchid,
  PageController controller,
) async {
  whenLoading(context);
  final String jsonTest = json.encode(merchid);

  final response = await http.post(
    Uri.parse(createVoucherUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "namavoucher": name,
      "merchantid": merchid,
      "price_online_shop": "0",
      "isActive": isActive,
      "harga": price,
      "point": point,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  print(jsonResponse);
  if (response.statusCode == 200) {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  }
}

Future updateVoucher(
  BuildContext context,
  token,
  String name,
  isActive,
  price,
  point,
  merchid,
  PageController controller,
  productid,
) async {
  whenLoading(context);
  final String jsonTest = json.encode(merchid);
  var body = {
    "deviceid": identifier,
    "namavoucher": name,
    "merchantid": jsonTest,
    "voucherid": productid,
    "isActive": isActive,
    "price": price,
    "point": point,
  };

  final response = await http.post(
    Uri.parse(updateVoucherUrl),
    headers: {
      'token': token,
    },
    body: body,
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print('succes');
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    // closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
  return jsonResponse['message'];
}

Future createProduct(
    BuildContext context,
    token,
    String name,
    typeProduct,
    isPPN,
    isActive,
    price,
    onlinePrice,
    image,
    List<String> merchid,
    PageController controller) async {
  whenLoading(context);
  final String jsonTest = json.encode(merchid);
  var body = {
    "deviceid": identifier,
    "name": name,
    "shortname": "",
    "merchantid": jsonTest,
    "typeproducts": typeProduct,
    "isPPN": isPPN,
    "isActive": isActive,
    "price": price,
    "price_online_shop": onlinePrice,
    "product_image": "data:image/jpeg;base64,$image",
  };

  final response = await http.post(
    Uri.parse(createProdukUrl),
    headers: {
      'token': token,
    },
    body: body,
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print('succes');
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  }
}

var subTotal,
    ppnTransaksi,
    totalTransaksi,
    customerTransaksi,
    namaCustomerCalculate,
    discountProduct,
    discountProductUmum;
Future calculateTransaction(
  BuildContext context,
  token,
  List<Map<String, String>> details,
  StateSetter setState,
  memberid,
  typePrice,
  discount,
) async {
  final String detail = json.encode(details);

  final response = await http.post(
    Uri.parse(calculateTransaksiUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "memberid": memberid,
      "detail": detail,
      "discount": discount,
      "typePrice": typePrice,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  var data = jsonResponse['data'];
  if (response.statusCode == 200) {
    print('succes');
    // log(jsonResponse.toString());
    // print(jsonResponse['data']['subTotal'].toString());
    // print(totalTransaksi.toString());
    totalTransaksi = data['total'];
    subTotal = data['subTotal'];
    ppnTransaksi = data['PPN'];
    namaCustomerCalculate = data['customerName'];
    discountProduct = data['discount'];
    discountProductUmum = data['discount_umum'];
    setState(() {});
    closeLoading(context);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  }
}

String printext = '',
    transaksiNama = '',
    transaksiMetode = '',
    transaksiPesanan = '',
    transaksiKasir = '';

Future createTransaction(
  BuildContext context,
  token,
  value,
  List<Map<String, String>> details,
  PageController pageController,
  dynamic cart,
  setState,
  method,
  reference,
  transactionid,
  memberid,
) async {
  whenLoading(context);
  final String detail = json.encode(details);

  final response = await http.post(
    Uri.parse(createTransaksiUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "discount": "",
      "memberid": memberid,
      "transactionid": transactionid,
      "value": value,
      "payment_method": method,
      "payment_reference": reference,
      "detail": detail
    },
  );

  var jsonResponse = jsonDecode(response.body);
  var data = jsonResponse['data'];
  if (response.statusCode == 200) {
    print(jsonResponse);
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    // pageController.jumpTo(0);
    // print(jsonResponse['data'].toString());
    setState(() {
      // subTotal = 0;
      printext = jsonResponse['data']['raw'];
      transaksiNama = data['customer'];
      transaksiMetode = data['payment_method'];
      transaksiPesanan = data['transactionid'];
      transaksiKasir = data['pic'];

      // cart.clear();
      // closeLoading(context);
    });
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future saveTransaction(
  BuildContext context,
  token,
  value,
  List<Map<String, String>> details,
  PageController pageController,
  dynamic cart,
  setState,
  method,
  reference,
) async {
  final String detail = json.encode(details);

  final response = await http.post(
    Uri.parse(createTransaksiUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "discount": "",
      "memberid": "",
      "value": value,
      "payment_method": method,
      "payment_reference": reference,
      "detail": detail
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    pageController.jumpTo(0);
    cart.clear();
    setState(() {
      subTotal = 0;
    });
    print(jsonResponse.toString());
  } else {
    print(jsonResponse['message'].toString());
    // print(jsonResponse.toString());
    showSnackbar(context, jsonResponse);
  }
}

Future deletePesanan(
  BuildContext context,
  token,
  transactionid,
) async {
  final response = await http.post(Uri.parse(deleteTransaksiUrl), headers: {
    'token': token,
  }, body: {
    "deviceid": identifier,
    "transactionid": transactionid,
    "reason": "1"
  });

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
  } else {
    print(jsonResponse['rc'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future headerTagihan(
  BuildContext context,
  token,
  transactionid,
  typetransaksi,
) async {
  final response = await http.post(Uri.parse(headerTagihanUrl), headers: {
    'token': token,
  }, body: {
    "deviceid": identifier,
    "transactionid": transactionid,
    "typetransaksi": typetransaksi,
  });

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print('succes');
    return jsonResponse['data'];
  } else {
    print(jsonResponse['rc'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future deleteReference(
  BuildContext context,
  token,
  transaksiReference,
  idkategori,
  detailAlasan,
  transactionidValue,
) async {
  final response = await http.post(Uri.parse(deleteTagihanUrl), headers: {
    'token': token,
  }, body: {
    "deviceid": identifier,
    // "transaksiid_reference": transaksiReference,
    "transactionid": transactionidValue,
    "idkategori": idkategori,
    "detail_alasan": detailAlasan,
  });

  var jsonResponse = jsonDecode(response.body);

  print(jsonResponse);

  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    // closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['rc'].toString());
    errorText = jsonResponse['message'];
    return jsonResponse['rc'];
  }
}

Future approveReference(
  BuildContext context,
  token,
  transactionid,
  status,
) async {
  final response = await http.post(Uri.parse(approveTransaksiUrl), headers: {
    'token': token,
  }, body: {
    "deviceid": identifier,
    "transactionid": transactionid,
    "status": status
  });

  var jsonResponse = jsonDecode(response.body);

  print(jsonResponse['data']);
  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    print(jsonResponse['rc'].toString());
    return jsonResponse['message'];
  }
}

Future getPendapatan(BuildContext context, token, condition, merchantid) async {
  final response = await http.post(
    Uri.parse(getPendapatanUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "jenis": condition,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    // print(jsonResponse.toString());

    final List<PendapatanLainModel> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = PendapatanLainModel.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getYearRekon(token, merchantid) async {
  final response = await http.post(
    Uri.parse(getYearRekonUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    // print(jsonResponse.toString());

    return jsonResponse['data'];
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

Future getMonthRekon(token, year, merchid) async {
  final response = await http.post(
    Uri.parse(getMonthRekonUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "tahun": year,
      "merchantid": merchid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  print(jsonResponse.toString());
  if (response.statusCode == 200) {
    print('succes');

    return jsonResponse['data'];
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

Future getPengeluaran(BuildContext context, token, condition) async {
  final response = await http.post(
    Uri.parse(getPendapatanUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "jenis": condition,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');
    // print(jsonResponse.toString());

    return jsonResponse['data'];
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getRekon(token, tahun, bulan, merchantid) async {
  final response = await http.post(
    Uri.parse(getRekonUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "tahun": tahun,
      "bulan": bulan,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return jsonResponse['data'];
  } else {
    print(jsonResponse['message'].toString());
  }
}

Future saveRekon(context, token, id, status, keterangan) async {
  final response = await http.post(
    Uri.parse(saveRekonUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "id": id,
      "isDone": status,
      "keterangan": keterangan,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    Navigator.pop(context);
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['data'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse['message'].toString());
  }
}

Future postingRekon(context, token, tahun, bulan, merchantid) async {
  final response = await http.post(
    Uri.parse(postingRekonUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "tahun": tahun,
      "bulan": bulan,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    Navigator.pop(context);
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['data'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse['message'].toString());
  }
}

Future getRiwayatTransaksi(
    BuildContext context, token, condition, merchid, orderby) async {
  final response = await http.post(
    Uri.parse(getTransaksiRiwayatUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "condition": condition,
      "orderby": orderby,
      "merchantid": merchid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    final List<TokoDataRiwayatModel> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = TokoDataRiwayatModel.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getDetailRiwayatTransaksi(
    BuildContext context, token, transactionid) async {
  final response = await http.post(
    Uri.parse(getTransaksiSingleRiwayatUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "transactionid": transactionid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    final List<DetailSingle> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = DetailSingle.fromJson(item);
      result.add(model);
    }

    print(jsonResponse['message']);

    return result;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future<Map<String, dynamic>> getSingleRiwayatTransaksi(
    token, transactionid, merchantid) async {
  final body = {
    "deviceid": identifier,
    "transactionid": transactionid,
    "merchantid": merchantid,
  };

  final response = await http.post(
    Uri.parse(getTransaksiSingleRiwayatUrl),
    body: body,
    headers: {
      'token': token,
    },
  );

  Map<String, dynamic> data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print(data.toString());
    printext = data['data']['rawstruk'];

    return data;
  } else {
    throw Exception('Failed to load data ${data}');
  }
}

Future<Map<String, dynamic>> getSingleRiwayatTransaksiGrup(
    token, transactionid, merchid) async {
  final body = {
    "deviceid": identifier,
    "transactionid": transactionid,
    "merchantid": merchid
  };

  final response = await http.post(
    Uri.parse(getTransaksiSingleRiwayatUrl),
    body: body,
    headers: {
      'token': token,
    },
  );

  // mengembalikan data yang didapat dari API sebagai objek Map
  if (response.statusCode == 200) {
    // Convert response body to JSON
    Map<String, dynamic> data = jsonDecode(response.body);

    printext = data['data']['raw'];
    // print(data['data'].toString());

    return data;
  } else {
    throw Exception('Failed to load data');
  }
}

Future getProductTransaksi(BuildContext context, token, String name,
    List<String> merchid, orderby) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(getProductUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": jsonTest,
      "name": name,
      "isActive": "1",
      "orderby": orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    // print(jsonResponse.toString());

    final List<ProductModel> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']['product']) {
      final model = ProductModel.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getCoinTransaksi(
    BuildContext context, token, String name, List<String> merchid) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(getProductUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": jsonTest,
      "name": name,
      "isActive": "1",
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    // print(jsonResponse.toString());

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['coin']);
    // print(jsonResponse['data']['coin'].toString());
    return data['data']['coin'];
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanDaily(
  BuildContext context,
  token,
  orderBy,
  keyword,
  List merchid,
  export,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanDailyUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "keyword": keyword.toString(),
      "orderby": orderBy.toString(),
      "merchantid": jsonTest,
      "export": export,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print('succes');

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanDailyExport(
  BuildContext context,
  token,
  orderBy,
  keyword,
  List merchid,
  export,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanDailyUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "keyword": keyword.toString(),
      "orderby": orderBy.toString(),
      "merchantid": jsonTest,
      "export": export,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print('succes');

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanMerchant(
  BuildContext context,
  token,
  keyword,
  orderby,
  List merchid,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanMerchUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "keyword": keyword.toString(),
      "orderby": orderby.toString(),
      "merchantid": jsonTest,
    },
  );

  // print(keyword + orderby);

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    print(jsonResponse.toString());

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString() + jsonResponse['rc'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanMerchantExport(
  BuildContext context,
  token,
  keyword,
  orderby,
  List merchid,
  export,
) async {
  whenLoading(context);
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanMerchUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "keyword": keyword,
      "orderby": orderby,
      "merchantid": jsonTest,
      "export": export,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  print(jsonResponse.toString());
  if (response.statusCode == 200) {
    print('succes');

    print(jsonResponse.toString());
    closeLoading(context);
    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanPerProduk(
  BuildContext context,
  token,
  keyword,
  orderby,
  List merchid,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanProdukUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "keyword": keyword.toString(),
      "orderby": orderby.toString(),
      "merchantid": jsonTest,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    // print(jsonResponse.toString());

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanPerProdukExport(
  BuildContext context,
  token,
  keyword,
  orderby,
  List merchid,
  export,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanProdukUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "keyword": keyword.toString(),
      "orderby": orderby.toString(),
      "merchantid": jsonTest,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    // print(jsonResponse.toString());

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

var productPrice = 0, nameChart;

late String nameEditProduk,
    hargaEditProduk,
    hargaEditOnlineProduk,
    jenisProductEdit,
    kodejenisProductEdit,
    ppnEdit,
    tampilEdit,
    imageEdit;
Future getSingleProduct(
    BuildContext context, token, String merchid, productid, setState) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(getSingleProductUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      "productid": productid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  // print(jsonResponse.toString());
  if (response.statusCode == 200) {
    var dataku = jsonResponse['data'];
    print(dataku.toString());

    nameEditProduk = dataku['name'];
    hargaEditProduk = dataku['price'].toString();
    hargaEditOnlineProduk = dataku['price_online_shop'].toString();
    jenisProductEdit = dataku['typeproducts'];
    kodejenisProductEdit = dataku['kodeproduct'];
    ppnEdit = dataku['isPPN'].toString();
    tampilEdit = dataku['isActive'].toString();
    imageEdit = dataku['product_image'].toString();
    closeLoading(context);
    // setState(() {});
    return jsonResponse['data'];
  } else {
    // print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

late String idDiskonUpdate,
    tipeDiskonUpdate,
    namaDiskonUpdate,
    hargaDiskonUpdate,
    tipeHargaDiskonUpdate,
    aktifDiskonUpdate,
    statusDiskonUpdate,
    tanggalAwalDiskon,
    tanggalAkhirDiskon,
    totalProdukDiskon;
List<String> productIdDiskon = [];

Future getSingleDiskon(context, token, id) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(getSingleDiskonLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "id": id,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  // log(jsonResponse.toString());
  if (response.statusCode == 200) {
    var dataku = jsonResponse['data'];
    //print(dataku.toString());

    idDiskonUpdate = dataku['id'].toString();
    tipeDiskonUpdate = dataku['type'].toString();
    namaDiskonUpdate = dataku['name'].toString();
    hargaDiskonUpdate = dataku['discount'].toString();
    tipeHargaDiskonUpdate = dataku['discount_type'].toString();
    aktifDiskonUpdate = dataku['date'].toString();
    statusDiskonUpdate = dataku['is_active'].toString();
    tanggalAwalDiskon = dataku['start_date'].toString();
    tanggalAkhirDiskon = dataku['end_date'].toString();

    // log(productIdDiskon.toString());
    productIdDiskon.clear();

    List<dynamic> products = dataku['products'];
    for (var product in products) {
      String productId = product['productid'].toString();
      productIdDiskon.add(productId);
    }

    totalProdukDiskon = products.length.toString();

    closeLoading(context);
    return jsonResponse['rc'].toString();
  } else {
    // print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

late String namaEditAkun,
    emailEditAkun,
    nomorEditAkun,
    statusEditAkun,
    useridEditAkun,
    imageEditAkun;
Future getSingleAkun(BuildContext context, token, String userid) async {
  final response = await http.post(
    Uri.parse(getSingleAkunUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "userid": userid,
    },
  );

  whenLoading(context);

  var jsonResponse = jsonDecode(response.body);
  var dataku = jsonResponse['data'];

  print(jsonResponse);

  if (response.statusCode == 200) {
    Navigator.of(context, rootNavigator: true).pop();
    namaEditAkun = dataku['fullname'];
    nomorEditAkun = dataku['phonenumber'];
    emailEditAkun = dataku['email'];
    imageEditAkun = dataku['account_image'] ?? '';
    useridEditAkun = dataku['userid'];
    statusEditAkun = dataku['status'];
    return response.statusCode.toString();
  } else {
    Navigator.of(context, rootNavigator: true).pop();
    showSnackbar(context, jsonResponse);
  }
}

late String nameEditPromosi,
    poinEditPromosi,
    hargaProductPromosi,
    statusPromosiUpdate;
Future getSinglePromosi(
    BuildContext context, token, String merchid, voucherid, setState) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(getSinglePromosiUrl),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      "voucherid": voucherid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes get single promosi');
    // Navigator.of(context, rootNavigator: true).pop();
    closeLoading(context);
    nameEditPromosi = jsonResponse['data']['name'];
    poinEditPromosi = jsonResponse['data']['point'].toString();
    hargaProductPromosi = jsonResponse['data']['price'].toString();
    statusPromosiUpdate = jsonResponse['data']['isActive'].toString();
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
    showSnackbar(context, jsonResponse);
  }
}

Future getOtpSandi(BuildContext context, token, typeotp) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(getOtpSandiLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "typeotp": typeotp,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print(jsonResponse);
    closeLoading(context);
  } else {
    print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
  return jsonResponse['rc'];
}

Future validasiOtpSandi(BuildContext context, token, otp, typeotp) async {
  final response = await http.post(
    Uri.parse(validasiOtpSandiLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "otp": otp,
      "typeotp": typeotp,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print(jsonResponse);

    showSnackbar(context, jsonResponse);
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
    errorText = jsonResponse['message'];
  }
  return jsonResponse['rc'];
}

Future deleteQris(BuildContext context, token, merchantid) async {
  final response = await http.post(
    Uri.parse(deleteQrisLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print(jsonResponse.toString());
    Navigator.pop(context);

    showSnackBarComponent(
        context, jsonResponse['data']['message'], jsonResponse['rc']);

    logoQris = '';
    getQris(context, token, merchantid);

    return jsonResponse['rc'];
  } else {
    // print(jsonResponse['message'].toString());
  }
}

Future uploadQris(BuildContext context, token, imageQris, merchantid) async {
  final response = await http.post(
    Uri.parse(uploadQrisLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "qris": "data:image/png;base64," + imageQris,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print(jsonResponse.toString());

    Navigator.pop(context);

    showSnackBarComponent(
        context, jsonResponse['data']['message'], jsonResponse['rc']);

    logoQris = jsonResponse['data']['qris'];

    return jsonResponse['rc'];
  } else {
    showSnackBarComponent(
        context, jsonResponse['data']['message'], jsonResponse['rc']);
    print(jsonResponse['message'].toString());
  }
}

Future uploadStruk(BuildContext context, token, imageStruk, merchantid) async {
  final response = await http.post(
    Uri.parse(uploadStrukLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "struk": "data:image/png;base64," + imageStruk,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    Navigator.pop(context);

    showSnackBarComponent(
        context, jsonResponse['data']['message'], jsonResponse['rc']);

    logoStruk = jsonResponse['data']['struk'];
    logoStrukPrinter = jsonResponse['data']['struk_printer'];
    getStruk(context, token, merchantid);
    return jsonResponse['rc'];
  } else {
    showSnackBarComponent(
        context, jsonResponse['data']['message'], jsonResponse['rc']);
  }
}

Future getStruk(BuildContext context, token, merchantid) async {
  final response = await http.post(
    Uri.parse(getStrukLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    if (jsonResponse['data']['struk'] == null) {
      logoStruk = '';
      logoStrukPrinter = '';
    } else {
      logoStruk = jsonResponse['data']['struk'];
      logoStrukPrinter = jsonResponse['data']['struk_printer'];
    }

    print(jsonResponse);

    return jsonResponse['rc'];
  } else {
    showSnackBarComponent(
        context, jsonResponse['data']['message'], jsonResponse['rc']);
  }
}

Future deleteStruk(BuildContext context, token, merchantid) async {
  final response = await http.post(
    Uri.parse(deleteStrukLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "merchantid": merchantid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    logoStruk = '';
    logoStrukPrinter = '';
    getStruk(context, token, merchantid);

    Navigator.pop(context);

    showSnackBarComponent(
        context, jsonResponse['data']['message'], jsonResponse['rc']);

    return jsonResponse['rc'];
  } else {}
}

Future transaksiViewReference(
    BuildContext context, token, transactionid) async {
  final response = await http.post(
    Uri.parse(transaksiViewReferenceLink),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": identifier,
      "transactionid": transactionid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print(jsonResponse.toString());

    return jsonResponse;
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future getQris(BuildContext context, token, merchantid) async {
  final response = await http.post(
    Uri.parse(getQrisLink),
    headers: {
      'token': token,
    },
    body: {"deviceid": identifier, "merchantid": merchantid},
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    if (jsonResponse['data']['qris'] == null) {
      logoQris = '';
    } else {
      logoQris = jsonResponse['data']['qris'];
    }

    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future<void> downloadFile(String link) async {
  var statusstorage = await Permission.storage.request();
  try {
    if (statusstorage.isGranted) {
      print(link);
      final baseStorage = await getExternalStorageDirectory();

      await FlutterDownloader.enqueue(
        url: link,
        headers: {},
        savedDir: baseStorage!.path,
        showNotification: true,
        openFileFromNotification: true,
        fileName: 'Report_Laporan',
      );
    }
  } catch (e) {
    print('Error: $e');
  }
}
