import 'package:caror/themes/number.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrImagePage extends StatelessWidget {
  const QrImagePage(this._encryptId, {Key? key}) : super(key: key);

  final String _encryptId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = Number.getScreenWidth(context);
    return Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: QrImage(
        size: screenWidth - 60,
        data: _encryptId,
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

class ImagePage extends StatelessWidget {
  const ImagePage(this._data, {Key? key}) : super(key: key);

  final String _data;

  @override
  Widget build(BuildContext context) {
    final screenWidth = Number.getScreenWidth(context);
    return Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: CommonWidget.image(
        _data,
        width: screenWidth - 60,
        height: double.infinity
      ),
    );
  }
}
