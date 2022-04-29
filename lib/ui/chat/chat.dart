import 'dart:math';

import 'package:caror/data/data_service.dart';
import 'package:caror/generated/l10n.dart';
import 'package:caror/themes/theme.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/material.dart';

List<Message> randomMessage() {
  final messages = ['Hảo hán', 'Năm ngoái cô mới đá tôi', 'Không phải, anh nhầm rồi, người năm ngoái đá anh là 1 nhân cách khác của em', 'Hãy là một trap girl đẳng cấp'];
  final random = Random();
  return List.generate(10, (index) {
    return Message(
      senderId: random.nextInt(2),
      message: messages[random.nextInt(messages.length)],
      messageType: random.nextInt(5),
      time: random.nextInt(0x7fffffff),
    );
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.name,
    required this.thumbnail,
  }) : super(key: key);

  final String name;
  final String thumbnail;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final _messages = randomMessage();
  final _scrollController = ScrollController();
  final _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editingController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance?.window.viewInsets.bottom;
    if (bottomInset != null && bottomInset > 0) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                forceElevated: true,
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                toolbarHeight: 56,
                shadowColor: Colors.white.withOpacity(0.3),
                elevation: 8,
                snap: true,
                floating: true,
                title: Row(
                  children: [
                    MaterialIconButton(
                      Icons.arrow_back_rounded,
                      padding: 16,
                      color: Colors.black,
                      onPressed: () => Navigator.pop(context),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(DataService.getFullUrl(widget.thumbnail)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                height: 6,
                                width: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                S.current.active,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: colorLight,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    MaterialIconButton(
                      Icons.call_rounded,
                      padding: 8,
                      color: Colors.black,
                      onPressed: () {},
                    ),
                    MaterialIconButton(
                      Icons.info,
                      padding: 8,
                      color: Colors.black,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 32, bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 32, height: 1, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_messages.first.time)),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 32, height: 1, color: Colors.black),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final message = _messages[index];
                    if (message.senderId == 0) {
                      return _ChatItemLeft(
                        message: _messages[index],
                        avatar: widget.thumbnail,
                        isSamePreviousSender: index != 0 && message.senderId == _messages[index - 1].senderId,
                      );
                    } else {
                      return _ChatItemRight(
                        message: _messages[index],
                        avatar: widget.thumbnail,
                        isSamePreviousSender: index != 0 && message.senderId == _messages[index - 1].senderId,
                      );
                    }
                  },
                  childCount: _messages.length,
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 16),
              ),
            ],
          )),
          Container(
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                MaterialIconButton(
                  Icons.photo_camera_rounded,
                  padding: 8,
                  color: Colors.black,
                  onPressed: () {},
                ),
                MaterialIconButton(
                  Icons.attach_file_rounded,
                  padding: 8,
                  color: Colors.black,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      color: colorShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _editingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: S.current.is_any_body_here,
                              isDense: true,
                            ),
                            minLines: 1,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 14,
                            ),
                          ),
                        ),
                        MaterialIconButton(
                          Icons.send_rounded,
                          padding: 12,
                          color: Colors.black,
                          onPressed: () {
                            if (_editingController.text.isNotEmpty) {
                              _messages.add(Message(
                                senderId: 1,
                                message: _editingController.text,
                                messageType: 0,
                                time: DateTime.now().millisecond,
                              ));
                              setState(() {
                                _editingController.clear();
                              });
                              Future.delayed(const Duration(milliseconds: 100), () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.linear,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatItemLeft extends StatelessWidget {
  const _ChatItemLeft({
    required this.message,
    required this.avatar,
    required this.isSamePreviousSender,
  }) : super();

  final Message message;
  final String avatar;
  final bool isSamePreviousSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isSamePreviousSender ? 8 : 16, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isSamePreviousSender
              ? const SizedBox(width: 32)
              : CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(DataService.getFullUrl(avatar)),
                ),
          const SizedBox(width: 4),
          Expanded(
            child: message.messageType == 4
                ? Padding(
                    padding: const EdgeInsets.only(right: 48),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      child: CommonWidget.image(
                        avatar,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        margin: const EdgeInsets.only(right: 48),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                          color: colorShadow,
                        ),
                        child: Text(
                          message.message,
                          style: const TextStyle(fontSize: 14),
                        )),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatItemRight extends StatelessWidget {
  const _ChatItemRight({
    required this.message,
    required this.avatar,
    required this.isSamePreviousSender,
  }) : super();

  final Message message;
  final String avatar;
  final bool isSamePreviousSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isSamePreviousSender ? 8 : 16, left: 64, right: 16),
      child: message.messageType == 4
          ? ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              child: CommonWidget.image(
                avatar,
                fit: BoxFit.fitWidth,
              ),
            )
          : Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  color: colorShadow,
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
    );
  }
}

class Message {
  Message({
    required this.senderId,
    required this.message,
    required this.messageType,
    required this.time,
  });

  final int senderId;
  final String message;
  final int messageType;
  final int time;
}
