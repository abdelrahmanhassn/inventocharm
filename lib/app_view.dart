import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventocharm/components/perrsistent_nav_bar.dart';
import 'package:inventocharm/components/theme/theme.dart';
import 'package:inventocharm/screens/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:inventocharm/screens/auth/views/welcome_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthenticationUserStatus.authenticated:
              return const PersistentTabScreen();
            case AuthenticationUserStatus.unauthenticated:
              return const WelcomeScreen();
            case AuthenticationUserStatus.unknown:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
          }
        },
      ),
    );
  }
}
