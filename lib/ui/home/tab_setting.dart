import 'package:caror/data/shared_preferences.dart';
import 'package:caror/generated/l10n.dart';
import 'package:caror/main.dart';
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
  bool _isNotification = true;
  String _language = getLanguageName(AppPreferences.getLanguageCode());
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
            CommonTitleText(S.of(context).settings),
            const SizedBox(height: 16),
            _SettingItem(S.current.login, const Icon(Icons.arrow_right_rounded), () {
              Navigator.of(context).push(createRoute(const LoginPage()));
            }),
            _SettingItem(S.current.scan_qr, const Icon(Icons.arrow_right_rounded), () {
              Navigator.of(context).push(createRoute(const ScanQRPage()));
            }),
            _SettingItem(
              S.current.notification,
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
            _SettingItem(
              S.current.sound,
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
            _SettingItem(
              S.current.language,
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(8),
                  underline: const SizedBox(),
                  alignment: Alignment.centerRight,
                  value: _language,
                  items: S.delegate.supportedLocales.map((e) {
                    return DropdownMenuItem(
                      value: getLanguageName(e.languageCode),
                      child: Text(getLanguageName(e.languageCode), textAlign: TextAlign.end),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      final locale = S.delegate.supportedLocales.firstWhere((e) => value == getLanguageName(e.languageCode));
                      AppPreferences.setLanguageCode(locale.languageCode);
                      MyApp.setLocale(context, locale);
                      // setState(() {
                        _language = value;
                      // });
                    }
                  },
                ),
              ),
              () {},
            ),
            _SettingItem(S.current.information, const Icon(Icons.arrow_right_rounded), () {
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
              child: Text(
                S.current.logout,
                style: const TextStyle(
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
}

class _SettingItem extends StatelessWidget {
  const _SettingItem(this.title, this.child, this.onPressed, {Key? key}) : super(key: key);

  final String title;
  final Widget child;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
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
                child,
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
