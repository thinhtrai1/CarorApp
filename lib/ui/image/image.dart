import 'package:caror/themes/number.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({Key? key, required this.data}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          child: Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: CommonWidget.image(data),
          ),
        ),
        Positioned(
          left: 8,
          top: Number.getStatusBarHeight(context),
          child: MaterialIconButton(
            Icons.arrow_back_rounded,
            padding: 13,
            color: Colors.white,
            backgroundColor: const Color(0x33FFFFFF),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

class QrImagePage extends StatelessWidget {
  const QrImagePage({required this.encryptId, Key? key}) : super(key: key);

  final String encryptId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: QrImageView(
            size: Number.getScreenWidth(context) - 60,
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
        ),
        Positioned(
          left: 8,
          top: Number.getStatusBarHeight(context),
          child: MaterialIconButton(
            Icons.arrow_back_rounded,
            padding: 13,
            color: Colors.white,
            backgroundColor: const Color(0x33FFFFFF),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
