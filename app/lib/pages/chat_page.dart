import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:chatglobe/components/circle.dart';
import 'package:chatglobe/constants/colors.dart';
import 'package:chatglobe/models/message.dart';
import 'package:chatglobe/models/profile.dart';
import 'package:chatglobe/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/header.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _primaryColorAnimation;
  late Animation<Color?> _secondaryColorAnimation;
  final _random = Random();

  final colors = [kPink, kBlue, kYellow, kGreen, kLightBlue, kRed];

  late Color _primaryBeginColor;
  late Color _primaryEndColor;
  late Color _secondaryBeginColor;
  late Color _secondaryEndColor;
  final Map<String, Profile> _profileCache = {};

  Language selectedLanguage = Languages.english;

  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool isLoading = false;

  Future<Message> translateMessage(Message message) async {
    final response = await supabase.functions.invoke('dart_edge',
        body: {
          'language': selectedLanguage.name,
          'content': message.content,
        },
        responseType: ResponseType.text);
    final json = jsonDecode(response.data);
    final content = (json['choices'] as List).first['text'];

    return message.copyWith(content: content.trim());
  }

  void _loadMessages() async {
    setState(() {
      isLoading = true;
    });
    final startIndex = _messages.length;
    final endIndex = startIndex + 25;

    final newMessages = await _fetchMessages(startIndex, endIndex);
    for (final message in newMessages) {
      _loadProfileCache(message.userId);
    }

    final translatedMessages = await Future.wait(
        newMessages.map((message) async => translateMessage(message)));

    setState(() {
      _messages.addAll(translatedMessages);
      isLoading = false;
    });
  }

  Future<List<Message>> _fetchMessages(int startIndex, int endIndex) async {
    final response = await supabase
        .from('messages')
        .select()
        .range(startIndex, endIndex)
        .order('created_at') as List;

    return response
        .map((json) => Message.fromJson(toCamelCaseMap(json)
          ..addEntries([
            MapEntry('isMine', json['user_id'] == supabase.auth.currentUser!.id)
          ])))
        .toList();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMessages();
    }
  }

  void _handleRealtimeMessage(Map<String, dynamic> newRecord) async {
    final newMessage = Message.fromJson(toCamelCaseMap(newRecord)
      ..addEntries([
        MapEntry(
            'isMine', newRecord['user_id'] == supabase.auth.currentUser!.id)
      ]));
    _loadProfileCache(newMessage.userId);
    final translatedMessage = await translateMessage(newMessage);
    setState(() {
      _messages.insert(0, translatedMessage);
    });
  }

  @override
  void initState() {
    supabase.channel('public:messages').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'messages'),
      (payload, [ref]) async {
        _handleRealtimeMessage(payload['new']);
      },
    ).subscribe();

    _loadMessages();
    _scrollController.addListener(_scrollListener);

    _primaryBeginColor = colors[_random.nextInt(colors.length)];
    _primaryEndColor = colors[_random.nextInt(colors.length)];
    _secondaryBeginColor = colors[_random.nextInt(colors.length)];
    _secondaryEndColor = colors[_random.nextInt(colors.length)];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..repeat()
      ..addListener(() {
        if (_animationController.status == AnimationStatus.completed) {
          _primaryBeginColor = _primaryEndColor;
          _primaryEndColor = colors[_random.nextInt(colors.length)];
          _primaryColorAnimation =
              ColorTween(begin: _primaryBeginColor, end: _primaryEndColor)
                  .animate(_animationController);

          _secondaryBeginColor = _secondaryEndColor;
          _secondaryEndColor = colors[_random.nextInt(colors.length)];
          _secondaryColorAnimation =
              ColorTween(begin: _secondaryBeginColor, end: _secondaryEndColor)
                  .animate(_animationController);

          _animationController.reset();
          _animationController.forward();
        }
      })
      ..forward();

    _primaryColorAnimation =
        ColorTween(begin: _primaryBeginColor, end: _primaryEndColor)
            .animate(_animationController);
    _secondaryColorAnimation =
        ColorTween(begin: _secondaryBeginColor, end: _secondaryEndColor)
            .animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileCache(String userId) async {
    if (_profileCache[userId] != null) {
      return;
    }
    final data =
        await supabase.from('profiles').select().eq('user_id', userId).single();
    final profile = Profile.fromJson(toCamelCaseMap(data));
    setState(() {
      _profileCache[userId] = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final radius = sqrt(width * width + height * height) / 2 * 0.92;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Circle(
                  primaryColor: _primaryColorAnimation.value!,
                  secondaryColor: _secondaryColorAnimation.value!,
                  rotateRadians: -1.0 / 4.0 * pi,
                  radius: clampDouble(radius, 0, 1000),
                  isBackground: true,
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Row(
                        children: [
                          const Header(),
                          const Expanded(
                            child: SizedBox.shrink(),
                          ),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                supabase.auth.signOut();
                                context.go('/');
                              },
                              child: Text(
                                'Sign out',
                                style: theme.textTheme.bodyMedium,
                              )),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 96,
                            child: LanguagePickerDropdown(
                              initialValue: selectedLanguage,
                              itemBuilder: (language) => Text(language.name,
                                  style: theme.textTheme.bodyMedium),
                              onValuePicked: (Language language) {
                                setState(() {
                                  selectedLanguage = language;
                                  _messages.clear();
                                  _loadMessages();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                          child: isLoading && _messages.isEmpty
                              ? Center(
                                  child: Text(
                                    'Loading...',
                                    style: theme.textTheme.headlineSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _messages.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Start your conversation now!',
                                        style: theme.textTheme.headlineSmall,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 48),
                                      reverse: true,
                                      controller: _scrollController,
                                      itemCount: _messages.length,
                                      itemBuilder: (context, index) {
                                        final message = _messages[index];
                                        return AnimatedBuilder(
                                            animation: _animationController,
                                            builder: (context, _) {
                                              return _ChatBubble(
                                                message: message,
                                                profile: _profileCache[
                                                    message.userId],
                                                primaryColor:
                                                    _primaryColorAnimation
                                                        .value!,
                                                secondaryColor:
                                                    _secondaryColorAnimation
                                                        .value!,
                                              );
                                            });
                                      },
                                    ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, _) {
                                return _MessageBar(
                                    color: _primaryColorAnimation.value!);
                              }),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBar extends StatefulWidget {
  const _MessageBar({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      maxLines: null,
      autofocus: true,
      controller: _textController,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.color.withOpacity(0.2),
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        hintText: 'Enter your message here...',
        suffixIcon: IconButton(
          onPressed: () => _submitMessage(),
          icon: Transform.rotate(angle: -pi / 4, child: const Icon(Icons.send)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'user_id': myUserId,
        'content': text,
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: 'An unknown error occurred.');
    }
  }
}

class _ChatBubble extends StatelessWidget {
  _ChatBubble({
    Key? key,
    required this.message,
    required this.profile,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  final Message message;
  final Profile? profile;
  final Color primaryColor;
  final Color secondaryColor;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget avatar(double radius) => CircleAvatar(
        radius: radius,
        backgroundColor: secondaryColor.withOpacity(0.2),
        foregroundColor: Colors.white,
        backgroundImage: profile?.avatarUrl != null
            ? NetworkImage(profile!.avatarUrl!)
            : null,
        child: profile == null
            ? const Icon(Icons.person)
            : profile!.avatarUrl == null
                ? Text(
                    profile!.username.substring(0, 2),
                  )
                : const SizedBox.shrink());
    List<Widget> chatContents = [
      if (!message.isMine) ...[
        Align(
          alignment: Alignment.topCenter,
          child: ClipOval(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            title: const Text('Profile'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: avatar(64)),
                                  const SizedBox(height: 16),
                                  Text('Name',
                                      style: theme.textTheme.bodySmall!
                                          .copyWith(
                                              color: Colors.white
                                                  .withOpacity(0.4))),
                                  const SizedBox(height: 4),
                                  Text(profile?.username ?? 'Unknown',
                                      style: theme.textTheme.bodyLarge),
                                  const SizedBox(height: 16),
                                  Text('Description',
                                      style: theme.textTheme.bodySmall!
                                          .copyWith(
                                              color: Colors.white
                                                  .withOpacity(0.4))),
                                  const SizedBox(height: 4),
                                  Text(profile?.description ?? '',
                                      style: theme.textTheme.bodyLarge),
                                ],
                              ),
                            )),
                      ),
                  child: avatar(16)),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine
                ? primaryColor.withOpacity(0.2)
                : secondaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 8),
      Text(_dateFormat.format(message.createdAt.toLocal()),
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(width: 64),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment:
              message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: chatContents,
        ),
      ),
    );
  }
}
