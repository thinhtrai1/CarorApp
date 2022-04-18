import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../themes/theme.dart';
import '../login/login.dart';
import '../scan_qr/scan_qr.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({Key? key}) : super(key: key);

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  var _isNotification = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F2F2),
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildItemSetting('login', const Icon(Icons.arrow_right_rounded), () => Navigator.of(context).push(createRoute(const LoginPage()))),
          _buildItemSetting('scan qr', const Icon(Icons.arrow_right_rounded), () => Navigator.of(context).push(createRoute(ScanQRPage()))),
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
                  })),
          _buildItemSetting('language', const Icon(Icons.arrow_right_rounded), () {}),
          _buildItemSetting('information', const Icon(Icons.arrow_right_rounded), () {}),
          const SizedBox(
            height: 80,
          ),
          ClayContainer(
            borderRadius: 40,
            color: const Color(0xFFF2F2F2),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSetting(String title, Widget icon, Function() onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 16, height: 60),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: colorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              icon,
              const SizedBox(width: 8),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFAAAAAA)),
        ],
      ),
    );
  }
}
