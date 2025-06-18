import 'package:flutter/material.dart';
import 'package:flutter_app/graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/authentication/screens/welcome_screen.dart';
//import 'package:flutter_app/features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? initialToken = prefs.getString('jwt_token');

  runApp(MyApp(initialToken: initialToken));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MyGraphQLProvider(
      initialToken: initialToken,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Plan Paw',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: const Color(0xFFF7FFF7),
          fontFamily: 'Poppins',
        ),
        initialRoute: initialToken != null && initialToken!.isNotEmpty
            ? '/home'
            : '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
