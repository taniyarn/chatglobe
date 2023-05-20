import 'package:chatglobe/pages/chat_page.dart';
import 'package:chatglobe/pages/confirmation_page.dart';
import 'package:chatglobe/pages/profile_creation_page.dart';
import 'package:chatglobe/pages/signin_page.dart';
import 'package:chatglobe/pages/signup_page.dart';
import 'package:chatglobe/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(child: SplashPage()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => const MaterialPage(child: SignupPage()),
    ),
    GoRoute(
      path: '/profile_creation',
      pageBuilder: (context, state) =>
          const MaterialPage(child: ProfileCreationPage()),
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => const MaterialPage(child: ChatPage()),
    ),
    GoRoute(
      path: '/confirmation',
      pageBuilder: (context, state) =>
          const MaterialPage(child: ConfirmationPage()),
    ),
  ],
);
