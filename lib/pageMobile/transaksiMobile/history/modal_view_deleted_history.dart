import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:unipos_app_335/components/atoms/unipos_detail_row.dart';
import 'package:unipos_app_335/components/atoms/unipos_information.dart';
import 'package:unipos_app_335/components/moleculs/unipos_modal.dart';
import 'package:unipos_app_335/data/static/transaction/history/view_deleted_history_state.dart';
import 'package:unipos_app_335/providers/transactions/history/view_deleted_history_provider.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/unipos_size.dart';
import 'package:unipos_app_335/utils/status_transaction.dart';

class ModalTransactionViewDeletedHistory {
  static void show(
    BuildContext context,
    Map<String, dynamic>? dataDetailProduct,
  ) {
    bool isDropdownOpen = false;
    UniposModal.show(
      context,
      title: 'Riwayat Transaksi',
      suffixButtonShow: false,
      onTapClose: () {
        Navigator.pop(context);
      },
      onTapPrefixButton: () {
        Navigator.pop(context);
      },
      child: Consumer<TransactionViewDeletedHistoryProvider>(
        builder: (context, value, child) {
          return switch (value.resultState) {
            TransactionViewDeletedHistoryErrorState(message: var message) =>
              Center(child: Text('EROR: $message')),
            TransactionViewDeletedHistoryLoadingState() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            TransactionViewDeletedHistoryLoadedState(
              data: var dataDeletedHistory,
            ) =>
              StatefulBuilder(
                builder: (context, setModalState) {
                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setModalState(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: uniposSize8,
                              horizontal: uniposSize8,
                            ),
                            decoration: BoxDecoration(
                              color: bnw100,
                              borderRadius: BorderRadius.circular(uniposSize16),
                              border: Border.all(color: bnw200),
                            ),
                            child: Column(
                              spacing: isDropdownOpen ? 8 : 0,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 16,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Transaksi Dibatalkan',
                                          style: heading2(
                                            FontWeight.normal,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          transitionBuilder:
                                              (child, animation) =>
                                                  FadeTransition(
                                                    opacity: animation,
                                                    child: ScaleTransition(
                                                      scale: animation,
                                                      child: child,
                                                    ),
                                                  ),
                                          child: Icon(
                                            isDropdownOpen
                                                ? PhosphorIcons.caret_up
                                                : PhosphorIcons.caret_down,
                                            key: ValueKey(isDropdownOpen),
                                            color: bnw900,
                                            size: uniposSize24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    uniposSize8,
                                                  ),
                                              color: danger100,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Pengisian Terakhir',
                                                  style: heading3(
                                                    FontWeight.normal,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                ),
                                                UniposInformation(
                                                  text:
                                                      dataDeletedHistory
                                                          .estimate ??
                                                      '-',
                                                  showIcon: false,
                                                  variant:
                                                      UniposInformationVariant
                                                          .danger,
                                                  hierarchy:
                                                      UniposInformationHierarchy
                                                          .primary,
                                                  size: UniposInformationSize
                                                      .medium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 300),
                                  alignment: Alignment.topCenter,
                                  crossFadeState: isDropdownOpen
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  sizeCurve: Curves.easeInOut,
                                  firstChild: SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        uniposSize8,
                                      ),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: bnw200,
                                        borderRadius: BorderRadius.circular(
                                          uniposSize8,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 16,
                                        children: [
                                         
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Status Transaksi',
                                                style: heading2(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              UniposInformation(
                                                variant:
                                                    statusTransactionCancel.contains(
                                                      dataDetailProduct!['isPaid'],
                                                    )
                                                    ? UniposInformationVariant
                                                          .danger
                                                    : statusTransactionProcessCancel
                                                          .contains(
                                                            dataDetailProduct!['isPaid'],
                                                          )
                                                    ? UniposInformationVariant
                                                          .warning
                                                    : UniposInformationVariant
                                                          .success,
                                                text:
                                                    '${dataDetailProduct!['status_transactions'] ?? '-'}',
                                                size: UniposInformationSize.small,
                                              ),
                                            ],
                                          ),
                                           Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: uniposSize8,
                                            children: [
                                              Text(
                                                'Detail Hapus',
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              UniposDetailRow(
                                                label: 'Alasan',
                                                value:
                                                    dataDeletedHistory
                                                            .references !=
                                                        null
                                                    ? dataDeletedHistory
                                                              .references!
                                                              .detailReason ??
                                                          'Rincian Alasan'
                                                    : 'Tidak Ada',
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 8,
                                            children: [
                                              Text(
                                                'Informasi Transaksi',
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              UniposDetailRow(
                                                label: 'Waktu Transaksi',
                                                value:
                                                    dataDeletedHistory
                                                        .entryDate ??
                                                    '-',
                                              ),
                                              UniposDetailRow(
                                                label: 'Nomor Transaksi',
                                                value:
                                                    '#${dataDetailProduct!['transactionid']}',
                                              ),
                                            ],
                                          ),

                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: uniposSize8,
                                            children: [
                                              Text(
                                                'Rincian Produk',
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  dataDetailProduct['product_image'] !=
                                                              null &&
                                                          dataDetailProduct['product_image'] !=
                                                              ''
                                                      ? Image.network(
                                                          dataDetailProduct['product_image'],
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (_, __, ___) =>
                                                                  const Icon(
                                                                    Icons.image,
                                                                  ),
                                                        )
                                                      : const Icon(
                                                          Icons.image,
                                                          size: 72,
                                                        ),
                                                  Text(
                                                    '${dataDetailProduct['product_name'] ?? 'Tidak Ada'}',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  secondChild: const SizedBox(
                                    width: double.infinity,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
