import 'package:caror/ui/home/tab_home.dart';
import 'package:caror/ui/home/tab_scan_qr.dart';
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
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: PageView.builder(
                itemCount: 5,
                controller: controller,
                onPageChanged: (page) {},
                itemBuilder: (BuildContext context, int itemIndex) {
                  switch (itemIndex) {
                    case 0:
                      return const HomeTab();
                    case 2:
                      return ScanQRTab();
                    default:
                      return const SettingTab();
                  }
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE8E8E8),
                    offset: Offset(0, -2),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Row(
                children: [
                  _buildBottomTabItem(0, 'Home', Icons.home_rounded),
                  _buildBottomTabItem(1, 'Forum', Icons.camera_rounded),
                  _buildBottomTabItem(2, 'Cart', Icons.shopping_cart_rounded),
                  _buildBottomTabItem(3, 'Chat', Icons.chat_rounded),
                  _buildBottomTabItem(4, 'Settings', Icons.settings_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTabItem(int position, String title, IconData icon) {
    return Expanded(
      child: Material(
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            controller.jumpToPage(position);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Colors.black,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
