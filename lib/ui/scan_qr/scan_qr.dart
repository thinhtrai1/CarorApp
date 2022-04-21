import 'dart:convert';

import 'package:caror/data/data_service.dart';
import 'package:caror/themes/number.dart';
import 'package:caror/themes/theme.dart';
import 'package:caror/ui/product_detail/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:encrypt/encrypt.dart' as e;

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({Key? key}) : super(key: key);

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final _cameraController = MobileScannerController();

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Number.getScreenWidth(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: MobileScanner(
              allowDuplicates: false,
              controller: _cameraController,
              fit: BoxFit.none,
              onDetect: (barcode, args) {
                _decrypt(barcode.rawValue);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: _ScanQrPaint(screenWidth),
          ),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  color: Color(0x4DFFFFFF),
                ),
                child: const Text(
                  'Scan Product QR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: screenWidth / 4 - 6,
            width: 64,
            height: 64,
            child: Material(
              shape: const CircleBorder(),
              color: const Color(0x4DFFFFFF),
              child: InkWell(
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.flashlight_on_rounded,
                  color: Colors.white,
                ),
                onTap: () {
                  if (_cameraController.hasTorch) {
                    _cameraController.toggleTorch();
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: screenWidth / 4 - 6,
            width: 64,
            height: 64,
            child: Material(
              shape: const CircleBorder(),
              color: const Color(0x4DFFFFFF),
              child: InkWell(
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                ),
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  _decrypt(String? json) {
    if (json != null) {
      try {
        final inputs = jsonDecode(json);
        final input = inputs['id'];
        if (input != null) {
          final key = e.Key.fromUtf8(App.ask);
          final iv = e.IV.fromLength(16);
          final encrypter = e.Encrypter(e.AES(key));
          final productId = encrypter.decrypt(e.Encrypted.fromBase64(input), iv: iv);
          _getProducts(productId);
          return;
        }
      } on FormatException catch (_) {}
    }
    showToast('Data error!');
    Navigator.pop(context);
  }

  _getProducts(String id) {
    showLoading(context, message: 'Loading data...');
    DataService.getProductDetail(id).then((response) {
      Navigator.pop(context);
      if (response?.data != null) {
        Navigator.pop(context);
        Navigator.of(context).push(createRoute(ProductDetailPage(response!.data!, Object)));
      }
    });
  }
}

class _ScanQrPaint extends StatefulWidget {
  const _ScanQrPaint(this.screenWidth) : super();

  final double screenWidth;

  @override
  State<_ScanQrPaint> createState() => _ScanQRPaintState();
}

class _ScanQRPaintState extends State<_ScanQrPaint> with SingleTickerProviderStateMixin {
  late Animation<double> _cornerWidthAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _cornerWidthAnimation = Tween<double>(begin: widget.screenWidth / 3, end: 40).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: true,
      painter: _ShapePainter(_cornerWidthAnimation),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.listenable) : super(repaint: listenable);

  final Animation listenable;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    const radius = 16;
    final rectWidth = size.width / 2;
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectWidth) / 2;
    final cornerWidth = listenable.value;
    final path = Path()
      ..moveTo(left + cornerWidth, top)
      ..lineTo(left + radius, top)
      ..quadraticBezierTo(left, top, left, top + radius)
      ..lineTo(left, top + cornerWidth)
      ..moveTo(size.width - left - cornerWidth, top)
      ..lineTo(size.width - left - radius, top)
      ..quadraticBezierTo(size.width - left, top, size.width - left, top + radius)
      ..lineTo(size.width - left, top + cornerWidth)
      ..moveTo(size.width - left - cornerWidth, size.height - top)
      ..lineTo(size.width - left - radius, size.height - top)
      ..quadraticBezierTo(size.width - left, size.height - top, size.width - left, size.height - top - radius)
      ..lineTo(size.width - left, size.height - top - cornerWidth)
      ..moveTo(left + cornerWidth, size.height - top)
      ..lineTo(left + radius, size.height - top)
      ..quadraticBezierTo(left, size.height - top, left, size.height - top - radius)
      ..lineTo(left, size.height - top - cornerWidth);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) {
    return oldDelegate.listenable.value != listenable.value;
  }
}
