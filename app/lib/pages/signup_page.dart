import 'dart:async';
import 'dart:math';

import 'package:chatglobe/components/circle.dart';
import 'package:chatglobe/components/header.dart';
import 'package:chatglobe/constants/colors.dart';
import 'package:chatglobe/layout/responsive_layout_builder.dart';
import 'package:chatglobe/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isLoading = false;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      supabase.channel('public:user_events').on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(event: 'INSERT', schema: 'public', table: 'user_events'),
        (payload, [ref]) async {
          if (payload['new']['email'] == email) {
            await supabase.auth
                .signInWithPassword(email: email, password: password);
            if (mounted) context.go('/profile_creation');
          }
        },
      ).subscribe();

      await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          emailRedirectTo: 'https://chatglobe.vercel.app/confirmation');

      if (mounted) {
        context.showSnackBar(message: 'Check your email for sign up link!');
        _emailController.clear();
        _passwordController.clear();
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: error.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        context.go('/profile_creation');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayoutBuilder(
        small: (context, _) {
          return Padding(
            padding: const EdgeInsets.only(left: 48.0, right: 48.0, top: 48.0),
            child: Column(
              children: [
                const Header(),
                const SizedBox(height: 48.0),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(48.0),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Circle(
                                primaryColor: kPink,
                                secondaryColor: kBlue,
                                rotateRadians: -1.0 / 4.0 * pi,
                                radius: constraints.maxWidth / 4.0,
                              );
                            }),
                          ),
                          _Content(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: _isLoading,
                            signUp: _signUp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        medium: (context, _) {
          return Row(
            children: [
              Flexible(
                flex: 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 48.0, right: 48.0, top: 48.0),
                      child: Column(
                        children: [
                          const Header(),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: _Content(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  isLoading: _isLoading,
                                  signUp: _signUp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Flexible(
                  flex: 4,
                  child: Center(
                    child: Circle(
                      primaryColor: kPink,
                      secondaryColor: kBlue,
                      rotateRadians: -1.0 / 4.0 * pi,
                      radius: 400,
                    ),
                  ))
            ],
          );
        },
        large: (context, _) {
          return Row(
            children: [
              Flexible(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 48.0, right: 48.0, top: 48.0),
                      child: Column(
                        children: [
                          const Header(),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: _Content(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  isLoading: _isLoading,
                                  signUp: _signUp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Flexible(
                  flex: 6,
                  child: Center(
                    child: Circle(
                      primaryColor: kPink,
                      secondaryColor: kBlue,
                      rotateRadians: -1.0 / 4.0 * pi,
                      radius: 400,
                    ),
                  ))
            ],
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.signUp,
  }) : super(key: key);

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final void Function() signUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create a free account',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 64),
        Text('Email Address', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: kPink.withOpacity(0.8),
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          cursorColor: kPink.withOpacity(0.8),
        ),
        const SizedBox(height: 24),
        Text('Password', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: kPink.withOpacity(0.8),
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          cursorColor: kPink.withOpacity(0.8),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isLoading ? null : signUp,
          style: ElevatedButton.styleFrom(
            foregroundColor: kBlue.withOpacity(0.8),
            backgroundColor: kPink.withOpacity(0.8),
            surfaceTintColor: kBlue.withOpacity(0.8),
            disabledBackgroundColor: kBlue.withOpacity(0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              isLoading ? 'Loading' : 'Create account',
              style: theme.textTheme.headlineSmall,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              context.go('/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: kPink.withOpacity(0.8),
            ),
            child: Text(
              'Already have an account?',
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
