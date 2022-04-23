import 'package:audioplayers/audioplayers.dart';
import 'package:caror/data/data_service.dart';
import 'package:caror/data/shared_preferences.dart';
import 'package:caror/ui/home/tab_cart.dart';
import 'package:caror/ui/home/tab_chat.dart';
import 'package:caror/ui/home/tab_universe.dart';
import 'package:caror/ui/home/tab_home.dart';
import 'package:caror/ui/home/tab_setting.dart';
import 'package:flutter/material.dart';

enum LoginState { noLogin, loggingIn, loggedIn }

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.loginState = LoginState.noLogin}) : super(key: key);

  final LoginState loginState;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 5, vsync: this);
  late LoginState loginState;
  bool isSound = false;
  AudioPlayer? _audioPlayer;

  checkSound({bool? value}) async {
    isSound = value ?? !isSound;
    if (isSound) {
      if (_audioPlayer == null) {
        _audioPlayer = await AudioCache().loop('background_sound.mp3');
      } else {
        _audioPlayer!.resume();
      }
    } else {
      _audioPlayer?.pause();
    }
  }

  @override
  void dispose() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    loginState = widget.loginState;
    if (widget.loginState != LoginState.loggedIn) {
      final username = AppPreferences.getUsername();
      final password = AppPreferences.getPassword();
      if (username != null && password != null) {
        loginState = LoginState.loggingIn;
        DataService.login(username, password).then((user) {
          if (user != null) {
            AppPreferences.setAccessToken(user.token);
            AppPreferences.setUsername(username);
            AppPreferences.setPassword(password);
            loginState = LoginState.loggedIn;
          } else {
            loginState = LoginState.noLogin;
          }
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: const [
              HomeTab(),
              UniverseTab(),
              CartTab(),
              ChatTab(),
              SettingTab(),
            ],
          ),
          Positioned(
            child: CustomPaint(
              painter: _BottomBarPaint(),
              child: _BottomBar(_tabController),
            ),
            bottom: 0,
            left: 0,
            right: 0,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar(this._tabController, {Key? key}) : super(key: key);

  final TabController _tabController;

  @override
  State<StatefulWidget> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> with SingleTickerProviderStateMixin {
  late Animation<double> _rotateAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _rotateAnimation = Tween<double>(begin: 0, end: 0.1).animate(_animationController);
  }

  _rotateIcon() {
    setState(() {
      _animationController.forward().then((value) => _animationController.reverse());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const SizedBox(width: 8),
          _buildBottomTabItem(0, 'Home', Icons.home_rounded),
          _buildBottomTabItem(1, 'Universe', Icons.camera_rounded),
          _buildBottomTabMiddleItem(2, 'Cart', Icons.shopping_cart_rounded),
          _buildBottomTabItem(3, 'Chat', Icons.chat_rounded),
          _buildBottomTabItem(4, 'Settings', Icons.settings_rounded),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBottomTabMiddleItem(int position, String title, IconData icon) {
    return Expanded(
      child: Center(
        child: Container(
          width: 60,
          height: 50,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
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
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              onTap: () {
                widget._tabController.animateTo(position);
                _rotateIcon();
              },
              child: widget._tabController.index == position
                  ? RotationTransition(
                      turns: _rotateAnimation,
                      child: Icon(
                        icon,
                        size: 32,
                        color: Colors.black,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 32,
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
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            widget._tabController.animateTo(position);
            _rotateIcon();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              widget._tabController.index == position
                  ? RotationTransition(
                      turns: _rotateAnimation,
                      child: Icon(
                        icon,
                        color: Colors.black,
                      ),
                    )
                  : Icon(
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
    );
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
      ..lineTo(0, 0)
      ..lineTo(centerX - 55, 0)
      ..quadraticBezierTo(centerX - 35, 0, centerX - 35, 20)
      ..lineTo(centerX - 35, size.height - 20)
      ..quadraticBezierTo(centerX - 35, size.height, centerX - 15, size.height)
      ..lineTo(centerX + 15, size.height)
      ..quadraticBezierTo(centerX + 35, size.height, centerX + 35, size.height - 20)
      ..lineTo(centerX + 35, 20)
      ..quadraticBezierTo(centerX + 35, 0, centerX + 55, 0)
      ..lineTo(size.width, 0);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
