import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/websocket_service.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/transaction_success_page.dart';

class SharedQrisHandler {
  static Future<void> showSharedQrisFlow({
    required BuildContext context,
    required Map<String, dynamic> response,
    required String token,
    required int amount,
    required List<Map<String, dynamic>>? cart,
    required VoidCallback onSuccess,
  }) async {
    final data = response['data'] ?? response; // Handle both nested and flat data
    String? qrString;

    // 1. Extract qr_string (Exact Mobile Logic)
    if (data['payments'] != null) {
      final payments = data['payments'];
      if (payments is Map<String, dynamic> && payments['payment_detail'] != null) {
        final pDetail = payments['payment_detail'];
        if (pDetail is Map<String, dynamic> && pDetail['payment_instructions'] != null) {
          final pInstr = pDetail['payment_instructions'];
          if (pInstr is Map<String, dynamic> && pInstr['qr_string'] != null) {
            qrString = pInstr['qr_string'].toString();
          }
        }
      }
    }

    if (qrString == null || qrString.isEmpty) {
      debugPrint('QRIS: qr_string not found in response');
      return;
    }

    final String transactionId = data['transactionid']?.toString() ?? '';
    final wsService = Provider.of<WebSocketService>(context, listen: false);
    final existingSocket = wsService.socket;

    void _finishAndRedirect() {
      // Check for tablet layout
      final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

      if (isTablet) {
        // Use standard push for Tablet to keep the Sidebar shell in the stack.
        // This avoids the 'blank screen' issue when clicking back.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionSuccessPage(
              data: data,
              localCart: cart,
            ),
          ),
        );
      } else {
        // Keep pushReplacement for Mobile as it matches the existing flow.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionSuccessPage(
              data: data,
              localCart: cart,
            ),
          ),
        );
      }
      onSuccess();
    }

    void handleTransactionUpdate(dynamic resp) {
      debugPrint('WebSocket: Update received $resp');
      if (resp is Map) {
        String paymentStatus = resp['payment_status']?.toString() ?? '';
        if (paymentStatus == 'SUCCESS') {
          existingSocket?.off('transactionUpdate', handleTransactionUpdate);
          if (Navigator.canPop(context)) Navigator.pop(context);
          _finishAndRedirect();
        } else if (paymentStatus == 'FAILED') {
          existingSocket?.off('transactionUpdate', handleTransactionUpdate);
          if (Navigator.canPop(context)) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi QRIS Gagal')),
          );
        }
      }
    }

    // WebSocket Parity Logic (Exact Mobile Logic)
    if (existingSocket == null || !existingSocket.connected) {
      print('=========== SOCKET MATI! MENGHUBUNGKAN ULANG DARI SERVICE... ===========');
      wsService.connect(token, identifier);
    }

    final activeSocket = wsService.socket;
    if (activeSocket != null) {
      print('=========== WEBSOCKET MEMULAI TRANSAKSI ${transactionId} ===========');
      
      void onSocketConnected(dynamic _) {
          print('✅ SOCKET CONNECTED. Joining room for transaction: $transactionId');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Socket Terhubung: $transactionId'), duration: const Duration(seconds: 1)),
          );
          
          // Emit events
          activeSocket.emit('subscribeTransaction', {"transactionId": transactionId, "transaction_id": transactionId});
          activeSocket.emit('joinRoom', {"room": "subscribeTransaction", "transactionId": transactionId, "transaction_id": transactionId});
          
          print('🏠 Sent joinRoom & subscribeTransaction for $transactionId');
      }

      if (activeSocket.connected) {
          onSocketConnected(null);
      } else {
          print('⏳ Socket still connecting... waiting for "connect" event');
          activeSocket.once('connect', (data) {
             print('⚡ Delayed connect event triggered!');
             onSocketConnected(data);
          });
      }
      
      activeSocket.on('transactionUpdate', handleTransactionUpdate);
      activeSocket.onAny((event, data) {
          print('=========== SOCKET MSG [$event]: $data ===========');
      });
    } else {
      print('=========== FATAL: WEBSOCKET PROVIDER KOSONG ===========');
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran QRIS',
                  style: heading1(
                    FontWeight.bold,
                    bnw900,
                    'Outfit',
                  ).copyWith(fontSize: 22),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Total Bayar',
                    style: heading2(
                      FontWeight.w600,
                      bnw900,
                      'Outfit',
                    ).copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Rp ${formatCurrency(amount)}',
                    style: heading1(
                      FontWeight.w800,
                      bnw900,
                      'Outfit',
                    ).copyWith(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=$qrString',
                      width: 250,
                      height: 250,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(child: Text('Gagal memuat QR Code')),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final bluetooth = BlueThermalPrinter.instance;
                          bluetooth.isConnected.then((isConnected) {
                            if (!context.mounted) return;
                            if (isConnected == true) {
                              bluetooth.printCustom("Total Bayar", 1, 1);
                              bluetooth.printCustom(
                                "Rp ${formatCurrency(amount)}",
                                1,
                                1,
                              );
                              bluetooth.printQRcode(
                                qrString!,
                                200,
                                200,
                                1,
                              );
                              bluetooth.printNewLine();
                              bluetooth.paperCut();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Printer belum terhubung',
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(
                          PhosphorIcons.printer,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Cetak',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          activeSocket?.off('transactionUpdate', handleTransactionUpdate);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            color: primary500,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primary500, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // Ensure listener is removed if bottom sheet is closed manually
    activeSocket?.off('transactionUpdate', handleTransactionUpdate);
  }
}
