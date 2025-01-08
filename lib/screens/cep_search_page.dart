import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cep_list_page.dart';

class CepSearchPage extends StatefulWidget {
  const CepSearchPage({super.key});

  @override
  _CepSearchPageState createState() => _CepSearchPageState();
}

class _CepSearchPageState extends State<CepSearchPage> {
  final _cepController = TextEditingController();

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  void _searchCep() async {
    final cep = _cepController.text.trim();

    if (cep.isEmpty) {
      _showMessage('Por favor, digite um CEP válido.');
      return;
    }

    // Verifica se o CEP já existe no Back4App
    final existingCep = await _checkIfCepExists(cep);

    if (existingCep != null) {
      _showCepData(existingCep);
    } else {
      await _fetchAndSaveCep(cep);
    }

    _cepController.clear();
  }

  Future<ParseObject?> _checkIfCepExists(String cep) async {
    final query = QueryBuilder<ParseObject>(ParseObject('CEP'))
      ..whereEqualTo('cep', cep);

    final response = await query.query();

    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseObject;
    } else {
      return null;
    }
  }

  Future<void> _fetchAndSaveCep(String cep) async {
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('erro')) {
          _showMessage('CEP não encontrado!');
        } else {
          await _saveCepToBack4App(data);
          _showCepDataFromMap(data);
        }
      } else {
        _showMessage('Erro na busca do CEP!');
      }
    } catch (e) {
      _showMessage('Ocorreu um erro: $e');
    }
  }

  Future<void> _saveCepToBack4App(Map<String, dynamic> data) async {
    final cepObject = ParseObject('CEP')
      ..set('cep', data['cep'])
      ..set('logradouro', data['logradouro'])
      ..set('bairro', data['bairro'])
      ..set('localidade', data['localidade'])
      ..set('uf', data['uf']);

    await cepObject.save();
  }

  void _showCepData(ParseObject cepObject) {
    final data = {
      'cep': cepObject.get<String>('cep'),
      'logradouro': cepObject.get<String>('logradouro'),
      'bairro': cepObject.get<String>('bairro'),
      'localidade': cepObject.get<String>('localidade'),
      'uf': cepObject.get<String>('uf'),
    };
    _showCepDataFromMap(data);
  }

  void _showCepDataFromMap(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Dados do CEP'),
        content: Text(
          'CEP: ${data['cep']}\n'
          'Logradouro: ${data['logradouro']}\n'
          'Bairro: ${data['bairro']}\n'
          'Cidade: ${data['localidade']}\n'
          'UF: ${data['uf']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar CEP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              decoration: InputDecoration(
                labelText: 'Digite o CEP',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchCep,
              child: Text('Buscar'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de listagem
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CepListPage()),
                );
              },
              child: Text('Listar CEPs Cadastrados'),
            ),
          ],
        ),
      ),
    );
  }
}
