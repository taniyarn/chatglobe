import 'dart:math';

import 'package:chatglobe/components/circle.dart';
import 'package:chatglobe/constants/colors.dart';
import 'package:chatglobe/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({Key? key}) : super(key: key);

  Future<void> future(BuildContext context) async {
    try {
      if (supabase.auth.currentUser == null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            context.go('/signup');
          },
        );
      }
      await supabase.from('user_events').upsert({
        'user_id': supabase.auth.currentUser!.id,
        'email': supabase.auth.currentUser!.email,
        'event_type': 'confirmation'
      });
    } catch (_) {
      throw Exception('Error confirming user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: FutureBuilder(
        future: future(context),
        builder: (context, snapshot) {
          late Widget child;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              child = Text('Error', style: theme.textTheme.headlineMedium);
            } else {
              child = Text(
                'Confirmed!',
                style: theme.textTheme.headlineMedium,
              );
            }
          } else {
            child = const SizedBox.shrink();
          }
          return Center(
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Circle(
                    primaryColor: kPink,
                    secondaryColor: kBlue,
                    rotateRadians: -1.0 / 4.0 * pi,
                    radius: constraints.maxWidth / 6.0,
                  ),
                  child,
                ],
              );
            }),
          );
        },
      ),
    );
  }
}
