import 'package:caror/themes/number.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({Key? key, required this.data}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Container(
        alignment: Alignment.center,
        color: Colors.black,
        child: CommonWidget.image(data),
      ),
    );
  }
}

class QrImagePage extends StatelessWidget {
  const QrImagePage({required this.encryptId, Key? key}) : super(key: key);

  final String encryptId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = Number.getScreenWidth(context);
    return Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: QrImage(
        size: screenWidth - 60,
        data: encryptId,
        padding: EdgeInsets.zero,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.white,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.white,
        ),
      ),
    );
  }
}
