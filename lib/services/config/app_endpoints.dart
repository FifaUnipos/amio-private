// Lalu ganti semua variabel lama dengan ApiEndpoints.namaVariabel
// Contoh:
//   Uri.parse(calculateTransaksiUrl)  →  Uri.parse(ApiEndpoints.calculateTransaksiUrl)
//   Uri.parse(getVariantLink)         →  Uri.parse(ApiEndpoints.getVariantLink)

import 'app_config.dart';

class ApiEndpoints {
  // Private constructor — class ini tidak boleh di-instantiate
  ApiEndpoints._();

  static const String _base = AppConfig.baseUrl;

  // ─── Base URL (untuk yang masih pakai `url` langsung) ────
  static const String url = _base;

  // ─── Auth ────────────────────────────────────────────────
  static const String registerbyotp = '$_base/api/user/registerbyotp';
  static const String registerentryotp = '$_base/api/register/verify';
  static const String registerLink = '$_base/api/register';
  static const String loginEmailLink = '$_base/api/login';
  static const String loginbyotp = '$_base/api/user/loginbyotp';
  static const String loginentryotp = '$_base/api/user/loginentryotp';
  static const String checkpass = '$_base/api/user/checkPassword';
  static const String forgotPassRequestLink =
      '$_base/api/forgot-password/request';
  static const String forgotPassRequestOtpLink =
      '$_base/api/forgot-password/request/otp';
  static const String forgotPassVerifyLink =
      '$_base/api/forgot-password/verify';
  static const String forgotPassChangeLink =
      '$_base/api/forgot-password/change';

  // ─── Profile ─────────────────────────────────────────────
  static const String myaccout = '$_base/api/profile/myaccount';
  static const String changeProfileName = '$_base/api/profile/change';
  static const String changeImage = '$_base/api/profile/upload/image';
  static const String changeProfilePhone =
      '$_base/api/profile/changephonenumber';
  static const String changeProfilePhoneOtp =
      '$_base/api/profile/changenumberentryotp';

  // ─── Dashboard ───────────────────────────────────────────
  static const String dashboardNumber = '$_base/api/user/dashboardNumber';
  static const String dashboardChart = '$_base/api/v2/user/dashboard/gross';
  static const String dashboardCheckBilling = '$_base/api/v2/billing/check';
  static const String dashboardChartPendapatan =
      '$_base/api/v2/user/dashboard/nett';

  // ─── Merchant ────────────────────────────────────────────
  static const String createMerchan = '$_base/api/merchant/create';
  static const String deleteMerchan = '$_base/api/merchant/delete';
  static const String getMerch = '$_base/api/merchant';
  static const String getSingleMerchant = '$_base/api/merchant/single';
  static const String updateMerchant = '$_base/api/merchant/update';
  static const String getAllAkun = '$_base/api/merchant/account';

  // ─── Transaksi ───────────────────────────────────────────
  static const String createTransaksiUrl = '$_base/api/v2/transaction/create';
  static const String deleteTransaksiUrl = '$_base/api/transaction/delete';
  static const String approveTransaksiUrl =
      '$_base/api/transaction/approve/reference';
  static const String calculateTransaksiUrl =
      '$_base/api/v2/transaction/calculating';
  static const String getTransaksiRiwayatUrl = '$_base/api/v2/transaction/';
  static const String getTransaksiSingleRiwayatUrl =
      '$_base/api/v2/transaction/receipt';
  static const String transaksiViewReferenceLink =
      '$_base/api/transaction/view/reference';
  static const String headerTagihanUrl =
      '$_base/api/transaction/create/reference/tagihan';
  static const String deleteTagihanUrl =
      '$_base/api/transaction/delete/reference/tagihan';

  // ─── Produk ──────────────────────────────────────────────
  static const String createProdukUrl = '$_base/api/product/create';
  static const String updateProdukUrl = '$_base/api/product/update';
  static const String deleteProdukUrl = '$_base/api/product/delete';
  static const String uploadProdukUrl = '$_base/api/product/upload';
  static const String getProductUrl = '$_base/api/v2/product';
  static const String getSingleProductUrl = '$_base/api/product/single';
  static const String changeActiveUrl = '$_base/api/product/changeActive';
  static const String changePpnUrl = '$_base/api/product/changePPN';

  // ─── Variant Produk ──────────────────────────────────────
  static const String getVariantLink = '$_base/api/product-variant';
  static const String createVariantLink = '$_base/api/product-variant/resource';

  // ─── Kategori ────────────────────────────────────────────
  static const String getKategoriUrl = '$_base/api/kategori/getdata';
  static const String tambahKategoriLink = '$_base/api/typeproduct/store';
  static const String ubahKategoriLink = '$_base/api/typeproduct/update';
  static const String hapusKategoriLink = '$_base/api/typeproduct/delete';
  static const String getKategoriLink = '$_base/api/typeproduct';
  static const String tipeUsaha = '$_base/api/tipeusaha';
  static const String getTipeUsahaLink = '$_base/api/tipeusaha';

  // ─── Pelanggan / Member ──────────────────────────────────
  static const String createPelangganUrl = '$_base/api/member/create';
  static const String editPelangganUrl = '$_base/api/member/edit';
  static const String deletePelangganUrl = '$_base/api/member/delete';
  static const String getPelanggantUrl = '$_base/api/member/';

  // ─── Diskon ──────────────────────────────────────────────
  static const String diskonLink = '$_base/api/discount';
  static const String createDiskonLink = '$_base/api/discount/store';
  static const String deleteDiskonLink = '$_base/api/discount/delete';
  static const String updateDiskonLink = '$_base/api/discount/update';
  static const String getSingleDiskonLink = '$_base/api/discount/show';
  static const String getProdukDiskonLink = '$_base/api/discount/get-products';
  static const String aktifDiskonLink = '$_base/api/discount/change-is-active';
  static const String diskonTransaksiLink = '$_base/api/discount/transaction';

  // ─── Voucher ─────────────────────────────────────────────
  static const String createVoucherUrl = '$_base/api/voucher/create';
  static const String updateVoucherUrl = '$_base/api/voucher/update';
  static const String getVoucherUrl = '$_base/api/voucher';
  static const String getSinglePromosiUrl = '$_base/api/voucher/single';

  // ─── Akun ────────────────────────────────────────────────
  static const String getAkunUrl = '$_base/api/groupmerchant/users';
  static const String updateAkunUrl = '$_base/api/user/update';
  static const String deleteAkunUrl = '$_base/api/user/delete';
  static const String getSingleAkunUrl = '$_base/api/user/single';
  static const String changeActiveAkunUrl = '$_base/api/user/changeStatus';
  static const String checkEmailVerified = '$_base/api/user/isEmailVerified';
  static const String verifiedEmailLink = '$_base/api/user/email/verfied';
  static const String verifiedEmailOtpLink =
      '$_base/api/user/email/verfied/otp';
  static const String registerGlobalMerchbyOtp = '$_base/api/register/single';
  static const String registerGlobalMerchEntry =
      '$_base/api/register/single/entry';

  // ─── Sandi / Password ────────────────────────────────────
  static const String getOtpSandiLink = '$_base/api/user/password/otp';
  static const String validasiOtpSandiLink =
      '$_base/api/user/password/otp/verified';
  static const String changeSandiLink = '$_base/api/user/password/change';
  static const String valOtpEmailLink = '$_base/api/user/email/otp';
  static const String valOtpEmailTahap1Link =
      '$_base/api/user/email/otp/verified';
  static const String changeEmailLink = '$_base/api/user/email/change';
  static const String changeEmailTahap2Link =
      '$_base/api/user/email/change/verified';

  // ─── Laporan ─────────────────────────────────────────────
  static const String laporanDailyUrl = '$_base/api/report/income/daily';
  static const String laporanMerchUrl = '$_base/api/report/income/merchant';
  static const String laporanProdukUrl = '$_base/api/report/income/product';
  static const String laporanPembayaranUrl = '$_base/api/report/coa';
  static const String laporanStokUrl = '$_base/api/report/inventory/stock';
  static const String laporanPergerakanInventoriUrl =
      '$_base/api/report/inventory/movement';
  static const String laporanPenggunaanProdukUrl = '$_base/api/report/bom';
  static const String laporanBOMUsageUrl = '$_base/api/report/bom';
  static const String laporanProdukExportUrl =
      '$_base/api/export/report/income/product';
  static const String laporanTokoExportUrl =
      '$_base/api/export/report/income/merchant';
  static const String laporanPendapatanHarianExportUrl =
      '$_base/api/export/report/income/daily';
  static const String getSinglePendapatanHarianLink =
      '$_base/api/report/income/daily/full';

  // ─── Pendapatan ──────────────────────────────────────────
  static const String getPendapatanUrl = '$_base/api/ppm/get';
  static const String createPemasukanUrl = '$_base/api/ppm/create';
  static const String ubahPemasukanUrl = '$_base/api/ppm/update';

  // ─── Rekon ───────────────────────────────────────────────
  static const String getRekonUrl = '$_base/api/rekon/';
  static const String saveRekonUrl = '$_base/api/rekon/save';
  static const String postingRekonUrl = '$_base/api/rekon/posting';
  static const String getYearRekonUrl = '$_base/api/rekon/year';
  static const String getMonthRekonUrl = '$_base/api/rekon/month';

  // ─── COA / Metode Pembayaran ─────────────────────────────
  static const String getCoaRefLink = '$_base/api/type/payment/references';
  static const String getCoaMethodLink = '$_base/api/type/payment';
  static const String getCoaMethodSingleLink = '$_base/api/type/payment/single';
  static const String addCoaLink = '$_base/api/type/payment/create';
  static const String updateCoaLink = '$_base/api/type/payment/update';
  static const String deleteCoaLink = '$_base/api/type/payment/delete';

  // ─── QRIS ────────────────────────────────────────────────
  static const String uploadQrisLink = '$_base/api/merchant/qris/save';
  static const String deleteQrisLink = '$_base/api/merchant/qris/delete';
  static const String getQrisLink = '$_base/api/merchant/qris/view';

  // ─── Struk ───────────────────────────────────────────────
  static const String getStrukLink = '$_base/api/merchant/struk/view';
  static const String uploadStrukLink = '$_base/api/merchant/struk/save';
  static const String deleteStrukLink = '$_base/api/merchant/struk/delete';

  // ─── Inventori / BOM ─────────────────────────────────────
  static const String getBOMLink = '$_base/api/product-material/';
  static const String getSingleBOMLink = '$_base/api/product-material/single';
  static const String createBOMLink = '$_base/api/product-material/create';
  static const String updateBOMLink = '$_base/api/product-material/update';
  static const String deleteBOMLink = '$_base/api/product-material/delete';
  static const String getUnitConvertionLink = '$_base/api/unit-conversion/';
  static const String createUnitConvertionLink =
      '$_base/api/unit-conversion/create';
  static const String getSingleUnitConvertionLink =
      '$_base/api/unit-conversion/single';
  static const String deleteUnitConvertionLink =
      '$_base/api/unit-conversion/delete';
  static const String updateUnitConvertionLink =
      '$_base/api/unit-conversion/update';
  static const String getAdjustmentLink = '$_base/api/inventory/adjustment';
  static const String getDetailAdjustmentLink =
      '$_base/api/inventory/adjustment/detail';
  static const String createAdjustmentLink =
      '$_base/api/inventory/adjustment/create';
  static const String deleteAdjustmentLink =
      '$_base/api/inventory/adjustment/delete';
  static const String updateAdjustmentLink =
      '$_base/api/inventory/adjustment/update';
  static const String getPurchaseLink = '$_base/api/inventory/purchase';
  static const String getDetailPurchaseLink =
      '$_base/api/inventory/purchase/detail';
  static const String createDetailPurchaseLink =
      '$_base/api/inventory/purchase/create';
  static const String updateDetailPurchaseLink =
      '$_base/api/inventory/purchase/update';
  static const String deleteDetailPurchaseLink =
      '$_base/api/inventory/purchase/delete';

  // ─── Master Data Inventori ───────────────────────────────
  static const String getMasterDataLink = '$_base/api/inventory/master';
  static const String createMasterDataLink =
      '$_base/api/inventory/master/create';
  static const String getMasterDataSingleLink =
      '$_base/api/inventory/master/single';
  static const String getMasterDataSingleDetailLink =
      '$_base/api/inventory/master/detail';
  static const String getUnitMasterDataLink = '$_base/api/unit';
  static const String copyMasterDataLink = '$_base/api/inventory/master/copy';
  static const String updateMasterDataLink =
      '$_base/api/inventory/master/update';
  static const String deleteMasterDataLink =
      '$_base/api/inventory/master/delete';

  // ─── Kulasedaya ──────────────────────────────────────────
  static const String getkulasedayaLink =
      '$_base/api/merchant/binding/kulasedaya';
  static const String bindingKulasedayaLink = '$_base/api/binding/kulasedaya';
  static const String getkulasedayaMerchantLink =
      '$_base/api/merchant/binding/kulasedaya';
  static const String deletekulasedayaTagihanLink =
      '$_base/api/transaction/delete/reference/tagihan/kulasedaya';

  // ─── Wilayah ─────────────────────────────────────────────
  static const String getProvinsiLink = '$_base/api/province';
  static const String getRegenciesLink = '$_base/api/regencies';
  static const String getDistrictLink = '$_base/api/district';
  static const String getVillageLink = '$_base/api/village';

  // ─── Lainnya ─────────────────────────────────────────────
  static const String out = '$_base/api/logout';
  static const String firebaseTokenUrl = '$_base/api/user/update/firebasetoken';
}

// ─── Transaction History (tetap ada untuk backward compatibility) ────────────
abstract class ApiTransactionHistory {
  static String get getReasons => ApiEndpoints.headerTagihanUrl;
  static String get deleteTransaction => ApiEndpoints.deleteTagihanUrl;
  static String get viewDeletedHistory =>
      ApiEndpoints.transaksiViewReferenceLink;
}
