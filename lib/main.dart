import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/business_provider.dart';
import 'services/business_service.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ScaffoldScreen(),
      ),
    );
  }
}

class ScaffoldScreen extends StatelessWidget {
  const ScaffoldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genny Test'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, provider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.business,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Business Directory',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Show state management working
                Text(
                  'State: ${provider.state.name}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadBusinesses(),
                  child: const Text('Load Business Data'),
                ),
                if (provider.businesses.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Loaded ${provider.businesses.length} businesses',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
