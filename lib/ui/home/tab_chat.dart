import 'package:caror/data/data_service.dart';
import 'package:caror/entity/people.dart';
import 'package:caror/generated/l10n.dart';
import 'package:caror/themes/number.dart';
import 'package:caror/themes/theme.dart';
import 'package:caror/ui/chat/chat.dart';
import 'package:caror/ui/home/home.dart';
import 'package:caror/ui/login/login.dart';
import 'package:caror/widget/shimmer_loading.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  static bool isStart = true;

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  LoginState? _loginState;
  late final _statusBarHeight = Number.getStatusBarHeight(context);
  List<People>? _peoples;

  @override
  initState() {
    _loginState = HomePageState.of(context)?.loginState;
    if (_loginState == LoginState.loggedIn) {
      ChatTab.isStart = true;
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
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: S.current.search_name_phone_number,
                      ),
                      style: const TextStyle(fontFamily: "Montserrat"),
                    ),
                  ),
                  MaterialIconButton(Icons.search_rounded, padding: 16, onPressed: () {}),
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
                : Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      S.current.recent,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
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
                : Padding(
                    padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
                    child: Text(
                      S.current.friends,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
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
                        S.current.contacts_number(_peoples!.length),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      const Spacer(),
                      Text(
                        S.current.view_all,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
            _buildVerticalListView(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  int _getItemCount() => _peoples?.length ?? shimmerItemCount;

  bool _isShimmerIndex() => _peoples == null;

  Widget _buildHorizontalListView(bool activeIcon) {
    final peoples = _peoples?.toList()?..shuffle();
    return SizedBox(
      height: 64,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _HorizontalItem(people: peoples?[index], activeIcon: activeIcon);
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
      itemCount: _getItemCount(),
      itemBuilder: (context, index) {
        final people = _peoples?[index];
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: people == null ? _VerticalShimmerItem() : _VerticalItem(index: index,people: _peoples![index]),
        );
      },
    );
  }

  Widget _buildLoggingInView() {
    return Center(
      child: Text(
        S.current.logging_in_lease_come_back_in_a_moment,
        textAlign: TextAlign.center,
        style: const TextStyle(
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
        child: Text(S.current.login_and_enjoy_now),
      ),
    );
  }
}

class _HorizontalItem extends StatelessWidget {
  const _HorizontalItem({this.people, required this.activeIcon}) : super();

  final People? people;
  final bool activeIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShimmerLoading(
          isLoading: people == null,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: colorShimmer,
            backgroundImage: people == null ? null : NetworkImage(DataService.getFullUrl(people!.avatar)),
          ),
        ),
        if (people != null && activeIcon)
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
  }
}

class _VerticalShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
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
    );
  }
}

class _VerticalItem extends StatefulWidget {
  const _VerticalItem({required this.index, required this.people}) : super();

  final int index;
  final People people;

  @override
  State<_VerticalItem> createState() => _VerticalItemState();
}

class _VerticalItemState extends State<_VerticalItem> {
  bool _animate = false;

  @override
  void initState() {
    ChatTab.isStart
        ? Future.delayed(Duration(milliseconds: widget.index * 100), () {
            setState(() {
              _animate = true;
              ChatTab.isStart = false;
            });
          })
        : _animate = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _animate ? 1 : 0,
      curve: Curves.easeInOutQuart,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: _animate ? EdgeInsets.zero : const EdgeInsets.only(top: 16),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(createAnimateRoute(
              context,
              ChatPage(
                name: widget.people.fullName,
                thumbnail: widget.people.avatar,
                people: widget.people,
              ),
            ));
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorShimmer,
                backgroundImage: NetworkImage(DataService.getFullUrl(widget.people.avatar)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.people.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      widget.people.username,
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
        ),
      ),
    );
  }
}
