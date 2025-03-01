import 'package:caror/data/data_service.dart';
import 'package:caror/data/shared_preferences.dart';
import 'package:caror/resources/generated/l10n.dart';
import 'package:caror/main.dart';
import 'package:caror/resources/util.dart';
import 'package:caror/ui/web_view/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../resources/theme.dart';
import '../../widget/widget.dart';
import '../login/login.dart';
import '../profile/profile.dart';
import '../scan_qr/scan_qr.dart';
import 'home.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({Key? key}) : super(key: key);

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  bool _isLoggedIn = AppPreferences.getUserInfo() != null;
  bool _isNotification = true;
  String _language = getLanguageName(AppPreferences.getLanguageCode());
  HomePageState? _homeState;
  final GlobalKey _languageKey = GlobalKey();
  final _inAppPurchase = InAppPurchase.instance;
  ProductDetails? _premium;

  @override
  void initState() {
    _homeState = context.findAncestorStateOfType<HomePageState>();
    _initStoreInfo();
    super.initState();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      showToast(S.current.in_app_purchase_not_available);
      return;
    }
    final response = await _inAppPurchase.queryProductDetails({
      'test_premium',
    });
    if (response.error != null) {
      Util.log(response.error.toString(), error: true);
      showToast(S.current.in_app_purchase_not_available);
      return;
    }

    setState(() {
      _premium = response.productDetails.first;
    });

    _inAppPurchase.purchaseStream.listen((event) {
      Util.log('Purchase updated: ${event.map((e) => e.status).toList()}');
    });
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
            if (_isLoggedIn)
              _SettingItem(
                S.current.profile,
                child: const Icon(Icons.arrow_right_rounded),
                onPressed: () {
                  Navigator.of(context).push(createRoute(const ProfilePage()));
                },
              ),
            if (!_isLoggedIn)
              _SettingItem(
                S.current.login,
                child: const Icon(Icons.arrow_right_rounded),
                onPressed: () {
                  Navigator.of(context).push(createRoute(const LoginPage()));
                },
              ),
            _SettingItem(
              S.current.scan_qr,
              child: const Icon(Icons.arrow_right_rounded),
              onPressed: () {
                Navigator.of(context).push(createRoute(const ScanQRPage()));
              },
            ),
            _SettingItem(
              S.current.notification,
              child: Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  activeColor: Colors.black,
                  value: _isNotification,
                  onChanged: (value) {
                    setState(() {
                      _isNotification = value;
                    });
                  },
                ),
              ),
              onPressed: () => setState(() {
                _isNotification = !_isNotification;
              }),
            ),
            _SettingItem(
              S.current.sound,
              child: Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  activeColor: Colors.black,
                  value: _homeState?.isSound == true,
                  onChanged: (value) {
                    setState(() {
                      _homeState?.checkSound(value: value);
                    });
                  },
                ),
              ),
              onPressed: () => setState(() {
                _homeState?.checkSound();
              }),
            ),
            _SettingItem(
              S.current.language,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  key: _languageKey,
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
                      _language = value;
                      final locale = S.delegate.supportedLocales
                          .firstWhere((e) => value == getLanguageName(e.languageCode));
                      AppPreferences.setLanguageCode(locale.languageCode);
                      MyApp.setLocale(context, locale);
                    }
                  },
                ),
              ),
              onPressed: () {
                BuildContext? context = _languageKey.currentContext;
                while (context != null) {
                  context!.visitChildElements((element) {
                    if (element.widget is GestureDetector) {
                      (element.widget as GestureDetector).onTap?.call();
                      context = null;
                    } else {
                      context = element;
                    }
                  });
                }
              },
            ),
            _SettingItem(
              S.current.privacy_and_policy,
              child: const Icon(Icons.arrow_right_rounded),
              onPressed: () {
                Navigator.of(context).push(createRoute(WebViewPage(
                  url: DataService.getFullUrl('privacy'),
                )));
              },
            ),
            _SettingItem(
              S.current.information,
              child: const Icon(Icons.arrow_right_rounded),
              onPressed: () {
                Navigator.of(context).push(createRoute(const WebViewPage()));
              },
            ),
            if (_premium != null)
              _SettingItem(
                S.current.caror_premium,
                child: const Icon(Icons.star),
                onPressed: () {
                  _inAppPurchase.buyNonConsumable(
                    purchaseParam: PurchaseParam(productDetails: _premium!),
                  );
                },
              ),
            const SizedBox(height: 40),
            if (_isLoggedIn)
              InkWell(
                child: Container(
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
                onTap: () {
                  AppPreferences.logout();
                  setState(() {
                    _isLoggedIn = false;
                    HomePageState.of(context)?.loginState = LoginState.noLogin;
                  });
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem(this.title, {Key? key, required this.child, required this.onPressed})
      : super(key: key);

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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                child,
                const SizedBox(width: 8, height: 40),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }
}
