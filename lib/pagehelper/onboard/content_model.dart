class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent(
      {required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Pencatatan transaksi jual beli toko dengan sangat mudah',
      image: 'assets/newIllustration/OnBoarding1.svg',
      discription: "Melakukkan Transaksi Jual Beli Yang Terintegrasi"),
  UnbordingContent(
      title: 'Pencatatan, Keuangan, Laporan, Transaksi ada dalam satu aplikasi',
      image: 'assets/newIllustration/OnBoarding2.svg',
      discription: "Melakukkan Transaksi Jual Beli Yang Terintegrasi"),
  UnbordingContent(
      title: 'Pembeli senang dengan pelayanan yang cepat dengan menggunakan UniPOS',
      image: 'assets/newIllustration/OnBoarding3.svg',
      discription: "Melakukkan Transaksi Jual Beli Yang Terintegrasi"),
];
