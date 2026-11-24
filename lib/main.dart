import 'package:flutter/material.dart';

import 'common/local_storage.dart';
import 'common/session.dart';
import 'iam/presentation/login_page.dart';
import 'shared/presentation/app_theme.dart';
import 'shared/presentation/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  Session.restore();
  runApp(const SmartGasApp());
}

/// App SmartGas en Flutter. Consume el mismo backend que la web y la app Android.
class SmartGasApp extends StatelessWidget {
  const SmartGasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGas',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Si hay una sesion guardada en el telefono, entra directo a la app
      home: Session.isLoggedIn ? const MainShell() : const LoginPage(),
    );
  }
}
