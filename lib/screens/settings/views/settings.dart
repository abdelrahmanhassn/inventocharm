import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventocharm/components/app_bar/custom_app_bar.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/widgets/primary_header.dart';
import 'package:inventocharm/screens/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:inventocharm/screens/auth/blocs/signin_bloc/signin_bloc.dart';
import 'package:inventocharm/screens/settings/services/settings_service.dart';
import 'package:inventocharm/screens/settings/widgets/clear_sales_button.dart';
import 'package:inventocharm/screens/settings/widgets/export_to_cvs_button.dart';
import 'package:user_repository/user_repository.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _displayName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final userId = context.read<AuthenticationBloc>().state.user!.id;
    final userService = SettingsService();
    try {
      final userData = await userService.getUserData(userId);
      if (userData != null) {
        setState(() {
          _displayName = userData['displayName'] ?? '';
          _isLoading = false;
        });
      } else {
        // Handle case where user data is not found
        print('User data not found');
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationUserStatus.authenticated) {
            final user = state.user!;
            return SettingsScreen(user: user, displayName: _displayName);
          } else if (state.status == AuthenticationUserStatus.unauthenticated) {
            return Center(
              child: Text('You are not authenticated.'),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final AuthUser user;
  final String displayName;

  const SettingsScreen(
      {Key? key, required this.user, required this.displayName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomPrimaryHeader(
            child: Column(children: [
              CustomAppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Inventocharm',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .apply(color: CustomColors.white),
                    ),
                    Text(
                      'Settings',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .apply(color: CustomColors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        'assets/images/content/user.png',
                      ),
                    ),
                    Text(
                      displayName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: CustomColors.white),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .apply(color: CustomColors.white),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                const ClearSalesButton(),
                const SizedBox(height: 16),
                const ExportToExcelButton(),
                const SizedBox(height: 16),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.error,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      context.read<SignInBloc>().add(SignOutRequired());
                    },
                    child: Text('Sign Out')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
