import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:unipos_app_335/models/coaModel.dart';
import 'package:unipos_app_335/models/inventoriModel/bomModel.dart';
import 'package:unipos_app_335/models/inventoriModel/detailPembelianModel.dart';
import 'package:unipos_app_335/models/inventoriModel/inventoriModel.dart';
import 'package:unipos_app_335/models/inventoriModel/pembelianInventoriModel.dart';
import 'package:unipos_app_335/models/inventoriModel/penyesuaianInventoriModel.dart';
import 'package:unipos_app_335/models/inventoriModel/unitConvertionModel.dart';
import 'package:unipos_app_335/models/inventoriModel/unitMasterModel.dart';
import 'package:unipos_app_335/models/kulasedayaMemberModel.dart';
import 'package:unipos_app_335/models/modelSingleTokoModel.dart';
import 'package:unipos_app_335/models/productVariantModel.dart';
import 'package:unipos_app_335/pagehelper/loginregis/login_page.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';

import '../main.dart';
import '../models/diskonModel.dart';
import '../models/inventoriModel/produkMaterialModel.dart';
import '../models/lihatakunmodel.dart';
import '../models/modelDataRegion.dart';
import '../models/produkmodel.dart';
import '../models/tokoModel/calculateCart.dart';
import '../models/tokoModel/riwayatTransaksiTokoModel.dart';
import '../models/tokoModel/singletokomodel.dart';
import '../models/tokoModel/tokomodel.dart';
import '../models/tokoModel/transaksiTokoModel.dart';
import '../pagehelper/loginregis/lupaSandiPage/buat_sandi_baru.dart';
import 'modelBloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
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

import '../utils/component/component_color.dart';
import '../utils/component/component_loading.dart';
import '../utils/component/providerModel/refreshTampilanModel.dart';

// String url = 'https://api.prod.amio.my.id';
String url = 'https://unipos-dev-unipos-api-dev.yi8k7d.easypanel.host';

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
    dashboardChart = '$url/api/v2/user/dashboard/gross',
    dashboardCheckBilling = '$url/api/v2/billing/check',
    dashboardChartPendapatan = '$url/api/v2/user/dashboard/nett',
    createMerchan = '$url/api/merchant/create',
    createProdukUrl = '$url/api/product/create',
    createVoucherUrl = '$url/api/voucher/create',
    updateVoucherUrl = '$url/api/voucher/update',
    approveTransaksiUrl = '$url/api/transaction/approve/reference',
    createTransaksiUrl = '$url/api/v2/transaction/create',
    deleteTransaksiUrl = '$url/api/transaction/delete',
    headerTagihanUrl = '$url/api/transaction/create/reference/tagihan',
    deleteTagihanUrl = '$url/api/transaction/delete/reference/tagihan',
    getTransaksiRiwayatUrl = '$url/api/v2/transaction/',
    getPendapatanUrl = '$url/api/ppm/get',
    getRekonUrl = '$url/api/rekon/',
    saveRekonUrl = '$url/api/rekon/save',
    postingRekonUrl = '$url/api/rekon/posting',
    getYearRekonUrl = '$url/api/rekon/year',
    getMonthRekonUrl = '$url/api/rekon/month',
    getTransaksiSingleRiwayatUrl = '$url/api/v2/transaction/receipt',
    calculateTransaksiUrl = '$url/api/v2/transaction/calculating',
    updateAkunUrl = '$url/api/user/update',
    deleteAkunUrl = '$url/api/user/delete',
    deleteMerchan = '$url/api/merchant/delete',
    uploadProdukUrl = '$url/api/product/upload',
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
    getProductUrl = '$url/api/v2/product',
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
    laporanPembayaranUrl = '$url/api/report/coa',
    laporanStokUrl = '$url/api/report/inventory/stock',
    laporanPergerakanInventoriUrl = '$url/api/report/inventory/movement',
    laporanPenggunaanProdukUrl = '$url/api/report/bom',
    laporanBOMUsageUrl = '$url/api/report/bom',
    laporanProdukExportUrl = '$url/api/export/report/income/product',
    laporanTokoExportUrl = '$url/api/export/report/income/merchant',
    laporanPendapatanHarianExportUrl = '$url/api/export/report/income/daily',
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
    getVariantLink = '$url/api/product-variant',
    createVariantLink = '$url/api/product-variant/resource',
    aktifDiskonLink = '$url/api/discount/change-is-active',
    getSinglePendapatanHarianLink = '$url/api/report/income/daily/full',
    diskonTransaksiLink = '$url/api/discount/transaction',
    getCoaRefLink = '$url/api/type/payment/references',
    getCoaMethodLink = '$url/api/type/payment',
    addCoaLink = '$url/api/type/payment/create',
    updateCoaLink = '$url/api/type/payment/update',
    deleteCoaLink = '$url/api/type/payment/delete',
    getBOMLink = '$url/api/product-material/',
    getUnitConvertionLink = '$url/api/unit-conversion/',
    createUnitConvertionLink = '$url/api/unit-conversion/create',
    getSingleUnitConvertionLink = '$url/api/unit-conversion/single',
    deleteUnitConvertionLink = '$url/api/unit-conversion/delete',
    updateUnitConvertionLink = '$url/api/unit-conversion/update',
    getSingleBOMLink = '$url/api/product-material/single',
    createBOMLink = '$url/api/product-material/create',
    updateBOMLink = '$url/api/product-material/update',
    deleteBOMLink = '$url/api/product-material/delete',
    getAdjustmentLink = '$url/api/inventory/adjustment',
    getDetailAdjustmentLink = '$url/api/inventory/adjustment/detail',
    createAdjustmentLink = '$url/api/inventory/adjustment/create',
    deleteAdjustmentLink = '$url/api/inventory/adjustment/delete',
    updateAdjustmentLink = '$url/api/inventory/adjustment/update',
    getPurchaseLink = '$url/api/inventory/purchase',
    getDetailPurchaseLink = '$url/api/inventory/purchase/detail',
    createDetailPurchaseLink = '$url/api/inventory/purchase/create',
    updateDetailPurchaseLink = '$url/api/inventory/purchase/update',
    deleteDetailPurchaseLink = '$url/api/inventory/purchase/delete',
    getMasterDataLink = '$url/api/inventory/master',
    createMasterDataLink = '$url/api/inventory/master/create',
    getMasterDataSingleLink = '$url/api/inventory/master/single',
    getMasterDataSingleDetailLink = '$url/api/inventory/master/detail',
    getUnitMasterDataLink = '$url/api/unit',
    copyMasterDataLink = '$url/api/inventory/master/copy',
    updateMasterDataLink = '$url/api/inventory/master/update',
    deleteMasterDataLink = '$url/api/inventory/master/delete',
    getkulasedayaLink = '$url/api/merchant/binding/kulasedaya',
    bindingKulasedayaLink = '$url/api/binding/kulasedaya',
    getkulasedayaMerchantLink = '$url/api/merchant/binding/kulasedaya',
    deletekulasedayaTagihanLink =
        '$url/api/transaction/delete/reference/tagihan/kulasedaya',
    getProvinsiLink = '$url/api/province',
    getRegenciesLink = '$url/api/regencies',
    getDistrictLink = '$url/api/district',
    getVillageLink = '$url/api/village',
    getTipeUsahaLink = '$url/api/tipeusaha';

String out = '$url/api/logout';
String firebaseTokenUrl = '$url/api/user/update/firebasetoken';

const background = Color(0xFF1363DF);
const primaryColor = Color(0xFF1363DF);
const canvasColor = Colors.white;

const scaffoldBackgroundColor = Color(0xFFF5F5F5);
// const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;

final divider = Divider(color: bnw100, thickness: 8);

Future firebaseToken(tokenFirebase, token) async {
  try {
    var response = await Dio().post(
      firebaseTokenUrl,
      data: {'deviceid': identifier, 'token': tokenFirebase},
      options: Options(headers: {"token": "$token"}),
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
      body: {'deviceid': identifier},
      headers: {'token': token},
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
      data: {'deviceid': identifier},
      options: Options(headers: {"token": token}),
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
    whenLoading(context);
    final response = await http.post(
      Uri.parse(tambahKategoriLink),
      body: {'name': name},
      headers: {
        'Content-Type':
            'application/x-www-form-urlencoded', // Keep this for FormData
        'token': token,
      },
    );

    var jsonResponse = jsonDecode(response.body);
    // print('hello ${response.body}');

    if (response.statusCode == 200) {
      print("succes tambah kategori");
      closeLoading(context);
      // Navigator.pop(context);

      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      // Navigator.pop(context);
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
      body: {'id': idkategori},
      headers: {'token': token},
    );
    var jsonResponse = jsonDecode(response.body);
    print(response.body.toString());
    if (response.statusCode == 200) {
      print("succes hapus kategori");

      closeLoading(context);
      // Navigator.pop(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      // Navigator.pop(context);
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
      body: {'id': idkategori, 'name': name},
      headers: {'token': token},
    );
    var jsonResponse = jsonDecode(response.body);
    // log(response.body.toString());
    if (response.statusCode == 200) {
      print("succes hapus kategori");
      closeLoading(context);
      Navigator.pop(context);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      Navigator.pop(context);
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
      body: {'fullname': mycontroller, 'deviceid': id.toString()},
      headers: {'token': token},
    );
    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("succes aman tentram");
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

String userPhone = '', userEmail = '', userId = '';
Future changePasswordRequest(context, type, id) async {
  whenLoading(context);
  try {
    final response = await http.post(
      Uri.parse(forgotPassRequestLink),
      body: {'type': type, 'identifier': id},
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
      body: {'type': type, 'id': id},
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
      body: {'id': id, 'otp': otp},
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      errorText = '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BuatSandiBaruPage(userid: id)),
      );
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
      body: {'id': id, 'passsword': pass, 'password_confirmation': conPass},
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
      options: Options(headers: {"token": "$token"}),
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
      options: Options(headers: {"token": "$token"}),
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

int emailChecker = 0;
var statusVerified, statusPw;
Future checkEmail(token, setState) async {
  try {
    var response = await Dio().post(
      checkEmailVerified,
      data: {'email': emailProfile, 'deviceid': identifier},
      options: Options(headers: {"token": "$token"}),
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
      data: {'deviceid': identifier, 'typeotp': typeotp},
      options: Options(headers: {"token": token}),
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
    body: {'deviceid': identifier, 'otp': otp, 'typeotp': typeotp},
    headers: {"token": token},
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
      data: {"deviceid": identifier, "email": email, "typeotp": typeotp},
      options: Options(headers: {"token": "$token"}),
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
    body: {'deviceid': identifier, 'otp': otp, 'typeotp': typeotp},
    headers: {"token": token},
  );
  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print(jsonResponse['data']);
    // Navigator.pop(context);
    // Navigator.pop(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    // showSnackbar(context, jsonResponse);
    errorText = jsonResponse['message'];
    return jsonResponse['rc'];
  }
}

Future changePhoto(token, id, context, imageCon, reload) async {
  try {
    var response = await Dio().post(
      changeImage,
      data: {
        'deviceid': id.toString(),
        'image': "data:image/png;base64," + imageCon.toString(),
      },
      options: Options(headers: {"token": "$token"}),
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

String merchantId = '';
Future getAllToko(context, token, name, orderby) async {
  await Future.delayed(Duration(milliseconds: 150));
  final response = await http.post(
    Uri.parse(getMerch),
    headers: {'token': token},
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
    headers: {'token': token},
    body: {"deviceid": identifier},
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
    headers: {'token': token},
    body: {"deviceid": identifier, "merchantid": id, 'orderby': orderby},
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

late String nameMerchantUbah = '',
    addressMerchantUbah = '',
    zipMerchantUbah = '',
    nameProvUbah = '',
    kodeProvUbah = '',
    nameregUbah = '',
    kodeRegUbah = '',
    nameDisUbah = '',
    kodeDisUbah = '',
    nameVillageUbah = '',
    kodeVillageUbah = '',
    zipcodeUbah = '',
    tipeUbah = '',
    idtipeUbah = '',
    imageEditToko = '';

Future getSingleMerch(context, token, String merchid) async {
  final response = await http.post(
    Uri.parse(getSingleMerchant),
    headers: {'token': token},
    body: {"deviceid": identifier, "merchantid": merchid},
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

Future<MerchantDetailModel?> getSingleMerchMobile(
  BuildContext context,
  String token,
  String merchid,
) async {
  try {
    final response = await http.post(
      Uri.parse(getSingleMerchant),
      headers: {'token': token},
      body: {"deviceid": identifier, "merchantid": merchid},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'];
      if (jsonResponse['rc'] == '00' && data != null) {
        return MerchantDetailModel.fromJson(data);
      } else {
        showSnackbar(context, {"message": jsonResponse['message'] ?? 'Gagal'});
      }
    } else {
      showSnackbar(context, {"message": "Gagal memuat data toko"});
    }
  } catch (e) {
    showSnackbar(context, {"message": "Terjadi kesalahan: $e"});
  }
  return null;
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
        "namemerchant": nameMerch ?? '',
        "address": address ?? '',
        "province": province ?? '',
        "regencies": regencies ?? '',
        "district": district ?? '',
        "village": village ?? '',
        "zipcode": zipcode ?? '',
        "businesstype": businesstype ?? '',
        "logomerchant_url": "data:image/png;base64,$image",
      },
      headers: {"token": "$token"},
    );
    // print(response.data['rc']);

    var jsonResponse = jsonDecode(response.body);
    // print(jsonResponse['rc']);

    if (response.statusCode == 200) {
      // print("succes aman tentram");
      // print(response.data['data']);
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
  role,
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
        "image": "data:image/png;base64,$image",
        "role": role,
      },
      headers: {"token": "$token"},
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
  iscashier,
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
      "role": iscashier,
    },
    headers: {"token": "$token"},
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
        "logomerchant_url": "data:image/png;base64,$image",
      },
      headers: {"token": "$token"},
    );
    // print(response.data['rc']);

    var jsonResponse = jsonDecode(response.body);
    // print(jsonResponse['rc']);

    if (response.statusCode == 200) {
      print("Succes Update Merchant");
      // print(response.data['data']);
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
  img,
) async {
  String imgFix = '';
  if (img == '') {
    imgFix = '';
  } else {
    imgFix = 'data:image/jpeg;base64,$img';
  }

  try {
    whenLoading(context);
    // log('KODE $typeproducts');
    var body = {
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
    };

    // print('ini adalah body ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse(updateProdukUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("succes aman tentram");
      closeLoading(context);
      showSnackbar(context, jsonResponse);
      print(jsonResponse['data']);
      // Provider.of<ProductProvider>(context, listen: false).updateProduk(
      //   context,
      //   token,
      // );
      // Provider.of<ProductProvider>(context, listen: false);
      pageController.jumpTo(0);
      // getProductGrup(context, token, '', merchid, textvalueOrderBy);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      print(jsonResponse['rc']);
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    }
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
    headers: {'token': token},
    body: {"deviceid": identifier, "merchantid": jsonTest},
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

Future deleteAkun(BuildContext context, token, List userid) async {
  whenLoading(context);
  final String jsonTest = json.encode(userid);

  final response = await http.post(
    Uri.parse(deleteAkunUrl),
    headers: {'token': token},
    body: {"deviceid": identifier, "userid": jsonTest},
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

Future deletePurchase(BuildContext context, var token, List group_id) async {
  String jsonData = jsonEncode(group_id);
  whenLoading(context);
  final response = await http.post(
    Uri.parse(deleteDetailPurchaseLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "group_id": jsonData},
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
    headers: {'token': token},
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

Future deletePelanggan(BuildContext context, var token, List memberid) async {
  var jsonData = jsonEncode(memberid);

  final response = await http.post(
    Uri.parse(deletePelangganUrl),
    headers: {'token': token},
    body: {"deviceid": identifier, "memberid": jsonData},
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

Future changeActiveAkun(BuildContext context, token, status, userid) async {
  whenLoading(context);
  final String jsonTest = json.encode(userid);
  final response = await http.put(
    Uri.parse('$url/api/user/changeStatus'),
    headers: {'token': token},
    body: {"deviceid": identifier, "userid": jsonTest, "status": status},
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
    headers: {'token': token},
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
    return jsonResponse['rc'];
  } else {
    print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
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
    headers: {'token': token},
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
    return jsonResponse['rc'];
  } else {
    //print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
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
    headers: {'token': token},
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
    headers: {'token': token},
    body: {"deviceid": id},
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
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      "deviceid": identifier,
      "email": emailCon,
      "password": passCon,
      "confirmPassword": passCon,
    },
  );

  print(response.body);
  print(emailCon);
  print(passCon);

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
    headers: {'token': token},
    body: {"deviceid": identifier, "otp": otp},
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
  BuildContext context,
  token,
  newPass,
  conPass,
  typeotp,
) async {
  var response = await http.post(
    Uri.parse(changeSandiLink),
    headers: {"token": "$token"},
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
      data: {'deviceid': id.toString()},
      options: Options(headers: {"token": token}),
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

String? saldoKulasedaya, statusKulasedaya, messageKulasedaya = '';
Future<List<KulasedayaMember>> dashboardKulasedaya(String token) async {
  try {
    var response = await Dio().post(
      bindingKulasedayaLink,
      data: {'deviceid': identifier},
      options: Options(headers: {"token": token}),
    );

    log(response.data['data'].toString());

    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['data'] != null) {
      List<dynamic> dataList = response.data['data'];
      List<KulasedayaMember> members = dataList
          .map((item) => KulasedayaMember.fromJson(item))
          .toList();
      return members;
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<List<KulasedayaBinding>> bindingKulasedaya(String token) async {
  try {
    var response = await Dio().post(
      bindingKulasedayaLink,
      data: {'deviceid': identifier},
      options: Options(headers: {"token": token}),
    );

    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['data'] != null) {
      List<dynamic> dataList = response.data['data'];
      List<KulasedayaBinding> members = dataList
          .map((item) => KulasedayaBinding.fromJson(item))
          .toList();
      return members;
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<Map<String, dynamic>> dashboardSide(BuildContext context, token) async {
  final response = await http.post(
    Uri.parse(dashboardNumber),
    headers: {'token': token},
    body: {"deviceid": identifier},
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

Future<Map<String, dynamic>> getBilling(
  BuildContext context,
  String token,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final response = await http.post(
    Uri.parse(dashboardCheckBilling),
    headers: {'token': token},
    body: {"deviceid": identifier},
  );

  var jsonResponseThrow = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    showSnackbar(context, jsonResponseThrow);
    throw Exception(jsonResponseThrow['message'].toString());
  }
}

Future<Map<String, dynamic>> getValueDataChart(
  BuildContext context,
  token,
  tipe,
) async {
  print('tipe chart $tipe');
  final response = await http.post(
    Uri.parse(dashboardChart),
    headers: {'token': token},
    body: {"deviceid": identifier, "type": tipe},
  );

  // print(response.body);

  var jsonResponseThrow = jsonDecode(response.body);
  print('ada yang salah ${response.request}');
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

Future<Map<String, dynamic>> getValueDataChartPendapatan(
  BuildContext context,
  token,
  tipe,
) async {
  // print('tipe chart pendapatan $tipe');
  final response = await http.post(
    Uri.parse(dashboardChartPendapatan),
    headers: {'token': token},
    body: {"deviceid": identifier, "type": tipe},
  );

  var jsonResponseThrow = jsonDecode(response.body);
  // print('asade $jsonResponseThrow');
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
    headers: {'token': token},
    body: {"deviceid": identifier, "orderby": orderby},
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
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      'orderby': orderby,
      'merchantid': merchantid,
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
    headers: {'token': token},
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
    headers: {'token': token},
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
    headers: {'token': token},
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

Future deleteDiskon(BuildContext context, token, id) async {
  whenLoading(context);
  final String productidList = json.encode(id);
  final response = await http.post(
    Uri.parse(deleteDiskonLink),
    headers: {'token': token},
    body: {"deviceid": identifier, 'id': productidList},
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

Future getProduct(
  BuildContext context,
  token,
  String name,
  List<String> merchid,
  orderby,
) async {
  // final String jsonTest = json.encode(merchid);

  final body = {
    "deviceid": identifier,
    "merchantid": merchid,
    "name": name,
    "order_by": orderby,
    // "is_active": false,
  };

  final response = await http.post(
    Uri.parse(getProductUrl),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: json.encode(body),
  );

  print('sukses get produk ${response.body}');
  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print('succes');

    // productIdVariant = jsonResponse['data']['productid'].toString();
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
  BuildContext context,
  token,
  String name,
  List<String> merchid,
  orderby,
) async {
  final body = {
    "deviceid": identifier,
    "merchant_id": merchid,
    "name": name,
    "orderby": orderby,
    // "isActive": "false",
  };

  final response = await http.post(
    Uri.parse(getProductUrl),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: json.encode(body),
  );

  var jsonResponse = jsonDecode(response.body);
  print(jsonResponse);
  if (response.statusCode == 200) {
    await Future.delayed(Duration(seconds: 1));
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
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "nama_member": name,
      "alamat_member": address,
      "phonenumber": phone,
      "email": email,
      "twitter": '',
      "instagram": instagram,
      "facebook": '',
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
    "merchantid": "",
  };

  final response = await http.post(
    Uri.parse(createPemasukanUrl),
    headers: {'token': token},
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
    "merchantid": "",
  };

  final response = await http.post(
    Uri.parse(ubahPemasukanUrl),
    headers: {'token': token},
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
    "facebook": "",
  };

  final response = await http.post(
    Uri.parse(editPelangganUrl),
    headers: {'token': token},
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
    headers: {'token': token},
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
    headers: {'token': token},
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

Future<Map<String, dynamic>?> getProductVariant(
  BuildContext context,
  String token,
  String merchid,
  String productid,
) async {
  try {
    final body = {
      "deviceid": identifier,
      "order_by": "",
      "merchant_id": merchid,
      "product_id": productid,
    };

    final response = await http.post(
      Uri.parse(getVariantLink),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    // Log buat debugging
    print('🔹 [API Request] $getVariantLink');
    print('🔹 [Request Body] $body');
    print('🔹 [Status Code] ${response.statusCode}');
    print('🔹 [Response Body] ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Validasi struktur data
      if (jsonResponse is Map<String, dynamic>) {
        return jsonResponse;
      } else {
        debugPrint("⚠️ Response bukan Map: $jsonResponse");
        return null;
      }
    } else {
      showSnackbar(
        context,
        "Gagal memuat data (status ${response.statusCode})",
      );
      return null;
    }
  } catch (e, stackTrace) {
    debugPrint("❌ Error di getProductVariant: $e");
    debugPrint("StackTrace: $stackTrace");
    showSnackbar(context, "Terjadi kesalahan jaringan atau server");
    return null;
  }
}

Future<List<ProductVariantCategory>?> getProductVariantTransaksi(
  BuildContext context,
  String token,
  String merchid,
  String productid,
) async {
  try {
    final body = {
      "deviceid": identifier,
      "order_by": "",
      "merchant_id": merchid,
      "product_id": productid,
    };

    final response = await http.post(
      Uri.parse(getVariantLink),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    print('🔹 [API Request] $getVariantLink');
    print('🔹 [Request Body] $body');
    print('🔹 [Status Code] ${response.statusCode}');
    print('🔹 [Response Body] ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['rc'] == '00') {
        List<ProductVariantCategory> variants = (jsonResponse['data'] as List)
            .map((e) => ProductVariantCategory.fromJson(e))
            .toList();
        return variants;
      } else {
        showSnackbar(context, "Respon server tidak valid");
        return null;
      }
    } else {
      showSnackbar(
        context,
        "Gagal memuat data (status ${response.statusCode})",
      );
      return null;
    }
  } catch (e, stackTrace) {
    debugPrint("❌ Error di getProductVariant: $e");
    debugPrint("StackTrace: $stackTrace");
    showSnackbar(context, "Terjadi kesalahan jaringan atau server");
    return null;
  }
}

Future createProductVariant(
  BuildContext context,
  token,
  merchid,
  productid,
  variants, // This should be a List<Map<String, dynamic>> (an array)
) async {
  whenLoading(context);

  var body = {
    "deviceid": identifier,
    "merchant_id": merchid,
    "product_id": productid,
    "variants": variants,
  };

  final response = await http.post(
    Uri.parse(createVariantLink),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: json.encode(body),
  );

  // Decode the response body
  var jsonResponse = jsonDecode(response.body);
  // print(response.body);
  // print(jsonResponse);

  if (response.statusCode == 200) {
    showSnackbar(context, jsonResponse);
    closeLoading(context);
    return jsonResponse['rc'];
  } else {
    showSnackbar(context, jsonResponse);
    closeLoading(context);
    return jsonResponse['rc'];
  }
}

String productIdVariant = '';

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
  PageController controller,
) async {
  whenLoading(context);
  // final String jsonTest = json.encode(merchid);
  var body = {
    "deviceid": identifier,
    "name": name,
    "shortname": "",
    "merchantid": merchid,
    "typeproducts": typeProduct,
    "isPPN": isPPN,
    "isActive": isActive,
    "price": price,
    "price_online_shop": onlinePrice,
    "product_image": "data:image/jpeg;base64,$image",
  };

  // debugPrint(body.toString());

  final response = await http.post(
    Uri.parse(createProdukUrl),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    productIdVariant = jsonResponse['data'][0]['productid'].toString();
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
  transactionid,
) async {
  whenLoading(context);
  print('🧾 detail cart: $details');

  // 🔄 Ubah kembali field yang string ke tipe sesuai kebutuhan API
  List<Map<String, dynamic>> preparedDetails = details.map((item) {
    return {
      "product_id": item["product_id"],
      "request_id": item["id_request"] ?? "",
      "is_online": item["is_online"] == "true",
      "amount": num.tryParse(item["amount"] ?? "0") ?? 0,
      "name": item["name"],
      "quantity": item["quantity"],
      "description": item["description"],
      "variants": jsonDecode(item["variants"] ?? "[]"),
    };
  }).toList();

  print('🧾 preparedDetails: $preparedDetails');

  final response = await http.post(
    Uri.parse(calculateTransaksiUrl),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: json.encode({
      "deviceid": identifier,
      "member_id": memberid,
      "transaction_id": transactionid,
      "discount_id": discount,
      "typePrice": typePrice,
      "detail": preparedDetails,
    }),
  );

  var jsonResponse = jsonDecode(response.body);
  var data = jsonResponse['data'];
  debugPrint('🧾 Response Calculate: $jsonResponse');

  if (response.statusCode == 200) {
    closeLoading(context);
    // print('✅ Success');
    // log(jsonResponse.toString());

    totalTransaksi = data['amount'] ?? 0;
    subTotal = data['total_before_dsc_tax'] ?? 0;
    ppnTransaksi = data['ppn'] ?? 0;
    namaCustomerCalculate = data['customer_name'] ?? '';
    discountProduct = data['discount'] ?? 0;
    discountProductUmum = data['discount'] ?? 0;

    setState(() {});
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);

    // log(jsonResponse.toString());
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
  List<Map<String, String>> mapCalculate = List.empty(growable: true);

  for (var detail in details) {
    Map<String, String> map1 = {};
    map1['name'] = detail['name'] ?? '';
    map1['product_id'] = detail['product_id'] ?? '';
    map1['quantity'] = detail['quantity'] ?? '';
    map1['image'] = detail['image'] ?? '';
    map1['amount'] = detail['amount_display'] ?? detail['amount'] ?? '0';
    map1['description'] = detail['description'] ?? '';
    map1['id_request'] = detail['id_request'] ?? '';
    map1['is_online'] = detail['is_online'] ?? '';
    map1['variants'] = detail['variants'] ?? '[]'; // string JSON
    mapCalculate.add(map1);
  }

  // 🧩 Langkah 2: konversi ke format final (Map<String, dynamic>)
  // agar is_online jadi bool dan variants jadi array JSON
  List<Map<String, dynamic>> mapCalculateFinal = [];

  for (var item in mapCalculate) {
    mapCalculateFinal.add({
      "name": item['name'],
      "product_id": item['product_id'],
      "quantity": item['quantity'],
      "image": item['image'],
      "amount": item['amount'],
      "description": item['description'],
      "id_request": item['id_request'],
      "is_online": item['is_online'] == 'true', // ✅ ubah string ke bool
      "variants": jsonDecode(
        item['variants'] ?? '[]',
      ), // ✅ ubah string ke array JSON
    });
  }

  // 🧩 Kirim ke server
  final bodyJson = {
    "deviceid": identifier,
    "discount_id": "",
    "member_id": memberid,
    "transaction_id": transactionid,
    "value": value,
    "payment_method": method,
    "payment_reference": reference,
    "detail": mapCalculateFinal,
  };

  // final String detailBaru = json.encode(mapCalculate);

  final response = await http.post(
    Uri.parse(createTransaksiUrl),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: json.encode(bodyJson),
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
  memberid,
) async {
  whenLoading(context);
  List<Map<String, String>> mapCalculate = List.empty(growable: true);

  for (var detail in details) {
    Map<String, String> map1 = {};
    map1['name'] = detail['name'] ?? '';
    map1['product_id'] = detail['product_id'] ?? '';
    map1['quantity'] = detail['quantity'] ?? '';
    map1['image'] = detail['image'] ?? '';
    map1['amount'] = detail['amount_display'] ?? detail['amount'] ?? '0';
    map1['description'] = detail['description'] ?? '';
    map1['id_request'] = detail['id_request'] ?? '';
    map1['is_online'] = detail['is_online'] ?? '';
    map1['variants'] = detail['variants'] ?? '[]'; // string JSON
    mapCalculate.add(map1);
  }

  // 🧩 Langkah 2: konversi ke format final (Map<String, dynamic>)
  // agar is_online jadi bool dan variants jadi array JSON
  List<Map<String, dynamic>> mapCalculateFinal = [];

  for (var item in mapCalculate) {
    mapCalculateFinal.add({
      "name": item['name'],
      "product_id": item['product_id'],
      "quantity": item['quantity'],
      "image": item['image'],
      "amount": item['amount'],
      "description": item['description'],
      "id_request": item['id_request'],
      "is_online": item['is_online'] == 'true', // ✅ ubah string ke bool
      "variants": jsonDecode(
        item['variants'] ?? '[]',
      ), // ✅ ubah string ke array JSON
    });
  }

  final bodyJson = {
    "deviceid": identifier,
    "discount_id": "",
    "member_id": memberid,
    "transaction_id": '',
    "value": '',
    "payment_method": '',
    "payment_reference": reference,
    "detail": mapCalculateFinal,
  };

  final response = await http.post(
    Uri.parse(createTransaksiUrl),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: json.encode(bodyJson),
  );

  // print('🧾 Response Save Transaction: ${response.body}');

  // log("Payload ke server: ${json.encode(bodyJson)}");

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    showSnackbar(context, jsonResponse);
    closeLoading(context);
  } else {
    showSnackbar(context, jsonResponse);
    closeLoading(context);
  }
  return jsonResponse['rc'];
}

Future deletePesanan(BuildContext context, token, transactionid) async {
  final response = await http.post(
    Uri.parse(deleteTransaksiUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "transactionid": transactionid,
      "reason": "1",
    },
  );

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
  final response = await http.post(
    Uri.parse(headerTagihanUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "transactionid": transactionid,
      "typetransaksi": typetransaksi,
    },
  );

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
  final response = await http.post(
    Uri.parse(deleteTagihanUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      // "transaksiid_reference": transaksiReference,
      "transactionid": transactionidValue,
      "idkategori": idkategori,
      "detail_alasan": detailAlasan,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  print(jsonResponse);

  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    // closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    print(jsonResponse['rc'].toString());
    errorText = jsonResponse['message'];
    // closeLoading(context);
    return jsonResponse['rc'];
  }
}

Future approveReference(
  BuildContext context,
  token,
  transactionid,
  status,
) async {
  final response = await http.post(
    Uri.parse(approveTransaksiUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "transactionid": transactionid,
      "status": status,
    },
  );

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
    headers: {'token': token},
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
    headers: {'token': token},
    body: {"deviceid": identifier, "merchantid": merchantid},
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
    headers: {'token': token},
    body: {"deviceid": identifier, "tahun": year, "merchantid": merchid},
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
    headers: {'token': token},
    body: {"deviceid": identifier, "jenis": condition},
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
    headers: {'token': token},
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
    headers: {'token': token},
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
    headers: {'token': token},
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
  BuildContext context,
  token,
  condition,
  merchid,
  orderby,
) async {
  final response = await http.post(
    Uri.parse(getTransaksiRiwayatUrl),
    headers: {
      'token': token,
      'DEVICE-ID': identifier!,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "condition": condition,
      "order_by": orderby,
      "merchant_id": merchid,
    }),
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
  BuildContext context,
  token,
  transactionid,
) async {
  final response = await http.post(
    Uri.parse(getTransaksiSingleRiwayatUrl),
    headers: {'token': token, "DEVICE-ID": identifier!},
    body: {"transaction_id": transactionid, "merchantid": ''},
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
  token,
  transactionid,
  merchantid,
) async {
  final body = {"transaction_id": transactionid, "merchant_id": merchantid};

  final response = await http.post(
    Uri.parse(getTransaksiSingleRiwayatUrl),

    headers: {
      'token': token,
      "DEVICE-ID": identifier!,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  debugPrint('response body: ${response.body}');

  Map<String, dynamic> data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // log("ini data $data");
    printext = data['data']['raw'] ?? '';

    return data;
  } else {
    throw Exception('Failed to load data ${data}');
  }
}

Future<Map<String, dynamic>> getSinglePendapatanHarian(
  token,
  date,
  orderby,
  export,
  merchantid,
) async {
  final String jsonTest = json.encode(merchantid);
  final body = {
    "deviceid": identifier,
    "date": date,
    "orderby": orderby,
    "export": export,
    "merchantid": jsonTest,
  };

  final response = await http.post(
    Uri.parse(getSinglePendapatanHarianLink),
    body: body,
    headers: {'token': token},
  );

  Map<String, dynamic> data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    log("ini data $data");

    return data;
  } else {
    throw Exception('Failed to load data ${data}');
  }
}

Future<List<ProductModel>> getProductTransaksi(
  BuildContext context,
  String token,
  String name,
  List<String> merchid,
  String orderby,
) async {
  try {
    // Konversi list merchant ke JSON string
    final String jsonMerchId = json.encode(merchid);

    // Kirim request POST
    final response = await http.post(
      Uri.parse(getProductUrl),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: json.encode({
        "deviceid": identifier,
        "merchantid": merchid,
        "name": name,
        "is_active": true,
        "search": name,
        "order_by": orderby,
      }),
    );

    // Decode responsenya hanya sekali
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    // Logging untuk debug
    print('🔹 [Status Code] ${response.statusCode}');
    print('📦 [Response Body] $jsonResponse');

    if (response.statusCode == 200 && jsonResponse['rc'] == '00') {
      final data = jsonResponse['data'];
      if (data == null || data.isEmpty) {
        showSnackbar(context, "⚠️ Tidak ada data produk.");
        return [];
      }

      // Parsing ke model
      final List<ProductModel> result = (data as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      print("✅ Berhasil memuat ${result.length} produk");
      return result;
    } else {
      // Tangani error dari API
      final message = jsonResponse['message'] ?? 'Gagal memuat produk';
      showSnackbar(context, message);
      return [];
    }
  } catch (e, s) {
    // Tangani error jaringan / JSON
    print("❌ Error getProductTransaksi: $e");
    print(s);
    showSnackbar(context, "Terjadi kesalahan: $e");
    return [];
  }
}

Future getCoinTransaksi(
  BuildContext context,
  token,
  String name,
  List<String> merchid,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(getProductUrl),
    headers: {'token': token},
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

    print('ini response coin: ${response.body}');

    // print(data['data']['coin']);
    // print(jsonResponse['data']['coin'].toString());
    return jsonResponse['data'];
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
    headers: {'token': token},
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
    headers: {'token': token},
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
    headers: {'token': token},
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
    Uri.parse(laporanTokoExportUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "keyword": keyword,
      "orderby": orderby,
      "merchantid": jsonTest,
      "export": "pdf",
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
    headers: {'token': token},
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
  whenLoading(context);
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanProdukExportUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "keyword": keyword.toString(),
      "orderby": orderby.toString(),
      "merchantid": jsonTest,
      "export": export,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    closeLoading(context);
    print('succes');

    // print(jsonResponse.toString());

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanPembayaran(
  BuildContext context,
  token,
  List merchid,
  keyword,
  orderby,
  export,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanPembayaranUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchantid": jsonTest,
      "keyword": keyword.toString(),
      "orderby": orderby.toString(),
      "export": export,
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

Future getLaporanStok(
  BuildContext context,
  token,
  List merchid,
  keyword,
  orderby,
  export,
) async {
  print('export $export');
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanStokUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchantid": jsonTest,
      "keyword": keyword.toString(),
      "order_by": orderby.toString(),
      "export": export,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes get stok');

    // print(jsonResponse.toString());

    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getLaporanPergerakanInventori(
  BuildContext context,
  token,
  List merchid,
  keyword,
  orderby,
  export,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanPergerakanInventoriUrl),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: jsonEncode({
      "deviceid": identifier,
      "merchant_id": merchid,
      "keyword": keyword.toString(),
      "order_by": orderby.toString(),
      "export": export,
    }),
  );

  var jsonResponse = jsonDecode(response.body);
  // print('jsonResponse $jsonResponse');
  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future getPenggunaanProduk(
  BuildContext context,
  token,
  List merchid,
  keyword,
  orderby,
  inventory_master_id,
  export,
) async {
  final String jsonTest = json.encode(merchid);
  final response = await http.post(
    Uri.parse(laporanPenggunaanProdukUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchantid": jsonTest,
      "keyword": keyword.toString(),
      "inventory_master_id": "",
      "order_by": orderby.toString(),
      "export": export,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  print('response penggunaan produk');
  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    // print(data['data']['detail']['tanggal']);
    return data;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

var productPrice = 0, nameChart;

String? nameEditProduk,
    hargaEditProduk,
    hargaEditOnlineProduk,
    jenisProductEdit,
    kodejenisProductEdit,
    ppnEdit,
    tampilEdit,
    imageEdit;
Future getSingleProduct(
  BuildContext context,
  token,
  String merchid,
  productid,
  setState,
) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(getSingleProductUrl),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchantid": merchid,
      "productid": productid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  // log(jsonResponse.toString());
  if (response.statusCode == 200) {
    var dataku = jsonResponse['data'];
    // log("${dataku['name']}");
    log("dataku $dataku");

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
    return jsonResponse['rc'];
  } else {
    // print(jsonResponse['message'].toString());
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
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
    headers: {'token': token},
    body: {"deviceid": identifier, "id": id},
  );

  var jsonResponse = jsonDecode(response.body);
  log(jsonResponse.toString());
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
    tanggalAwalDiskon = dataku['start_date'] ?? '';
    tanggalAkhirDiskon = dataku['end_date'] ?? '';

    // log(productIdDiskon.toString());
    // productIdDiskon.clear();

    List<dynamic> products = dataku['products'];
    // for (var product in products) {
    //   String productId = product['productid'].toString();
    //   productIdDiskon.add(productId);
    // }

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
    statusEditAkunKasir,
    useridEditAkun,
    imageEditAkun;
Future getSingleAkun(BuildContext context, token, String userid) async {
  final response = await http.post(
    Uri.parse(getSingleAkunUrl),
    headers: {'token': token},
    body: {"deviceid": identifier, "userid": userid},
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
    statusEditAkunKasir = dataku['role'];

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
  BuildContext context,
  token,
  String merchid,
  voucherid,
  setState,
) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(getSinglePromosiUrl),
    headers: {'token': token},
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
    headers: {'token': token},
    body: {"deviceid": identifier, "typeotp": typeotp},
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
    headers: {'token': token},
    body: {"deviceid": identifier, "otp": otp, "typeotp": typeotp},
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
    headers: {'token': token},
    body: {"deviceid": identifier, "merchantid": merchantid},
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // print(jsonResponse.toString());
    Navigator.pop(context);

    showSnackBarComponent(
      context,
      jsonResponse['data']['message'],
      jsonResponse['rc'],
    );

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
    headers: {'token': token},
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
      context,
      jsonResponse['data']['message'],
      jsonResponse['rc'],
    );

    logoQris = jsonResponse['data']['qris'];

    return jsonResponse['rc'];
  } else {
    showSnackBarComponent(
      context,
      jsonResponse['data']['message'],
      jsonResponse['rc'],
    );
    print(jsonResponse['message'].toString());
  }
}

Future uploadStruk(BuildContext context, token, imageStruk, merchantid) async {
  final response = await http.post(
    Uri.parse(uploadStrukLink),
    headers: {'token': token},
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
      context,
      jsonResponse['data']['message'],
      jsonResponse['rc'],
    );

    logoStruk = jsonResponse['data']['struk'];
    logoStrukPrinter = jsonResponse['data']['struk_printer'];
    getStruk(context, token, merchantid);
    return jsonResponse['rc'];
  } else {
    showSnackBarComponent(
      context,
      jsonResponse['data']['message'],
      jsonResponse['rc'],
    );
  }
}

Future getStruk(BuildContext context, token, merchantid) async {
  final response = await http.post(
    Uri.parse(getStrukLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "merchantid": merchantid},
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
      context,
      jsonResponse['data']['message'] ?? jsonResponse['data']['data'],
      jsonResponse['rc'],
    );
  }
}

Future deleteStruk(BuildContext context, token, merchantid) async {
  final response = await http.post(
    Uri.parse(deleteStrukLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "merchantid": merchantid},
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    logoStruk = '';
    logoStrukPrinter = '';
    getStruk(context, token, merchantid);

    Navigator.pop(context);

    showSnackBarComponent(
      context,
      jsonResponse['data']['message'],
      jsonResponse['rc'],
    );

    return jsonResponse['rc'];
  } else {}
}

Future transaksiViewReference(
  BuildContext context,
  token,
  transactionid,
) async {
  final response = await http.post(
    Uri.parse(transaksiViewReferenceLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "transactionid": transactionid},
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
    headers: {'token': token},
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
    // closeLoading(context);
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

Future getCOAPayment(BuildContext context, token, category, orderby) async {
  final response = await http.post(
    Uri.parse(getCoaMethodLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "category": category,
      // "orderby": orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    // print(jsonResponse.toString());

    final List<PaymentMethod> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = PaymentMethod.fromJson(item);
      result.add(model);

      // print(model.toJson());
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future createCOA(
  BuildContext context,
  token,
  paymentMethod,
  accountNumber,
) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(addCoaLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "paymentMethod": paymentMethod,
      "accountNumber": accountNumber,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse.toString());

    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future updateCOA(
  BuildContext context,
  token,
  idPaymentMethod,
  paymentMethod,
  accountNumber,
) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(updateCoaLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "idPaymentMethod": idPaymentMethod,
      "paymentMethod": paymentMethod,
      "accountNumber": accountNumber,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse.toString());

    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

Future deleteCOA(BuildContext context, token, idPaymentMethod) async {
  whenLoading(context);
  String jsonData = jsonEncode(idPaymentMethod);
  final response = await http.post(
    Uri.parse(deleteCoaLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "idPaymentMethod": jsonData},
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
    print(jsonResponse.toString());

    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    showSnackbar(context, jsonResponse);
  }
}

String coaValueKredit = '', coaValueDebit = '', coaValueEWallet = '';
Future<List<PaymentMethod>> fetchPaymentMethods(token, category) async {
  final response = await http.post(
    Uri.parse(getCoaMethodLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "category": category},
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    List<dynamic> jsonData = jsonResponse['data'];

    if (category == 'Kredit') {
      jsonData.isEmpty ? coaValueKredit = 'null' : '';
    } else if (category == 'Debit') {
      jsonData.isEmpty ? coaValueDebit = 'null' : '';
    } else if (category == 'EWallet') {
      jsonData.isEmpty ? coaValueEWallet = 'null' : '';
    }
    return jsonData.map((data) => PaymentMethod.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load payment methods');
  }
}

Future getAdjustment(token, merchid, String name, orderby) async {
  final response = await http.post(
    Uri.parse(getAdjustmentLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchant_id": merchid,
      // "name": name,
      // "orderby": orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  log(jsonResponse.toString());
  if (response.statusCode == 200) {
    // print('kuontol');

    final List<PenyesuaianModel> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = PenyesuaianModel.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

Future getMasterData(token, merchid, String name, orderby) async {
  final response = await http.post(
    Uri.parse(getMasterDataLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchant_id": merchid,
      "name": name,
      "orderby": orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  // print('ini ada response master data: ${response.body}');
  if (response.statusCode == 200) {
    // print('succes');

    final List<ModelDataInventori> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = ModelDataInventori.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

Future createMasterData(context, token, merchid, nameItem, unit) async {
  final response = await http.post(
    Uri.parse(createMasterDataLink),
    headers: {'token': token},
    body: {
      "name_item": nameItem,
      "unit": unit,
      // "merchant_id": "913eb0b0-f8ac-4639-b520-7ee012fe0618"
      "merchant_id": merchid,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future updateMasterData(context, token, id, nameItem) async {
  final response = await http.post(
    Uri.parse(updateMasterDataLink),
    headers: {'token': token},
    body: {"inventory_master_id": id, "name_item": nameItem},
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future deleteMasterData(
  context,
  String token,
  List<String> productid, // Pastikan ini List<String>
) async {
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    'inventory_master_id':
        productid, // Pastikan tetap List, jangan jsonEncode sendiri
  };

  try {
    final response = await http.post(
      Uri.parse(deleteMasterDataLink),
      headers: {
        'Content-Type': 'application/json', // Wajib ada untuk JSON
        'token': token,
      },
      body: jsonEncode(requestBody), // Encode seluruh requestBody
    );

    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      closeLoading(context);
      print(jsonResponse['message'].toString());
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      print("Error: ${jsonResponse['message']}");
      showSnackbar(context, jsonResponse);
    }
  } catch (e) {
    closeLoading(context);
    print("Exception: $e");
    showSnackbar(context, {"message": "Terjadi kesalahan saat menghapus data"});
  }
}

Future deleteAdjustment(
  context,
  token,
  List<String> productid, // Pastikan bertipe List<String>
) async {
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "group_id": productid, // Tetap List, jangan jsonEncode sendiri
  };

  final response = await http.post(
    Uri.parse(deleteAdjustmentLink),
    headers: {
      'Content-Type': 'application/json', // Tambahkan Content-Type
      'token': token,
    },
    body: jsonEncode(requestBody), // Encode seluruh requestBody
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future deletePembelian(
  context,
  token,
  List<String> productid, // Pastikan ini adalah List<String>
) async {
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "group_id": productid, // Biarkan tetap List, jangan di-jsonEncode sendiri
  };

  final response = await http.post(
    Uri.parse(deleteDetailPurchaseLink),
    headers: {
      'Content-Type': 'application/json', // Pastikan ini ada
      'token': token,
    },
    body: jsonEncode(requestBody), // Encode seluruh requestBody
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future<List<Unit>> getUnitMaster(String token) async {
  try {
    final response = await http.post(
      Uri.parse(getUnitMasterDataLink),
      headers: {'token': token},
      body: {"deviceid": identifier},
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var dataList = jsonResponse['data'] as List<dynamic>;

      List<Unit> units = dataList.map((unit) => Unit.fromJson(unit)).toList();

      return units;
    } else {
      print('Failed to fetch unit data');
      return [];
    }
  } catch (e) {
    log('Error in getUnitMaster: $e');
    return [];
  }
}

Future getBOM(token, merchid, String name, orderby) async {
  final response = await http.post(
    Uri.parse(getBOMLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchant_id": merchid,
      "name": name,
      "order_by": orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  log(jsonResponse.toString());
  if (response.statusCode == 200) {
    final List<BOMModel> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = BOMModel.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

String judulUbahBOM = '', produkNameBom = '';
TextEditingController searchProductIDUbah = TextEditingController();

TextEditingController ubahJudulBOMController = TextEditingController();
TextEditingController ubahProdukBOM = TextEditingController();
String ubahProdukBOMid = '', productMaterialIdUbah = '';

List<Map<String, dynamic>> orderBOMInventoryUbah = [];

Future<Map<String, Map<String, dynamic>>> getSingleBOMSelected(
  BuildContext context,
  String token,
  String merchId,
  String materialId,
) async {
  whenLoading(context);

  final Map<String, String> body = {
    "deviceid": identifier!,
    "merchant_id": merchId,
    "product_material_id": materialId,
  };

  final response = await http.post(
    Uri.parse(getSingleBOMLink),
    headers: {'token': token},
    body: body,
  );

  if (response.statusCode == 200) {
    closeLoading(context);
    final Map<String, dynamic> decoded = jsonDecode(response.body);

    judulUbahBOM = decoded['data']['title'];
    produkNameBom = decoded['data']['product_name'];
    ubahProdukBOMid = decoded['data']['product_id'];
    final List<dynamic> detailList = decoded['data']['detail'] ?? [];

    editPesananInventory.clear();
    editHargaInventory.clear();

    final Map<String, Map<String, dynamic>> selectedMap = {};

    for (var item in detailList) {
      final String masterId = item['id'];
      selectedMap[masterId] = {
        "bom_detail_id": item['id'],
        "inventory_master_id": masterId,
        "name": item['item_name'],
        "unit_name": item['unit_name'],
        "qty": double.parse(item['quantity_needed']).toString(),
        "unit_conversion_id": item['unit_conversion_id'] ?? '',
        "unit_factor": item['unit_conversion_factor'] ?? '',
      };
    }
    selectedDataPemakaian = selectedMap;
    orderInventory = selectedDataPemakaian.values.toList();

    return selectedMap;
  } else {
    closeLoading(context);
    final jsonResponse = jsonDecode(response.body);
    print('Error: ${jsonResponse['message']}');
    showSnackbar(context, jsonResponse);
    return {};
  }
}

Future<List<UnitConvertionModel>> getUnitConvertion(
  String token,
  String merchid,
  String name,
  String orderby,
) async {
  try {
    final Map<String, String> body = {
      "deviceid": identifier!,
      "merchid": merchid,
    };

    final response = await http.post(
      Uri.parse(getUnitConvertionLink),
      headers: {'token': token},
      body: body,
    );
    // log('get unit coy: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded['data'] != null && decoded['data'] is List) {
        final List<UnitConvertionModel> result = decoded['data']
            .map<UnitConvertionModel>(
              (item) => UnitConvertionModel.fromJson(item),
            )
            .toList();

        // log('Hasil getUnitConvertion = ${response.body}');
        return result;
      } else {
        log('Data kosong / format tidak sesuai');
        return [];
      }
    } else {
      log('Error: ${response.statusCode} - ${response.body}');
      return [];
    }
  } catch (e) {
    log('Exception di getUnitConvertion: $e');
    return [];
  }
}

TextEditingController nameUnitConUbah = TextEditingController();
TextEditingController faktorConUnitUbah = TextEditingController();

Future<List<UnitConvertionModel>> getSingleUnitConvertion(
  String token,
  String merchid,
  String unitId,
  context,
) async {
  try {
    whenLoading(context);
    final Map<String, String> body = {
      "deviceid": identifier!,
      "unit_conversion_id": unitId,
      "merchant_id": merchid,
    };

    // log('Request Body: $body');

    final response = await http.post(
      Uri.parse(getSingleUnitConvertionLink),
      headers: {'token': token},
      body: body,
    );

    print('Response get single unit: ${response.body}');

    var jsonResponse = jsonDecode(response.body);
    var data = jsonResponse['data'];

    nameUnitConUbah.text = data['name'];
    double conversionFactor = double.parse(data['conversion_factor']);
    faktorConUnitUbah.text = conversionFactor.toStringAsFixed(2);

    if (response.statusCode == 200) {
      closeLoading(context);
      return [];
    } else {
      log('Error: ${response.statusCode} - ${response.body}');
      closeLoading(context);
      return [];
    }
  } catch (e) {
    log('Exception di getUnitConvertion: $e');
    return [];
  }
}

Future createUnitConvertion(
  context,
  token,
  merchantId,
  name,
  faktorConvertion,
) async {
  // Tampilkan loading
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "merchant_id": merchantId,
    "name": name,
    "conversion_factor": faktorConvertion,
  };

  // Kirim POST request dengan body dalam format JSON
  final response = await http.post(
    Uri.parse(createUnitConvertionLink),
    headers: {
      // 'Content-Type': 'application/json',
      'token': token,
    },
    body: requestBody,
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future updateUnitConvertion(
  context,
  token,
  merchantId,
  unitId,
  name,
  inventoryMasterId,
  faktorConvertion,
) async {
  // Tampilkan loading
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "merchant_id": merchantId,
    'unit_conversion_id': unitId,
    "name": name,
    "inventory_master_id": inventoryMasterId,
    "conversion_factor": faktorConvertion,
  };

  // Kirim POST request dengan body dalam format JSON
  final response = await http.post(
    Uri.parse(updateUnitConvertionLink),
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode(requestBody),
  );

  log('lihat $requestBody');

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success Update Unit');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future deleteUNIT(
  context,
  token,
  List<String> unitID,
  // bomId,
  merchid,
) async {
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "merchant_id": merchid,
    "unit_conversion_id": unitID,
  };

  final response = await http.post(
    Uri.parse(deleteUnitConvertionLink),
    headers: {
      'Content-Type': 'application/json', // Tambahkan Content-Type
      'token': token,
    },
    body: jsonEncode(requestBody),
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future createBOM(
  context,
  token,
  merchantId,
  title,
  productId,
  List<dynamic> orderInventory, // Pastikan ini bertipe List
) async {
  // Tampilkan loading
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "title": title,
    "merchant_id": merchantId,
    "product_id": productId,
    "detail": orderInventory, // Tidak perlu jsonEncode di sini
  };

  // Kirim POST request dengan body dalam format JSON
  final response = await http.post(
    Uri.parse(createBOMLink),
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode(requestBody), // Encode seluruh requestBody di sini
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future updateBOM(
  context,
  token,
  productMaterialId,
  title,
  merchantId,
  productId,
  List<dynamic> orderInventory,
) async {
  // Tampilkan loading
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "product_material_id": productMaterialId,
    "title": title,
    "merchant_id": merchantId,
    "product_id": productId,
    "detail": orderInventory,
  };

  // Kirim POST request dengan body dalam format JSON
  final response = await http.post(
    Uri.parse(updateBOMLink),
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode(requestBody), // Encode seluruh requestBody di sini
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future deleteBOM(
  context,
  token,
  List<String> bomId,
  // bomId,
  merchid,
) async {
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "merchant_id": merchid,
    "product_material_id": bomId,
  };

  final response = await http.post(
    Uri.parse(deleteBOMLink),
    headers: {
      'Content-Type': 'application/json', // Tambahkan Content-Type
      'token': token,
    },
    body: jsonEncode(requestBody),
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    Navigator.of(context).popUntil((route) => route.isFirst);
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

late String idBahan, name_itemBahan, unit_idBahan, unit_nameBahan;

Future getSingleMasterData(context, token, productid) async {
  final response = await http.post(
    Uri.parse(getMasterDataSingleLink),
    headers: {'token': token},
    body: {'inventory_master_id': productid},
  );

  var jsonResponse = jsonDecode(response.body);
  var data = jsonResponse['data'];
  if (response.statusCode == 200) {
    print(data);
    closeLoading(context);
    idBahan = data['id'];
    name_itemBahan = data['name_item'];
    unit_idBahan = data['unit_id'];
    unit_nameBahan = data['unit_name'];

    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future<Map<String, dynamic>?> getSingleDetailMasterData(
  BuildContext context,
  String token,
  String productid,
) async {
  try {
    final response = await http.post(
      Uri.parse(getMasterDataSingleDetailLink),
      headers: {'token': token},
      body: {'item_id': productid},
    );

    if (response.statusCode == 200) {
      final rawJson = jsonDecode(response.body);
      final Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(
        rawJson,
      );

      if (jsonResponse.containsKey('data')) {
        return jsonResponse;
      } else {
        showSnackbar(context, 'Format response tidak sesuai.');
        return null;
      }
    } else {
      final errorJson = Map<String, dynamic>.from(jsonDecode(response.body));
      final message = errorJson['message'] ?? 'Terjadi kesalahan.';
      showSnackbar(context, message);
      return null;
    }
  } catch (e) {
    showSnackbar(context, 'Gagal terhubung ke server: $e');
    return null;
  }
}

Future getPembelian(token, merchid, name, orderby) async {
  final response = await http.post(
    Uri.parse(getPurchaseLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "merchant_id": merchid,
      // "name": name,
      // "orderby": orderby,
    },
  );

  var jsonResponse = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('succes');

    final List<PembelianModel> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      final model = PembelianModel.fromJson(item);
      result.add(model);
    }

    return result;
  } else {
    print(jsonResponse['message'].toString());
    // showSnackbar(context, jsonResponse);
  }
}

late String titlePenyesuaianUbah = '', groupIdInventoryPenyesuaianUbah = '';

List<Map<String, dynamic>> orderInventoryPenyesuaian = [];
Map<String, Map<String, dynamic>> selectedDataPemakaianPenyesuaian = {};

Future<Map<String, Map<String, dynamic>>> getSelectedDataPenyesuaian(
  BuildContext context,
  String token,
  String groupid,
) async {
  whenLoading(context);
  final response = await http.post(
    Uri.parse(getDetailAdjustmentLink),
    headers: {
      'token': token,
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {"deviceid": identifier, "group_id": groupid},
  );

  if (response.statusCode == 200) {
    closeLoading(context);
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    print('Success fetch selectedDataPemakaian ${response.body}');
    final List<dynamic> detailList = decoded['data']['detail'];
    titlePenyesuaianUbah = decoded['data']['title'];
    // Clear isi controller sebelumnya
    editPesananInventory.clear();
    editHargaInventory.clear();

    final Map<String, Map<String, dynamic>> selectedMap = {};

    for (var item in detailList) {
      final String itemId = item['item_id'];
      final String qty = double.parse(
        item['qty_after_activity'].toString(),
      ).toInt().toString();
      final String price = double.parse(
        item['price'].toString(),
      ).toInt().toString();

      selectedMap[itemId] = {
        "inventory_master_id": itemId,
        "name": item['name_item'],
        "category": item['unit_conversion_name'] ?? item['unit_name'],
        "unit_conversion_id": item['unit_conversion_id'],
        "qty": qty,
        "price": price,
      };

      // Tambahkan ke List controller
      editPesananInventory.add(TextEditingController(text: qty));
      editHargaInventory.add(TextEditingController(text: price));
    }

    selectedDataPemakaian =
        selectedMap; // Update selectedDataPemakaian dengan selectedMap

    // Update orderInventory dengan values dari selectedDataPemakaian
    orderInventory = selectedDataPemakaian.values.toList();

    return selectedMap;
  } else {
    closeLoading(context);
    final jsonResponse = jsonDecode(response.body);
    print('Error: ${jsonResponse['message']}');
    showSnackbar(context, jsonResponse);
    return {};
  }
}

Future<List<DetailItem>> getDetailPenyesuian(
  context,
  String token,
  String groupid,
) async {
  // whenLoading(context);
  final response = await http.post(
    Uri.parse(getDetailAdjustmentLink),
    headers: {
      'token': token,
      // 'Accept': 'application/json',
      // 'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {"deviceid": identifier, "group_id": groupid},
  );

  if (response.statusCode == 200) {
    debugPrint('Success fetch detail pembelian ${response.body}');
    final decoded = jsonDecode(response.body);

    titlePenyesuaianUbah = decoded['data']['title'];
    tanggalAwalInventoryUbah = decoded['data']['date'];
    final List<dynamic> detailListUbah = decoded['data']['detail'];

    final List<DetailItem> result = detailListUbah
        .map((item) => DetailItem.fromJson(item))
        .toList();

    return result;
  } else {
    // closeLoading(context);
    final jsonResponse = jsonDecode(response.body);
    print('Error: ${jsonResponse['message']}');
    showSnackbar(context, jsonResponse);
    return []; // atau lempar error
  }
}

Future<List<ProdukMaterialModel>> getDetailBom(
  BuildContext context,
  String token,
  String productId,
) async {
  final response = await http.post(
    Uri.parse(getSingleBOMLink),
    headers: {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {"deviceid": identifier!, "product_material_id": productId},
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    judulUbahBOM = decoded['data']['title'];
    produkNameBom = decoded['data']['product_name'];
    ubahProdukBOMid = decoded['data']['product_id'];

    if (decoded['rc'] == '00') {
      titlePenyesuaianUbah = decoded['data']['title'];
      tanggalAwalInventoryUbah = decoded['data']['date'] ?? '';

      // Mengambil data 'details' dan memetakannya ke model ProdukMaterialModel
      final List<dynamic> detailListUbah = decoded['data']['detail'];

      // Parsing ke dalam List<ProdukMaterialModel>
      final List<ProdukMaterialModel> result = detailListUbah
          .map((item) => ProdukMaterialModel.fromJson(item))
          .toList();
      // print('Success fetch produk materiala: ${result}');

      return result;
    } else {
      print('Error: ${decoded['message']}');
      showSnackbar(context, {"message": decoded['message']});
      return []; // Kembalikan list kosong jika ada error pada response
    }
  } else {
    // Handle error jika statusCode tidak 200
    final jsonResponse = jsonDecode(response.body);
    print('Error: ${jsonResponse['message']}');
    showSnackbar(context, jsonResponse);
    return []; // Kembalikan list kosong jika gagal
  }
}

late String groupIdInventoryUbah = '',
    titleInventoryUbah = '',
    dateInventoryUbah = '',
    tanggalAwalInventoryUbah = '',
    tanggalAkhirInventoryUbah = '';

// late List<dynamic> detailListUbahFIX = [];

Future<List<DetailItem>> getDetailPembelian(
  context,
  String token,
  String groupid,
) async {
  final response = await http.post(
    Uri.parse(getDetailPurchaseLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "group_id": groupid},
  );

  if (response.statusCode == 200) {
    log('Success fetch detail pembelian ${response.body}');
    final decoded = jsonDecode(response.body);
    titleInventoryUbah = decoded['data']['title'];
    tanggalAwalInventoryUbah = decoded['data']['date'];
    final List<dynamic> detailListUbah = decoded['data']['detail'];

    final List<DetailItem> result = detailListUbah
        .map((item) => DetailItem.fromJson(item))
        .toList();

    return result;
  } else {
    showSnackbar(context, {"message": "Gagal mengambil data"});
    return [];
  }
}

List<TextEditingController> editPesananInventory = List.empty(growable: true);
List<TextEditingController> editHargaInventory = List.empty(growable: true);

List<Map<String, dynamic>> orderInventory = [];
Map<String, Map<String, dynamic>> selectedDataPemakaian = {};

Future<Map<String, Map<String, dynamic>>> getSelectedDataPemakaian(
  BuildContext context,
  String token,
  String groupid,
) async {
  final response = await http.post(
    Uri.parse(getDetailPurchaseLink),
    headers: {
      'token': token,
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {"deviceid": identifier, "group_id": groupid},
  );

  if (response.statusCode == 200) {
    print('Success fetch selectedDataPemakaian');
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final List<dynamic> detailList = decoded['data']['detail'];

    // Clear isi controller sebelumnya
    editPesananInventory.clear();
    editHargaInventory.clear();

    final Map<String, Map<String, dynamic>> selectedMap = {};

    for (var item in detailList) {
      final String itemId = item['item_id'];
      final String qty = double.parse(
        item['qty'].toString(),
      ).toInt().toString();
      final String price = double.parse(
        item['price'].toString(),
      ).toInt().toString();

      selectedMap[itemId] = {
        "inventory_master_id": itemId,
        "name": item['name_item'],
        "category": item['unit_conversion_name'] ?? item['unit_name'],
        "unit_conversion_id": item['unit_conversion_id'] ?? '',
        "qty": qty,
        "price": price,
      };

      // Tambahkan ke List controller
      editPesananInventory.add(TextEditingController(text: qty));
      editHargaInventory.add(TextEditingController(text: price));
    }

    selectedDataPemakaian =
        selectedMap; // Update selectedDataPemakaian dengan selectedMap

    // Update orderInventory dengan values dari selectedDataPemakaian
    orderInventory = selectedDataPemakaian.values.toList();

    return selectedMap;
  } else {
    final jsonResponse = jsonDecode(response.body);
    print('Error: ${jsonResponse['message']}');
    showSnackbar(context, jsonResponse);
    return {};
  }
}

Future<List<Map<String, dynamic>>> getMasterDataToko(
  BuildContext context,
  String token,
  String merchid,
  name,
  orderby,
) async {
  final response = await http.post(
    Uri.parse(getMasterDataLink),
    headers: {'token': token},
    body: {
      "merchant_id": merchid,
      // "isMinimize": false,
      "name": "",
      "order_by": "",
    },
  );

  final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  // log('Request body: merchant_id: $merchid, name: $name, order_by: $orderby');
  // log('$jsonResponse');
  if (response.statusCode == 200) {
    print("Success: Data fetched master ${response.body}");

    // Parse JSON response

    if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
      final List<Map<String, dynamic>> inventoryData =
          List<Map<String, dynamic>>.from(jsonResponse['data']);
      return inventoryData;
    } else {
      throw Exception("Invalid data format");
    }
  } else {
    print("Error: ${response.statusCode} - ${response.body}");
    showSnackbar(context, jsonResponse);
    return [];
  }
}

Future createPembelian(
  context,
  token,
  date,
  judulPembelian,
  List<dynamic> orderInventory, // Pastikan ini bertipe List
) async {
  // Tampilkan loading
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "title": judulPembelian,
    "date": date,
    "order_inventory": orderInventory, // Tidak perlu jsonEncode di sini
  };

  // Kirim POST request dengan body dalam format JSON
  final response = await http.post(
    Uri.parse(createDetailPurchaseLink),
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode(requestBody),
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future updatePembelian(
  context,
  token,
  groupId,
  date,
  judulPembelian,
  List<dynamic> orderInventory, // Pastikan ini bertipe List
) async {
  // Tampilkan loading
  print(groupId);
  print('hello $orderInventory');
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "group_id": groupId,
    "title": judulPembelian,
    "date": date,
    "order_inventory": orderInventory, // Tidak perlu jsonEncode di sini
  };

  // Kirim POST request dengan body dalam format JSON
  final response = await http.post(
    Uri.parse(updateDetailPurchaseLink),
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode(requestBody), // Encode seluruh requestBody di sini
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future updatePenyesuaian(
  context,
  token,
  groupId,
  date,
  judulPenyesuaian,
  List<dynamic> usageInventory, // Pastikan ini bertipe List
) async {
  // Tampilkan loading
  print(groupId);
  print('hello $usageInventory');
  whenLoading(context);

  final Map<String, dynamic> requestBody = {
    "deviceid": identifier,
    "group_id": groupId,
    "date": date,
    "title": judulPenyesuaian,
    "usage_inventory": usageInventory,
  };

  // Kirim POST request dengan body dalam format JSON
  final response = await http.post(
    Uri.parse(updateAdjustmentLink),
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode(requestBody), // Encode seluruh requestBody di sini
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

Future createPenyesuaian(
  context,
  token,
  date,
  judulPenyesuaian,
  List<Map<String, dynamic>> usage_inventory,
) async {
  // Tampilkan loading
  whenLoading(context);
  final Map<String, dynamic> requestBody = {
    "date": date,
    "title": judulPenyesuaian,
    "usage_inventory": usage_inventory,
  };

  // Debugging: Lihat data yang dikirim
  // print(usage_inventory);
  print('Request Body: ${jsonEncode(requestBody)}');

  // Kirim POST request
  final response = await http.post(
    Uri.parse(createAdjustmentLink),
    headers: {'token': token, 'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );
  print('Response Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');
  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  try {
    if (response.statusCode == 200) {
      closeLoading(context);
      print('Success');
      showSnackbar(context, jsonResponse);
      return jsonResponse['rc'];
    } else {
      closeLoading(context);
      print(jsonResponse['message'].toString());

      showSnackbar(context, jsonResponse);
    }
  } catch (e) {
    // closeLoading(context);
    showSnackbar(context, 'Terjadi kesalahan: $e');
  }
}

Future upadatePenyesuaian(
  context,
  token,
  date,
  judulPenyesuaian,
  usage_inventory,
) async {
  // Tampilkan loading
  whenLoading(context);
  String jsonData = jsonEncode(usage_inventory);

  // Debugging: Lihat data yang dikirim
  print(usage_inventory);

  // Kirim POST request
  final response = await http.post(
    Uri.parse(updateAdjustmentLink),
    headers: {'token': token},
    body: {
      "deviceid": identifier,
      "title": judulPenyesuaian,
      "date": date,
      "usage_inventory": jsonData,
    },
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');
    showSnackbar(context, jsonResponse);
    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

List<Map<String, dynamic>> orderInventoryEdit = [];
String dateEdit = '';
String titleEdit = '';

Future getSinglePenyesuaian(context, token, groupId) async {
  // Tampilkan loading
  whenLoading(context);

  // Kirim POST request
  final response = await http.post(
    Uri.parse(updateAdjustmentLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "group_id": groupId},
  );

  var jsonResponse = jsonDecode(response.body);

  // Handle responsenya
  if (response.statusCode == 200) {
    closeLoading(context);
    print('Success');

    // Ekstrak data dari respons
    var data = jsonResponse['data'];

    // Masukkan nilai title dan date ke dalam variabel
    titleEdit = data['title']; // Ambil nilai 'title'
    dateEdit = data['date']; // Ambil nilai 'date'

    // Cetak nilai untuk memastikan data sudah masuk
    // print('Title: $titleEdit');
    // print('Date: $dateEdit');
    print('Dataku: $data');

    // Ekstrak detail jika diperlukan
    var detail = data['detail'] ?? []; // Ambil array 'detail' dari 'data'

    // Masukkan data ke dalam orderInventoryEdit
    List<Map<String, dynamic>> orderInventoryEdit = [];
    for (var item in detail) {
      orderInventoryEdit.add({
        'group_id': item['group_id'],
        'item_id': item['item_id'],
        'name_item': item['name_item'],
        'unit_id': item['unit_id'],
        'unit_name': item['unit_name'],
        'unit_abbreviation': item['unit_abbreviation'],
        'unit_conversion_name': item['unit_conversion_name'],
        'qty': item['qty'],
        'qty_after_activity': item['qty_after_activity'],
        'price': item['price'],
        'activity_type': item['activity_type'],
        'is_approved': item['is_approved'],
        'approved_at': item['approved_at'],
      });
    }

    // Cetak orderInventoryEdit untuk memastikan data sudah masuk
    print(orderInventoryEdit);

    return jsonResponse['rc'];
  } else {
    closeLoading(context);
    print(jsonResponse['message'].toString());
    showSnackbar(context, jsonResponse);
  }
}

late String bindingUrl = '';
Future getKulasedaya(
  context,
  token,
  /*  */
  merchid,
) async {
  final response = await http.post(
    Uri.parse(getkulasedayaLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "merchant_id": merchid},
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    bindingUrl = jsonResponse['data']['binding_url'];

    return jsonResponse;
  }
}

Future deleteTagihanKulasedaya(context, token, idRequest) async {
  final String jsonTest = json.encode(idRequest);
  final response = await http.post(
    Uri.parse(deletekulasedayaTagihanLink),
    headers: {'token': token},
    body: {"deviceid": identifier, "idRequest": jsonTest},
  );

  var jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200) {
    print("berhasil menghapus!");
    return jsonResponse;
  }
}

Future<List<TipeUsahaModel>> getTipeUsaha(String token) async {
  final res = await http.post(
    Uri.parse(getTipeUsahaLink),
    headers: {'token': token},
    body: {'deviceid': identifier},
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['rc'] == '00') {
      return (data['data'] as List)
          .map((e) => TipeUsahaModel.fromJson(e))
          .toList();
    }
  }
  return [];
}

Future<List<WilayahModel>> getProvinsi(String token) async {
  final res = await http.post(
    Uri.parse(getProvinsiLink),
    headers: {'token': token},
    body: {'deviceid': identifier},
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['rc'] == '00') {
      return (data['data'] as List)
          .map((e) => WilayahModel.fromJson(e))
          .toList();
    }
  }
  return [];
}

Future<List<WilayahModel>> getKabupaten(String token, String provID) async {
  final res = await http.post(
    Uri.parse(getRegenciesLink),
    headers: {'token': token},
    body: {'deviceid': identifier, 'province': provID},
  );
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['rc'] == '00') {
      return (data['data'] as List)
          .map((e) => WilayahModel.fromJson(e))
          .toList();
    }
  }
  return [];
}

Future<List<WilayahModel>> getKecamatan(String token, String kabID) async {
  final res = await http.post(
    Uri.parse(getDistrictLink),
    headers: {'token': token},
    body: {'deviceid': identifier, 'regencies': kabID},
  );
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['rc'] == '00') {
      return (data['data'] as List)
          .map((e) => WilayahModel.fromJson(e))
          .toList();
    }
  }
  return [];
}

Future<List<WilayahModel>> getKelurahan(String token, String kecID) async {
  final res = await http.post(
    Uri.parse(getVillageLink),
    headers: {'token': token},
    body: {'deviceid': identifier, 'district': kecID},
  );
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['rc'] == '00') {
      return (data['data'] as List)
          .map((e) => WilayahModel.fromJson(e))
          .toList();
    }
  }
  return [];
}
