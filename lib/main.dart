import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'screens/cep_search_page.dart'; // Importa a tela inicial do aplicativo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Substitua pelas suas chaves do Back4App
  const String keyApplicationId = 'd6VTfnoiE1WTCSnTn3XnjmFNXv2tToUCsYc16mn1';
  const String keyClientKey = 'KOFNj8ZclHs83RF20vptaZYLGWpQM84K36cYHCZ8';
  const String keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Adicionamos o parâmetro `key` ao construtor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Via CEP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CepSearchPage(), // Define a tela inicial do aplicativo
    );
  }
}
