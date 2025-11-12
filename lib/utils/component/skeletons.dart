import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

//! avatar dan line
class SkeletonCardLine extends StatefulWidget {
  SkeletonCardLine({Key? key}) : super(key: key);

  @override
  State<SkeletonCardLine> createState() => _SkeletonCardLineState();
}

class _SkeletonCardLineState extends State<SkeletonCardLine> {
  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;

    void _toggleLoading() {
      setState(() {
        _isLoading = !_isLoading;
      });
    }

    return Expanded(
      child: SkeletonListView(
        scrollable: true,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonAvatar(
                    style: SkeletonAvatarStyle(height: 60, width: 60)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(style: SkeletonLineStyle(height: 60)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: 10,
      ),
    );
  }
}

//! hanya card besar
class SkeletonCard extends StatefulWidget {
  SkeletonCard({Key? key}) : super(key: key);

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SkeletonListView(
        scrollable: true,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width / 2.57,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width / 2.57,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: 10,
      ),
    );
  }
}

//! hanya untuk di transaksi
class SkeletonCardTransaksi extends StatefulWidget {
  SkeletonCardTransaksi({Key? key}) : super(key: key);

  @override
  State<SkeletonCardTransaksi> createState() => _SkeletonCardTransaksiState();
}

class _SkeletonCardTransaksiState extends State<SkeletonCardTransaksi> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SkeletonListView(
        padding: EdgeInsets.zero,
        scrollable: true,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            // padding: const EdgeInsets.only(top: 12),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SkeletonAvatar(
                //   style: SkeletonAvatarStyle(
                //     height: MediaQuery.of(context).size.height / 3,
                //     width: MediaQuery.of(context).size.width / 7.2,
                //   ),
                // ),

                columnForTransaksi(context),
                SizedBox(
                  width: 8,
                ),
                columnForTransaksi(context),
                SizedBox(width: 8),
                columnForTransaksi(context),
                SizedBox(width: 8),
                columnForTransaksi(context),
              ],
            ),
          );
        },
        itemCount: 4,
      ),
    );
  }

  columnForTransaksi(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SkeletonAvatar(
          style: SkeletonAvatarStyle(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width / 7.2,
          ),
        ),
      ),
    );
  }
}

class SkeletonJustLine extends StatefulWidget {
  SkeletonJustLine({Key? key}) : super(key: key);

  @override
  State<SkeletonJustLine> createState() => _SkeletonJustLineState();
}

class _SkeletonJustLineState extends State<SkeletonJustLine> {
  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;

    void _toggleLoading() {
      setState(() {
        _isLoading = !_isLoading;
      });
    }

//tambahin column
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SkeletonListView(
          scrollable: true,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonLine(style: SkeletonLineStyle(height: 60)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: 10,
        ),
      ),
    );
  }
}
