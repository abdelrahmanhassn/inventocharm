import 'package:bloc/bloc.dart';
import 'package:inventocharm/simple_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:inventocharm/services/pocketbase_client.dart';
import 'package:user_repository/user_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  runApp(MainApp(PocketBaseUserRepo(pocketBase)));
}
