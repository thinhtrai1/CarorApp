import 'package:caror/data/data_service.dart';
import 'package:caror/entity/People.dart';
import 'package:caror/themes/number.dart';
import 'package:caror/themes/theme.dart';
import 'package:caror/ui/home/home.dart';
import 'package:caror/ui/login/login.dart';
import 'package:caror/widget/shimmer_loading.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  LoginState? _loginState;
  late final _statusBarHeight = Number.getStatusBarHeight(context);
  List<People>? _peoples;

  LoginState? getLoginState() {
    return context.findAncestorStateOfType<HomePageState>()?.loginState;
  }

  @override
  initState() {
    _loginState = getLoginState();
    if (_loginState == LoginState.loggedIn) {
      _getPeoples();
    }
    super.initState();
  }

  _getPeoples() {
    DataService.getPeoples().then((response) {
      if (response != null) {
        setState(() {
          _peoples = response.data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginState) {
      case LoginState.loggingIn:
        return _buildLoggingInView();
      case LoginState.loggedIn:
        return _buildContent();
      default:
        return _buildLoginButton();
    }
  }

  Widget _buildContent() {
    return Shimmer(
      linearGradient: Shimmer.shimmerGradient,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, top: _statusBarHeight + 16, bottom: 24),
              padding: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: colorShadow,
                    offset: Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search name, phone number...',
                      ),
                      style: const TextStyle(fontFamily: "Montserrat"),
                    ),
                  ),
                  CommonIcon(Icons.search_rounded, padding: 16, onPressed: () {}),
                ],
              ),
            ),
            _isShimmerIndex()
                ? ShimmerLoading(
                    child: Container(
                      margin: const EdgeInsets.only(left: 16, bottom: 8),
                      width: 100,
                      height: 24,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: colorShimmer,
                      ),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      'Recent',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
            _buildHorizontalListView(true),
            _isShimmerIndex()
                ? ShimmerLoading(
                    child: Container(
                      margin: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
                      width: 100,
                      height: 24,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: colorShimmer,
                      ),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                    child: Text(
                      'Friends',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
            _buildHorizontalListView(false),
            const SizedBox(height: 24),
            _isShimmerIndex()
                ? ShimmerLoading(
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      width: 100,
                      height: 24,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: colorShimmer,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        'Contacts (${_peoples!.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      const Spacer(),
                      const Text(
                        'View all',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
            _buildVerticalListView(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  int _getItemCount() => _peoples?.length ?? shimmerItemCount;

  bool _isShimmerIndex() => _peoples == null;

  Widget _buildHorizontalListView(bool activeIcon) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ShimmerLoading(
                isLoading: _isShimmerIndex(),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: colorShimmer,
                  backgroundImage: _isShimmerIndex() ? null : NetworkImage(_peoples![index].avatar),
                ),
              ),
              if (!_isShimmerIndex() && activeIcon)
                Positioned(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: colorLight,
                      size: 20,
                    ),
                  ),
                  right: 0,
                  top: 0,
                )
            ],
          );
        },
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _getItemCount(),
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }

  Widget _buildVerticalListView() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _peoples?.length ?? 5,
      itemBuilder: (context, index) {
        final people = _peoples?[index];
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: people == null
              ? ShimmerLoading(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: colorShimmer,
                      ),
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 16),
                            width: 200,
                            height: 16,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              color: colorShimmer,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 16, top: 4),
                            height: 16,
                            width: 200,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              color: colorShimmer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colorShimmer,
                      backgroundImage: NetworkImage(_peoples![index].avatar),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            people.firstname + ' ' + people.lastname,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            people.email,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8, right: 16),
                      height: 12,
                      width: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLoggingInView() {
    return const Center(
      child: Text(
        'Logging in...\nPlease come back in a moment',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(createRoute(const LoginPage()));
        },
        child: const Text('Login and enjoy now!'),
      ),
    );
  }
}
