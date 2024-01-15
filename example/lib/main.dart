import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:example/services/couchbase_service.dart';
import 'package:flutter/material.dart';
import 'package:example/view_models/login_view_model.dart';
import 'package:example/views/login_screen_view.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CouchbaseLiteFlutter.init();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final CouchbaseService _couchbaseService;

  @override
  void initState() {
    super.initState();
    _couchbaseService = CouchbaseService();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(couchbaseService: _couchbaseService),
        ),
      ],
      child: MaterialApp(
        title: 'Couchbase Lite Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
