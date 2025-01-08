import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class CepEditPage extends StatefulWidget {
  final ParseObject cepObject;

  const CepEditPage({super.key, required this.cepObject});

  @override
  _CepEditPageState createState() => _CepEditPageState();
}

class _CepEditPageState extends State<CepEditPage> {
  // Controladores para os campos de texto
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _ufController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os valores atuais do CEP
    _logradouroController.text = widget.cepObject.get<String>('logradouro') ?? '';
    _bairroController.text = widget.cepObject.get<String>('bairro') ?? '';
    _localidadeController.text = widget.cepObject.get<String>('localidade') ?? '';
    _ufController.text = widget.cepObject.get<String>('uf') ?? '';
  }

  @override
  void dispose() {
    // Libera os recursos dos controladores quando não são mais necessários
    _logradouroController.dispose();
    _bairroController.dispose();
    _localidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    // Atualiza os valores do objeto CEP com os dados dos controladores
    widget.cepObject
      ..set('logradouro', _logradouroController.text)
      ..set('bairro', _bairroController.text)
      ..set('localidade', _localidadeController.text)
      ..set('uf', _ufController.text);

    // Salva as alterações no Back4App
    await widget.cepObject.save();

    // Retorna para a tela anterior e indica que houve uma edição
    Navigator.pop(context, true); // Retorna para atualizar a lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar CEP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'CEP: ${widget.cepObject.get<String>('cep') ?? ''}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _logradouroController,
              decoration: InputDecoration(labelText: 'Logradouro'),
            ),
            TextField(
              controller: _bairroController,
              decoration: InputDecoration(labelText: 'Bairro'),
            ),
            TextField(
              controller: _localidadeController,
              decoration: InputDecoration(labelText: 'Cidade'),
            ),
            TextField(
              controller: _ufController,
              decoration: InputDecoration(labelText: 'UF'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
