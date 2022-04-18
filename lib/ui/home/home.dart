import 'package:caror/ui/home/tab_home.dart';
import 'package:caror/ui/home/tab_setting.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController controller = PageController(keepPage: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 60,
              child: PageView.builder(
                itemCount: 5,
                controller: controller,
                onPageChanged: (page) {},
                itemBuilder: (BuildContext context, int itemIndex) {
                  switch (itemIndex) {
                    case 0:
                      return const HomeTab();
                    default:
                      return const SettingTab();
                  }
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: _BottomBarPaint(),
                child: SizedBox(
                  height: 70,
                  child: Row(
                    children: [
                      _buildBottomTabItem(0, 'Home', Icons.home_rounded),
                      _buildBottomTabItem(1, 'Forum', Icons.camera_rounded),
                      _buildBottomTabMiddleItem(2, 'Cart', Icons.shopping_cart_rounded),
                      _buildBottomTabItem(3, 'Chat', Icons.chat_rounded),
                      _buildBottomTabItem(4, 'Settings', Icons.settings_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTabMiddleItem(int position, String title, IconData icon) {
    return Expanded(
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0xffcbcbcb),
                offset: Offset(0, 1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              onTap: () {
                controller.jumpToPage(position);
              },
              child: Icon(
                icon,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTabItem(int position, String title, IconData icon) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            controller.jumpToPage(position);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.black,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class _BottomBarPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPath = Path()..moveTo(0, size.height - 50);
    _createMainPath(shadowPath, size).lineTo(size.width, size.height - 50);
    final shadowPaint = Paint()
      ..color = const Color(0xFFAFAFAF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(shadowPath, shadowPaint);
    final colorPath = Path()..moveTo(0, size.height);
    _createMainPath(colorPath, size).lineTo(size.width, size.height);
    final colorPaint = Paint()..color = Colors.white;
    canvas.drawPath(colorPath, colorPaint);
  }

  Path _createMainPath(Path path, Size size) {
    final centerX = size.width / 2;
    return path
      ..lineTo(0, 10)
      ..lineTo(centerX - 40, 10)
      ..quadraticBezierTo(centerX - 35, 10, centerX - 35, 5)
      ..quadraticBezierTo(centerX - 35, 0, centerX - 30, 0)
      ..lineTo(centerX + 30, 0)
      ..quadraticBezierTo(centerX + 35, 0, centerX + 35, 5)
      ..quadraticBezierTo(centerX + 35, 10, centerX + 40, 10)
      ..lineTo(size.width, 10);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
