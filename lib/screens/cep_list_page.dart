import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'cep_edit_page.dart';

class CepListPage extends StatefulWidget {
  const CepListPage({super.key});

  @override
  _CepListPageState createState() => _CepListPageState();
}

class _CepListPageState extends State<CepListPage> {
  List<ParseObject> _ceps = []; // Lista que armazenará os CEPs

  @override
  void initState() {
    super.initState();
    _loadCeps(); // Carrega os CEPs ao iniciar a tela
  }

  void _loadCeps() async {
    final query = QueryBuilder<ParseObject>(ParseObject('CEP'));
    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        _ceps = response.results as List<ParseObject>;
      });
    } else {
      _showMessage('Erro ao carregar CEPs!');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _editCep(ParseObject cep) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CepEditPage(cepObject: cep)),
    );
    if (result == true) {
      _loadCeps(); // Recarrega a lista após edição
    }
  }

  void _deleteCep(ParseObject cep) async {
    final confirm = await _showConfirmationDialog('Deseja excluir este CEP?');
    if (confirm == true) {
      await cep.delete();
      _loadCeps(); // Recarrega a lista após exclusão
    }
  }

  Future<bool?> _showConfirmationDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmação'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CEPs Cadastrados'),
      ),
      body: _ceps.isEmpty
          ? Center(child: Text('Nenhum CEP cadastrado.'))
          : ListView.builder(
              itemCount: _ceps.length,
              itemBuilder: (context, index) {
                final cep = _ceps[index];
                return ListTile(
                  title: Text('CEP: ${cep.get<String>('cep') ?? ''}'),
                  subtitle: Text('${cep.get<String>('logradouro') ?? ''}, ${cep.get<String>('localidade') ?? ''}-${cep.get<String>('uf') ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editCep(cep),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCep(cep),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
