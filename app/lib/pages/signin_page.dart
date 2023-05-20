import 'dart:async';
import 'dart:math';

import 'package:chatglobe/components/circle.dart';
import 'package:chatglobe/components/header.dart';
import 'package:chatglobe/constants/colors.dart';
import 'package:chatglobe/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../layout/responsive_layout_builder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      if (mounted) {
        _emailController.clear();
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
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
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        context.go('/profile_creation');
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                                primaryColor: kYellow,
                                secondaryColor: kGreen,
                                rotateRadians: 5.0 / 4.0 * pi,
                                radius: constraints.maxWidth / 4.0,
                              );
                            }),
                          ),
                          _Content(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: _isLoading,
                            signIn: _signIn,
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
                                  signIn: _signIn,
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
                      primaryColor: kYellow,
                      secondaryColor: kGreen,
                      rotateRadians: 5.0 / 4.0 * pi,
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
                                  signIn: _signIn,
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
                      primaryColor: kYellow,
                      secondaryColor: kGreen,
                      rotateRadians: 5.0 / 4.0 * pi,
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
    required this.signIn,
  }) : super(key: key);

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final void Function() signIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome back',
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
                color: kYellow.withOpacity(0.8),
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          cursorColor: kYellow.withOpacity(0.8),
        ),
        const SizedBox(height: 24),
        Text('Password', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: kYellow.withOpacity(0.8),
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          cursorColor: kYellow.withOpacity(0.8),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isLoading ? null : signIn,
          style: ElevatedButton.styleFrom(
            foregroundColor: kGreen.withOpacity(0.8),
            backgroundColor: kYellow.withOpacity(0.8),
            surfaceTintColor: kGreen.withOpacity(0.8),
            disabledBackgroundColor: kGreen.withOpacity(0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              isLoading ? 'Loading' : 'Login',
              style: theme.textTheme.headlineSmall,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              context.go('/signup');
            },
            style: TextButton.styleFrom(
              foregroundColor: kYellow.withOpacity(0.8),
            ),
            child: Text(
              'Create an account',
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
