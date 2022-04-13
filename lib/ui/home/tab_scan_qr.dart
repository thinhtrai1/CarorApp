import 'package:caror/themes/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRTab extends StatelessWidget {
  ScanQRTab({Key? key}) : super(key: key);

  final MobileScannerController _cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ShapePainter(),
      child: MobileScanner(
        allowDuplicates: false,
        controller: _cameraController,
        fit: BoxFit.none,
        onDetect: (barcode, args) {
          toast('Barcode found:\n${barcode.rawValue}');
        },
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final path = Path()
      ..moveTo(100, 50)
      ..lineTo(70, 50)
      ..quadraticBezierTo(50, 50, 50, 70)
      ..lineTo(50, 100)
      ..moveTo(size.width - 100, 50)
      ..lineTo(size.width - 70, 50)
      ..quadraticBezierTo(size.width - 50, 50, size.width - 50, 70)
      ..lineTo(size.width - 50, 100)
      ..moveTo(size.width - 100, size.height - 50)
      ..lineTo(size.width - 70, size.height - 50)
      ..quadraticBezierTo(size.width - 50, size.height - 50, size.width - 50, size.height - 70)
      ..lineTo(size.width - 50, size.height - 100)
      ..moveTo(100, size.height - 50)
      ..lineTo(70, size.height - 50)
      ..quadraticBezierTo(50, size.height - 50, 50, size.height - 70)
      ..lineTo(50, size.height - 100);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
