import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'pendapatan_harian_page.dart';
import 'laporan_per_toko_page.dart';
import 'laporan_per_produk_page.dart';
import 'laporan_pembayaran_page.dart';
import 'laporan_stok_page.dart';
import 'laporan_pergerakan_stok_page.dart';

class LaporanPage extends StatelessWidget {
  final String token;
  final String merchantId;

   LaporanPage({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Laporan',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: ListView(
        padding:  EdgeInsets.all(16),
        children: [
          _buildReportCard(
            context,
            title: 'Pendapatan Harian',
            subtitle: 'Laporan pendapatan harian toko',
            icon: PhosphorIcons.money_fill,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendapatanHarianPage(
                    token: token,
                    merchantId: merchantId,
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Pendapatan Per Toko',
            subtitle: 'Laporan pendapatan per toko',
            icon: PhosphorIcons.storefront_fill,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendapatanPerTokoPage(
                    token: token,
                    merchantId: merchantId,
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Pendapatan Per Produk',
            subtitle: 'Laporan pendapatan per produk',
            icon: PhosphorIcons.apple_logo_fill,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PendapatanPerProdukPage(
                    token: token,
                    merchantId: merchantId,
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Pendapatan Per Metode Pembayaran',
            subtitle: 'Laporan pendapatan per metode pembayaran',
            icon: PhosphorIcons.list_bullets_fill,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LaporanPembayaranPage(
                    token: token,
                    merchantId: merchantId,
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Stock Inventaris',
            subtitle: 'Laporan stok inventaris',
            icon: PhosphorIcons.package_fill,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LaporanStokPage(
                    token: token,
                    merchantId: merchantId,
                  ),
                ),
              );
            },
          ),
          _buildReportCard(
            context,
            title: 'Pergerakan Inventaris',
            subtitle: 'Laporan pergerakan inventaris',
            icon: PhosphorIcons.cube_fill,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LaporanPergerakanStokPage(
                    token: token,
                    merchantId: merchantId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:  EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bnw300),
      ),
      child: Padding(
        padding:  EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                       SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: heading4(FontWeight.w400, bnw600, 'Outfit'),
                      ),
                    ],
                  ),
                ),
                Icon(icon, color: bnw900, size: 28),
              ],
            ),
             SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side:  BorderSide(color: primary500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:  EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Lihat Laporan',
                  style: heading3(FontWeight.w600, primary500, 'Outfit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
