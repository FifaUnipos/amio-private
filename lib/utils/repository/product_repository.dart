import 'package:unipos_app_335/models/produkmodel.dart';
import 'package:unipos_app_335/utils/connection_checker.dart';
import 'package:unipos_app_335/utils/database_helper.dart';
import 'package:unipos_app_335/services/product_api_service.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectionChecker _connectionChecker = ConnectionChecker();
  final ProductApiService _apiService = ProductApiService();

  Future<List<ModelDataProduk>> getProducts({
    required String token,
    required String name,
    required String isactive,
    required List<String> merchid,
    required String orderby,
    required Function(List<ModelDataProduk>) onSyncUpdate,
  }) async {
    // Ambil data dari local database, filter by isActive
    final allLocalProducts = await _dbHelper.getProducts();
    final localProducts = isactive == "1"
        ? allLocalProducts.where((p) => p.isActive == 1).toList()
        : allLocalProducts;

    // Cek koneksi internet dan sync di background
    _syncProductsInBackground(
      token,
      name,
      isactive,
      merchid,
      orderby,
      onSyncUpdate,
    );

    return localProducts;
  }

  Future<void> _syncProductsInBackground(
    String token,
    String name,
    String isactive,
    List<String> merchid,
    String orderby,
    Function(List<ModelDataProduk>) onSyncUpdate,
  ) async {
    bool isOnline = await _connectionChecker.checkInternet();

    if (isOnline) {
      final remoteProducts = await _apiService.fetchProducts(
        token: token,
        name: name,
        isactive: isactive,
        merchid: merchid,
        orderby: orderby,
      );

      if (remoteProducts != null) {
        await _dbHelper.saveProducts(remoteProducts);
        onSyncUpdate(remoteProducts);
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getProductVariants({
    required String token,
    required String merchantId,
    required String productId,
  }) async {
    // Cek cache lokal
    final cachedVariants = await _dbHelper.getProductVariants(productId);
    if (cachedVariants != null) {
      // Trigger background sync walaupun udah di cache
      _syncVariantsInBackground(token, merchantId, productId);
      return List<Map<String, dynamic>>.from(cachedVariants);
    }

    // Jika tidak ada di cache, fetch dari API
    bool isOnline = await _connectionChecker.checkInternet();
    if (isOnline) {
      final remoteVariants = await _apiService.fetchProductVariants(
        token: token,
        merchantId: merchantId,
        productId: productId,
      );

      if (remoteVariants != null) {
        await _dbHelper.saveProductVariants(productId, remoteVariants);
        return remoteVariants;
      }
    }
    return null;
  }

  Future<void> _syncVariantsInBackground(
    String token,
    String merchantId,
    String productId,
  ) async {
    bool isOnline = await _connectionChecker.checkInternet();
    if (isOnline) {
      final remoteVariants = await _apiService.fetchProductVariants(
        token: token,
        merchantId: merchantId,
        productId: productId,
      );
      if (remoteVariants != null) {
        await _dbHelper.saveProductVariants(productId, remoteVariants);
      }
    }
  }
}
