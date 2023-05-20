import 'dart:math';

import 'package:chatglobe/components/avatar.dart';
import 'package:chatglobe/components/circle.dart';
import 'package:chatglobe/components/header.dart';
import 'package:chatglobe/constants/colors.dart';
import 'package:chatglobe/layout/responsive_layout_builder.dart';
import 'package:chatglobe/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _avatarUrl;
  var _isLoading = false;

  Future<void> _getProfile() async {
    setState(() {
      _isLoading = false;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single() as Map;
      _nameController.text = (data['username'] ?? '') as String;
      _descriptionController.text = (data['description'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected exception occurred');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    final userName = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final user = supabase.auth.currentUser;

    final updates = {
      'user_id': user!.id,
      'username': userName,
      'description': description,
    };
    if (userName.isEmpty) {
      context.showErrorSnackBar(message: 'Username cannot be empty');
      return;
    }

    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        context.go('/chat');
      }
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpeted error occurred');
    }
    setState(() {
      _isLoading = false;
    });
  }

  // -- (auth.uid() = user_id)

  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'user_id': userId,
        'avatar_url': imageUrl,
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error has occurred');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
                                primaryColor: kLightBlue,
                                secondaryColor: kRed,
                                rotateRadians: 5.0 / 4.0 * pi,
                                radius: constraints.maxWidth / 4.0,
                              );
                            }),
                          ),
                          _Content(
                            avatarUrl: _avatarUrl,
                            nameController: _nameController,
                            descriptionController: _descriptionController,
                            onUpload: _onUpload,
                            updateProfile: _updateProfile,
                            isLoading: _isLoading,
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
                                  avatarUrl: _avatarUrl,
                                  nameController: _nameController,
                                  descriptionController: _descriptionController,
                                  onUpload: _onUpload,
                                  updateProfile: _updateProfile,
                                  isLoading: _isLoading,
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
                      primaryColor: kLightBlue,
                      secondaryColor: kRed,
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
                                  avatarUrl: _avatarUrl,
                                  nameController: _nameController,
                                  descriptionController: _descriptionController,
                                  onUpload: _onUpload,
                                  updateProfile: _updateProfile,
                                  isLoading: _isLoading,
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
                      primaryColor: kLightBlue,
                      secondaryColor: kRed,
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
    required this.avatarUrl,
    required this.nameController,
    required this.descriptionController,
    required this.onUpload,
    required this.updateProfile,
    required this.isLoading,
  }) : super(key: key);

  final String? avatarUrl;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final void Function(String imageUrl) onUpload;
  final void Function() updateProfile;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create your profile',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 64),
        Text('Profile Image', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 12),
        Align(
            alignment: Alignment.centerLeft,
            child: Avatar(imageUrl: avatarUrl, onUpload: onUpload)),
        const SizedBox(height: 24),
        Text('Name', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: kLightBlue.withOpacity(0.8),
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          cursorColor: kLightBlue.withOpacity(0.8),
        ),
        const SizedBox(height: 24),
        Text('Description', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: kLightBlue.withOpacity(0.8),
              ),
            ),
            border: const OutlineInputBorder(),
          ),
          cursorColor: kLightBlue.withOpacity(0.8),
          maxLines: 4,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isLoading ? null : updateProfile,
          style: ElevatedButton.styleFrom(
            foregroundColor: kRed.withOpacity(0.8),
            backgroundColor: kLightBlue.withOpacity(0.8),
            surfaceTintColor: kRed.withOpacity(0.8),
            disabledBackgroundColor: kRed.withOpacity(0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              isLoading ? 'Loading' : 'Done',
              style: theme.textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}
