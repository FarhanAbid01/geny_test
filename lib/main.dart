import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/business_provider.dart';
import 'services/business_service.dart';
import 'screens/business_list_screen.dart';

void main() {
  runApp(const GennyTestApp());
}

class GennyTestApp extends StatelessWidget {
  const GennyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BusinessService>(
          create: (_) => BusinessService(),
        ),
        ChangeNotifierProvider<BusinessProvider>(
          create: (context) => BusinessProvider(
            context.read<BusinessService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Genny Test - Business Directory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[700],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const BusinessListScreen(),
      ),
    );
  }
}

