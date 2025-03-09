import 'package:caror/data/data_service.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/resources/number.dart';
import 'package:caror/resources/theme.dart';
import 'package:caror/resources/util.dart';
import 'package:caror/ui/product_detail/product_detail.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
              controller: _cameraController,
              fit: BoxFit.cover,
              onDetect: (barcode) {
                _decrypt(barcode.barcodes.first.rawValue);
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  color: Color(0x4DFFFFFF),
                ),
                child: Text(
                  S.current.scan_product_qr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
            child: MaterialIconButton(
              Icons.flashlight_on_rounded,
              color: Colors.white,
              backgroundColor: const Color(0x4DFFFFFF),
              onPressed: () {
                _cameraController.toggleTorch();
              },
            ),
          ),
          Positioned(
            bottom: 120,
            right: screenWidth / 4 - 6,
            width: 64,
            height: 64,
            child: MaterialIconButton(
              Icons.photo_library_rounded,
              color: Colors.white,
              backgroundColor: const Color(0x4DFFFFFF),
              onPressed: () {
                _selectPhoto();
              },
            ),
          ),
        ],
      ),
    );
  }

  _selectPhoto() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!mounted || file == null) {
        return;
      }

      final barcodeCapture = await _cameraController.analyzeImage(file.path);
      if (mounted) {
        _decrypt(barcodeCapture?.barcodes.first.rawValue);
      }
    } catch (e) {
      Util.log('Select photo error: $e', error: true);
    }
  }

  _decrypt(String? data) {
    if (data != null) {
      try {
        final uri = Uri.parse(data);
        final paths = uri.pathSegments;
        if (paths.length == 2) {
          _cameraController.pause();
          final productId = Util.decrypt(paths.last);
          if (productId != null) {
            _getProducts(productId);
            return;
          }
        }
      } on FormatException catch (e) {
        Util.log('Decrypt QR Code: $e', error: true);
      }
    }
    showToast(S.current.data_error);
    Navigator.pop(context);
  }

  _getProducts(String id) {
    showLoading(context, message: S.current.loading_data);
    DataService.getProductDetail(id).then((data) {
      Navigator.pop(context);
      if (data != null) {
        Navigator.pop(context);
        Navigator.of(context).push(createRoute(ProductDetailPage(data)));
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
