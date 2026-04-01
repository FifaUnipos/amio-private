String textOrderBy = 'Nama Toko A ke Z ';
String textvalueOrderBy = 'upDownNama';

String textOrderByStore = 'Nama Toko A ke Z ';
String textvalueOrderByStore = 'upDownNama';

String textOrderByBahan = 'Nama Bahan A ke Z';
String textvalueOrderByBahan = 'upDownName';
String textOrderByCart = 'Nama Produk A ke Z';
String textvalueOrderByCart = 'upDownNama';
String textOrderByRiwayatTransaksi = 'Riwayat Terbaru';
String textvalueOrderByRiwayatTransaksi = 'upDownCreate';
String textOrderByTagihan = 'Tagihan Terbaru';
String textvalueOrderByTagihan = 'upDownCreate';
String textOrderByPelanggan = 'Nama Pelanggan A ke Z';
String textvalueOrderByMember = 'upDownNama';
String textOrderByDiscount = 'Nama Diskon A ke Z';
String textvalueOrderByDiscount = 'upDownNama';

String textOrderByReportDaily = 'Laporan Terkini';
String textvalueOrderByReportDaily = 'tanggalTerkini';
String textOrderByReportProduct = 'Laporan Terkini';
String textvalueOrderByReportProduct = 'tanggalTerkini';
String textOrderByReportByPayment = 'Nama Pembayaran A-Z';
String textvalueOrderByReportByPayment = 'nameCoaAsc';
String textOrderByReportInventoryStock = 'Stok Akhir A-Z';
String textvalueOrderByReportInventoryStock = 'endingStockAsc';
String textOrderByReportMoveInventory = 'Stok Akhir A-Z';
String textvalueOrderByReportMoveInventory = 'endingStockAsc';

String textOrderByCOA = '';

List alasanTagihanText = [
  "Salah Input Produk",
  "Produk Tidak Tersedia",
  "Transaksi Lama",
  "Kurang Catatan",
  "Tidak Sesuai Pesanan",
  "Kesalahan Pembeli",
];

List orderByProductText = [
  "Nama Produk A ke Z",
  "Nama Produk Z ke A",
  "Produk Terbaru",
  "Produk Terlama",
  "Harga Tertinggi",
  "Harga Terendah",
];

List orderByCartText = [
  "Nama Produk A ke Z",
  "Nama Produk Z ke A",
  "Produk Terbaru",
  "Produk Terlama",
  "Harga Tertinggi",
  "Harga Terendah",
];

List orderByDiscountText = [
  "Nama Diskon A ke Z",
  "Nama Diskon Z ke A",
  "Diskon Terbaru",
  "Diskon Terlama",
  "Harga Tertinggi",
  "Harga Terendah",
];

List orderByCOAListText = [
  "Nama COA A ke Z",
  "Nama COA Z ke A",
  "COA Terbaru",
  "COA Terlama",
];

List orderByRiwayatText = [
  "Riwayat Terbaru",
  "Riwayat Terlama",
  "Nama Pembeli A ke Z",
  "Nama Pembeli Z ke A",
  "Total Tertinggi",
  "Total Terendah",
];

List orderByTagihanText = [
  "Tagihan Terbaru",
  "Tagihan Terlama",
  "Nama Pembeli A ke Z",
  "Nama Pembeli Z ke A",
  "Total Tertinggi",
  "Total Terendah",
];

List orderByVoucherText = [
  "Nama Voucher A ke Z",
  "Nama Voucher Z ke A",
  "Voucher Terbaru",
  "Voucher Terlama",
  "Harga Tertinggi",
  "Harga Terendah",
];

List orderByDiskonText = [
  "Nama Diskon A ke Z",
  "Nama Diskon Z ke A",
  "Diskon Terbaru",
  "Diskon Terlama",
  "Harga Tertinggi",
  "Harga Terendah",
];

List orderByPelangganText = [
  "Nama Pelanggan A ke Z",
  "Nama Pelanggan Z ke A",
  "Pelanggan Terbaru",
  "Pelanggan Terlama",
];

List orderByTokoText = [
  "Nama Toko A ke Z",
  "Nama Toko Z ke A",
  "Toko Terbaru",
  "Toko Terlama",
];

List orderByAkunText = [
  "Nama Akun A ke Z",
  "Nama Akun Z ke A",
  "Akun Terbaru",
  "Akun Terlama",
];

List orderByBahanText = [
  "Nama Akun A ke Z",
  "Nama Akun Z ke A",
  "Bahan Terbaru",
  "Bahan Terlama",
  "Aktifitas Terbaru",
  "Aktifitas Terlama",
  "Kuantitas Terkecil",
  "Kuantitas Terbanyak",
];

List orderByRiwayatTransaksiText = [
  "Riwayat Terbaru",
  "Riwayat Terlama",
  "Nama Pembeli A ke Z",
  "Nama Pembeli Z ke A",
  "Total Tertinggi",
  "Total Terendah",
];

List orderByLaporanPerProdukText = [
  "Product Terbaru",
  "Product Terlama",
  "Transaksi Terbanyak",
  "Transaksi Terendah",
  "Nilai Transaksi Tertinggi",
  "Nilai Transaksi Terendah",
  "PPN Tertinggi",
  "PPN Terendah",
  "Total PerProduk Tertinggi",
  "Total PerProduk Terendah",
];

List orderByLaporanHarianText = [
  "Tanggal Terkini",
  "Tanggal Terlama",
  "Transaksi Tertinggi",
  "Transaksi Terendah",
  "PPN Tertinggi",
  "PPN Terendah",
  "Total Tertinggi",
  "Total Terendah",
];
List orderByLaporanPembayaranText = [
  "Nama Pembayaran A-Z",
  "Nama Pembayaran Z-A",
];

List orderByLaporanStokInventarisText = [
  "Stok Akhir A-Z", // endingStockAsc
  "Stok Akhir Z-A", // endingStockDesc
  "Stok Awal A-Z", // startingStockAsc
  "Stok Awal Z-A", // startingStockDesc
  "Nama Inventori A-Z", // inventoryNameAsc
  "Nama Inventori Z-A", // inventoryNameDesc
  "Inventori Keluar A-Z", // outgoingInventoryAsc
  "Inventori Keluar Z-A", // outgoingInventoryDesc
  "Inventori Masuk A-Z", // incomingInventoryAsc
  "Inventori Masuk Z-A", // incomingInventoryDesc
];

List orderByLaporanPergerakanInventarisText = [
  "Stok Akhir A-Z", // endingStockAsc
  "Stok Akhir Z-A", // endingStockDesc
  "Stok Awal A-Z", // startingStockAsc
  "Stok Awal Z-A", // startingStockDesc
  "Nama Inventori A-Z", // inventoryNameAsc
  "Nama Inventori Z-A", // inventoryNameDesc
  "Inventori Keluar A-Z", // outgoingInventoryAsc
  "Inventori Keluar Z-A", // outgoingInventoryDesc
  "Inventori Masuk A-Z", // incomingInventoryAsc
  "Inventori Masuk Z-A", // incomingInventoryDesc
];

//! orderby
List orderByBahanIngredient = [
  "upDownName",
  "downUpName",
  "upDownCreated",
  "downUpCreated",
  "upDownActivity",
  "downUpActivity",
  "upDownQty",
  "downUpQty",
];
List orderByProduct = [
  "upDownNama",
  "downUpNama",
  "upDownCreate",
  "downUpCreate",
  "downUpHarga",
  "upDownHarga",
];
List orderByCart = [
  "upDownNama",
  "downUpNama",
  "upDownCreate",
  "downUpCreate",
  "downUpHarga",
  "upDownHarga",
];

List orderByDiscount = [
  "upDownNama",
  "downUpNama",
  "upDownCreate",
  "downUpCreate",
  "downUpHarga",
  "upDownHarga",
];

List orderByPelanggan = [
  "upDownNama",
  "downUpNama",
  "upDownCreate",
  "downUpCreate",
];
List orderByToko = ["upDownNama", "downUpNama", "upDownCreate", "downUpCreate"];

List orderByAkun = [
  "upDownNama",
  "downUpNama",
  "upDownAccount",
  "downUpAccount",
];
List orderByRiwayatTagihan = [
  "upDownCreate",
  "downUpCreate",
  "upDownNama",
  "downUpNama",
  "downUpAmount",
  "upDownAmount",
];
List orderByRiwayatTransaksi = [
  "upDownCreate",
  "downUpCreate",
  "upDownNama",
  "downUpNama",
  "downUpAmount",
  "upDownAmount",
];
List orderByCOAText = ["", "Debit", "Kredit", "EWallet"];

List orderByLaporanHarian = [
  "tanggalTerkini",
  "tanggalTerlama",
  "transaksiTertinggi",
  "transaksiTerendah",
  "ppnTertinggi",
  "ppnTerendah",
  "totalTertinggi",
  "totalTerendah",
];

List orderByLaporanPerProduk = [
  "productTerbaru",
  "productTerlama",
  "countTertinggi",
  "countTerendah",
  "transaksiTertinggi",
  "transaksiTerendah",
  "ppnTertinggi",
  "ppnTerendah",
  "totalTertinggi",
  "totalTerendah",
];

List orderByLaporanPembayaran = ["nameCoaAsc", "nameCoaDesc"];
List orderByLaporanStokInventaris = [
  "endingStockAsc",
  "endingStockDesc",
  "startingStockAsc",
  "startingStockDesc",
  "inventoryNameAsc",
  "inventoryNameDesc",
  "outgoingInventoryAsc",
  "outgoingInventoryDesc",
  "incomingInventoryAsc",
  "incomingInventoryDesc",
];

List orderByLaporanPergerakanInventaris = [
  "endingStockAsc",
  "endingStockDesc",
  "startingStockAsc",
  "startingStockDesc",
  "inventoryNameAsc",
  "inventoryNameDesc",
  "outgoingInventoryAsc",
  "outgoingInventoryDesc",
  "incomingInventoryAsc",
  "incomingInventoryDesc",
];


// 
int valueOrderByStore = 0;

int valueOrderByProduct = 0;
int valueOrderByIngredient = 0;
int valueOrderByDiscount = 0;
int valueOrderByCart = 0;
int valueOrderByHistoryTransaction = 0;
int valueOrderByBills = 0;
int valueOrderByMember = 0;
int valueOrderByReportDaily = 0;
int valueOrderByReportProduct = 0;
int valueOrderByReportByPayment = 0;
int valueOrderByReportInventoryStock = 0;
int valueOrderByReportMoveInventory = 0;
