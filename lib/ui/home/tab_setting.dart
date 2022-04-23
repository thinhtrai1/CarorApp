import 'package:caror/ui/web_view/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../themes/theme.dart';
import '../../widget/widget.dart';
import '../login/login.dart';
import '../scan_qr/scan_qr.dart';
import 'home.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({Key? key}) : super(key: key);

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  var _isNotification = true;
  HomePageState? homeState;

  @override
  void initState() {
    homeState = context.findAncestorStateOfType<HomePageState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackgroundContainer(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            const CommonTitleText('Setting'),
            const SizedBox(height: 16),
            _buildItemSetting('login', const Icon(Icons.arrow_right_rounded), () {
              //TODO #HOWTO: Why don't have exit transition?
              Navigator.of(context).push(createRoute(const LoginPage()));
            }),
            _buildItemSetting('scan qr', const Icon(Icons.arrow_right_rounded), () {
              Navigator.of(context).push(createRoute(const ScanQRPage()));
            }),
            _buildItemSetting(
              'notification',
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  value: _isNotification,
                  onChanged: (value) {
                    setState(() {
                      _isNotification = value;
                    });
                  },
                ),
              ),
              () => setState(() {
                _isNotification = !_isNotification;
              }),
            ),
            _buildItemSetting(
              'sound',
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  value: homeState?.isSound == true,
                  onChanged: (value) {
                    setState(() {
                      homeState?.checkSound(value: value);
                    });
                  },
                ),
              ),
              () => setState(() {
                homeState?.checkSound();
              }),
            ),
            _buildItemSetting('language', const Icon(Icons.arrow_right_rounded), () {}),
            _buildItemSetting('information', const Icon(Icons.arrow_right_rounded), () {
              Navigator.of(context).push(createRoute(const WebViewPage()));
            }),
            const SizedBox(height: 64),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: colorShadow,
                    offset: Offset(0, 1),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSetting(String title, Widget icon, Function() onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: colorDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                icon,
                const SizedBox(width: 8, height: 50),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }
}
