import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/atoms/button/unipos_button_option.dart';
import 'package:unipos_app_335/components/atoms/fields/unipos_text_field.dart';
import 'package:unipos_app_335/components/moleculs/unipos_modal.dart';
import 'package:unipos_app_335/data/static/transaction/history/delete_reasons_state.dart';
import 'package:unipos_app_335/data/static/transaction/history/delete_state.dart';
import 'package:unipos_app_335/providers/transactions/history/delete_list_reasons_provider.dart';
import 'package:unipos_app_335/providers/transactions/history/delete_provider.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class ModalTransactionDelete {
  static Future<bool?> show(
    BuildContext context,
    Map<String, dynamic>? dataDetailProduct,
    String token,
  ) async {
    // Reset state saat modal baru mau dibuka agar error yang lama hilang
    context.read<TransactionHistoryDeleteProvider>().resetState();

    String? selectedReasonId;
    final noteController = TextEditingController();
    return await UniposModal.show<bool>(
      context,
      title: 'Hapus Tagihan',
      prefixTextButton: 'Kembali',
      suffixTextButton: 'Hapus',
      onTapClose: () {
        context.read<TransactionHistoryDeleteProvider>().resetState();
        Navigator.pop(context);
      },
      onTapPrefixButton: () => Navigator.pop(context),
      onTapSuffixButton: () async {
        if (dataDetailProduct == null || dataDetailProduct['transactionid'] == null) {
          showSnackbar(context, {
            'rc': '99',
            'message': 'ID Transaksi belum dimuat',
          });
          return;
        }

        if (selectedReasonId == null) {
          showSnackbar(context, {
            'rc': '99',
            'message': 'Silakan pilih alasan hapus terlebih dahulu',
          });
          return;
        }

        if (noteController.text.trim().length < 15) {
          showSnackbar(context, {
            'rc': '99',
            'message': 'Detail alasan minimal 15 karakter',
          });
          return;
        }

        final provider = context.read<TransactionHistoryDeleteProvider>();
        await provider.deleteTransactionHistory(
          noteController.text,
          selectedReasonId!,
          dataDetailProduct['transactionid'].toString(),
          token,
        );

        if (!context.mounted) return;

        final state = provider.resultState;

        if (state is TransactionHistoryDeleteLoadedState) {
          showSnackbar(context, {'rc': '00', 'message': state.message});
          Navigator.pop(context, true);
        }
      },
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alasan Hapus Tagihan ',
                      style: heading2(FontWeight.normal, bnw900, 'Outfit'),
                    ),
                    Consumer<TransactionHistoryDeleteReasonsProvider>(
                      builder: (context, provider, child) {
                        final state = provider.resultState;

                        if (state
                            is TransactionHistoryDeleteReasonsLoadingState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.start,
                              direction: Axis.horizontal,
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  [
                                        "Barang ada yang rusak/hilang",
                                        "Pelanggan membatalkan",
                                        "Kasir keliru memasukkan barang",
                                        "Salah input kuantity",
                                        "Ganti metode pembayaran",
                                      ]
                                      .map(
                                        (text) => UniposButtonOption(
                                          isLoading: true,
                                          text: text,
                                        ),
                                      )
                                      .toList(),
                            ),
                          );
                        } else if (state
                            is TransactionHistoryDeleteReasonsErrorState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Gagal memuat alasan: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (state
                            is TransactionHistoryDeleteReasonsLoadedState) {
                          final reasons = state.data;
                          if (reasons.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Tidak ada alasan yang tersedia'),
                            );
                          }

                          return Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.horizontal,
                            spacing: 8,
                            runSpacing: 8,
                            children: reasons.map((reason) {
                              return UniposButtonOption(
                                text: reason.namakategori ?? 'Tidak diketahui',
                                state: selectedReasonId == reason.idkategori
                                    ? UniposButtonOptionState.active
                                    : UniposButtonOptionState.defaultState,
                                onTap: () {
                                  setModalState(() {
                                    selectedReasonId = reason.idkategori;
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox(); // None State
                      },
                    ),
                  ],
                ),
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Alasan',
                      style: heading2(FontWeight.normal, bnw900, 'Outfit'),
                    ),
                    Consumer<TransactionHistoryDeleteProvider>(
                      builder: (context, provider, child) {
                        final state = provider.resultState;
                        String? errorMessage;
                        if (state is TransactionHistoryDeleteErrorState) {
                          errorMessage = state.message;
                        }
                        return UniposTextField(
                          controller: noteController,
                          maxLines: 1,
                          errorText: errorMessage ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
