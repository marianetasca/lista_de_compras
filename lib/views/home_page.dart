import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_trabalho/services/authentication_service.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> itens = [];
  List<Item> favoritos = [];
  List<Item> itensExibidos = [];
  Categoria _categoriaSelecionada = Categoria.todos;
  bool _mostrarApenasFavoritos = false;
  
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarItens().then((_) {
      _filtrarItensPorCategoria();
    });
  }

  // Carregar itens do Firestore
  Future<void> _carregarItens() async {
    try {
      print('Iniciando carregamento...');
      print('UID do usuário: ${widget.user.uid}');

      final userDoc = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user.uid);
      
      print('Verificando documento do usuário...');
      
      // Criar documento do usuário se não existir
      if (!(await userDoc.get()).exists) {
        print('Criando documento do usuário...');
        await userDoc.set({
          'email': widget.user.email,
          'criado_em': FieldValue.serverTimestamp(),
        });
      }

      print('Buscando itens...');
      final snapshot = await userDoc.collection('itens').get();
      print('Dados dos itens:');
      snapshot.docs.forEach((doc) {
        print('Item: ${doc.data()}');
      });
      print('Itens encontrados: ${snapshot.docs.length}');

      setState(() {
        // Convertendo explicitamente cada documento para Item
        itens = List<Item>.from(
          snapshot.docs.map((doc) => Item.fromFirestore(doc))
        );
        
        print('Itens carregados: ${itens.length}');
        favoritos = List<Item>.from(
          itens.where((item) => item.favorito)
        );
        _filtrarItensPorCategoria();
      });
    } catch (e, stack) {
      print('Erro ao carregar itens: $e');
      print('Stack trace: $stack');
    }
  }

  // Salvar item no Firestore
  Future<void> _salvarItem(Item item) async {
    final docRef = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('itens')
        .add(item.toMap());

    item.id = docRef.id;
  }

  // Atualizar item no Firestore
  Future<void> _atualizarItem(Item item) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('itens')
        .doc(item.id)
        .update(item.toMap());
  }

  // Deletar item do Firestore
  Future<void> _deletarItem(Item item) async {
    try {
      // Verifica se o documento existe antes de tentar excluir
      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user.uid)
          .collection('itens')
          .doc(item.id);

      final doc = await docRef.get();
      if (!doc.exists) {
        print('Documento não encontrado no Firestore: ${item.id}');
        // Remove apenas localmente se não existir no Firestore
        setState(() {
          itens.removeWhere((i) => i.id == item.id);
          itensExibidos.removeWhere((i) => i.id == item.id);
          favoritos.removeWhere((i) => i.id == item.id);
        });
        return;
      }

      // Se o documento existe, exclui do Firestore
      await docRef.delete();
      
      // Atualiza a interface após excluir
      setState(() {
        itens.removeWhere((i) => i.id == item.id);
        itensExibidos.removeWhere((i) => i.id == item.id);
        favoritos.removeWhere((i) => i.id == item.id);
      });

      // Atualiza a filtragem
      _filtrarItensPorCategoria();
      
    } catch (e) {
      print('Erro ao deletar item: $e');
      // Você pode adicionar aqui uma mensagem para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir o item. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _adicionarItem({Item? item}) {
    _categoriaSelecionada = item?.categoria ?? Categoria.alimentos;
    DateTime dataSelecionada = item?.data ?? DateTime.now();

    _nomeController.text = item?.nome ?? '';
    _quantidadeController.text = item?.quantidade ?? '';
    _precoController.text = item?.preco.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(item == null ? 'Adicionar Item' : 'Editar Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome do item'),
                  ),
                  TextField(
                    controller: _quantidadeController,
                    decoration: InputDecoration(labelText: 'Quantidade'),
                  ),
                  TextField(
                    controller: _precoController,
                    decoration: InputDecoration(labelText: 'Preço unitário'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  DropdownButton<Categoria>(
                    isExpanded: true,
                    value: _categoriaSelecionada,
                    items: Categoria.values
                        .where((c) => c != Categoria.todos)
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(_getIconeCategoria(c)),
                                  SizedBox(width: 8),
                                  Text(c.name.toUpperCase()),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        _categoriaSelecionada = val!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      DateTime? novaData = await showDatePicker(
                        context: context,
                        initialDate: dataSelecionada,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (novaData != null) {
                        setStateDialog(() {
                          dataSelecionada = novaData;
                        });
                      }
                    },
                    child: Text('Selecionar Data: ${DateFormat('dd/MM/yyyy').format(dataSelecionada)}'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (_nomeController.text.isNotEmpty && _quantidadeController.text.isNotEmpty) {
                    final precoText = _precoController.text.replaceAll('R\$', '').replaceAll(',', '.').trim();
                    final preco = double.tryParse(precoText) ?? 0.0;

                    final novoItem = Item(
                      nome: _nomeController.text,
                      quantidade: _quantidadeController.text,
                      preco: preco,
                      categoria: _categoriaSelecionada,
                      data: dataSelecionada,
                    );

                    if (item == null) {
                      await _salvarItem(novoItem);
                      setState(() {
                        itens.add(novoItem);
                      });
                    } else {
                      novoItem.id = item.id;
                      await _atualizarItem(novoItem);
                      setState(() {
                        int index = itens.indexOf(item);
                        itens[index] = novoItem;
                      });
                    }

                    _filtrarItensPorCategoria();
                    _nomeController.clear();
                    _quantidadeController.clear();
                    _precoController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calcularTotal() {
    return itens.fold(0, (total, item) => 
      total + (item.preco * double.parse(item.quantidade)));
  }

  void _compartilharLista() {
    String listaTexto = "Lista de Compras:\n\n";
    for (var item in itens) {
      listaTexto += "${item.nome} - ${item.quantidade} x R\$${item.preco.toStringAsFixed(2)}\n";
    }
    listaTexto += "\nTotal: R\$${_calcularTotal().toStringAsFixed(2)}";
    
    Share.share(listaTexto);
  }

  Widget _buildItemCard(Item item) {
    return Card(
      color: item.comprado ? Colors.green[50] : Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          _getIconeCategoria(item.categoria),
          color: item.comprado ? Colors.green : null,
        ),
        title: Text(
          item.nome,
          style: TextStyle(
            decoration: item.comprado ? TextDecoration.lineThrough : null,
            color: item.comprado ? Colors.green[900] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade: ${item.quantidade}'),
            Text('Preço: R\$ ${item.preco.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: item.comprado,
              activeColor: Colors.green,
              onChanged: (bool? value) async {
                setState(() {
                  item.comprado = value ?? false;
                });
                await _atualizarItem(item);
              },
            ),
            IconButton(
              icon: Icon(
                item.favorito ? Icons.star : Icons.star_border,
                color: item.favorito ? Colors.amber : null,
              ),
              onPressed: () async {
                setState(() {
                  item.favorito = !item.favorito;
                });
                await _atualizarItem(item);
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _adicionarItem(item: item),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletarItem(item),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconeCategoria(Categoria categoria) {
    switch (categoria) {
      case Categoria.alimentos:
        return Icons.restaurant;
      case Categoria.bebidas:
        return Icons.local_drink;
      case Categoria.higiene:
        return Icons.clean_hands_outlined;
      case Categoria.limpeza:
        return Icons.cleaning_services;
      case Categoria.outros:
        return Icons.more_horiz;
      case Categoria.todos:
        return Icons.all_inclusive;
      default:
        return Icons.category;
    }
  }

  void _filtrarItensPorCategoria() {
    setState(() {
      var itensFiltrados = List<Item>.from(itens);

      // Filtra por data se houver uma data selecionada
      if (_dataSelecionada != null) {
        itensFiltrados = itensFiltrados.where((item) {
          return DateFormat('dd/MM/yyyy').format(item.data) == 
                 DateFormat('dd/MM/yyyy').format(_dataSelecionada!);
        }).toList();
      }

      // Filtra por categoria
      if (_categoriaSelecionada != Categoria.todos) {
        itensFiltrados = itensFiltrados
            .where((item) => item.categoria == _categoriaSelecionada)
            .toList();
      }

      // Filtra favoritos
      if (_mostrarApenasFavoritos) {
        itensFiltrados = itensFiltrados
            .where((item) => item.favorito)
            .toList();
      }

      itensExibidos = itensFiltrados;
    });
  }

  Map<String, List<Item>> _agruparItensPorDia() {
    Map<String, List<Item>> itensPorDia = {};

    // Garante que os itens estão ordenados por data
    List<Item> itensOrdenados = List.from(itensExibidos)
      ..sort((a, b) => b.data.compareTo(a.data));

    for (var item in itensOrdenados) {
      String dataFormatada = DateFormat('dd/MM/yyyy').format(item.data);
      if (!itensPorDia.containsKey(dataFormatada)) {
        itensPorDia[dataFormatada] = [];
      }
      itensPorDia[dataFormatada]!.add(item);
    }

    return itensPorDia;
  }

  void _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
      _filtrarItensPorCategoria();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o total dos itens exibidos
    double totalGeral = itensExibidos.fold(0, (total, item) => total + (item.preco * double.parse(item.quantidade)));
    double totalConcluidos = itensExibidos
        .where((item) => item.comprado)
        .fold(0, (total, item) => total + (item.preco * double.parse(item.quantidade)));

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras"),
        actions: [
          IconButton(
            icon: Icon(_dataSelecionada != null ? Icons.calendar_today : Icons.date_range),
            onPressed: _selecionarData,
          ),
          if (_dataSelecionada != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _dataSelecionada = null;
                });
                _filtrarItensPorCategoria();
              },
            ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _compartilharLista,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.displayName ?? "Não informado"),
              accountEmail: Text(widget.user.email ?? "Não informado"),
            ),
            ...Categoria.values.map((categoria) => 
              ListTile(
                title: Text(categoria.name.toUpperCase()),
                leading: Icon(_getIconeCategoria(categoria)),
                selected: _categoriaSelecionada == categoria,
                onTap: () {
                  setState(() {
                    _categoriaSelecionada = categoria;
                  });
                  _filtrarItensPorCategoria();
                  Navigator.pop(context);
                },
              ),
            ).toList(),
            Divider(),
            ListTile(
              title: Text("Apenas Favoritos"),
              leading: Icon(Icons.star),
              selected: _mostrarApenasFavoritos,
              onTap: () {
                setState(() {
                  _mostrarApenasFavoritos = !_mostrarApenasFavoritos;
                });
                _filtrarItensPorCategoria();
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text("Deslogar"),
              leading: Icon(Icons.logout),
              onTap: () {
                AuthenticationService().logoutUser();
              },
            ),
          ],
        ),
      ),
      body: _buildGroupedList(),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Concluído:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'R\$ ${totalConcluidos.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Geral:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$ ${totalGeral.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (_dataSelecionada != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarItem(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupedList() {
    if (itensExibidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_dataSelecionada != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Data selecionada: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              'Nenhum item encontrado',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    final itensPorDia = _agruparItensPorDia();

    return ListView.builder(
      itemCount: itensPorDia.length,
      itemBuilder: (context, index) {
        final entry = itensPorDia.entries.elementAt(index);
        
        // Agrupar itens por categoria dentro de cada data
        Map<Categoria, List<Item>> itensPorCategoria = {};
        for (var item in entry.value) {
          if (!itensPorCategoria.containsKey(item.categoria)) {
            itensPorCategoria[item.categoria] = [];
          }
          itensPorCategoria[item.categoria]!.add(item);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da Data
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Itens agrupados por categoria
            ...itensPorCategoria.entries.map((categoriaEntry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho da Categoria
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Icon(_getIconeCategoria(categoriaEntry.key)),
                        SizedBox(width: 8),
                        Text(
                          categoriaEntry.key.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Itens da categoria
                  ...categoriaEntry.value.map((item) => _buildItemCard(item)).toList(),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class Item {
  String nome;
  String quantidade;
  bool comprado;
  double preco;
  bool favorito;
  String id;
  Categoria categoria;
  DateTime data;

  Item({
    required this.nome,
    required this.quantidade,
    this.comprado = false,
    this.preco = 0.0,
    this.favorito = false,
    this.id = "",
    this.categoria = Categoria.alimentos,
    DateTime? data,
  }) : this.data = data ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'comprado': comprado,
      'preco': preco,
      'favorito': favorito,
      'categoria': categoria.index,
      'data': data.toIso8601String(),
    };
  }

  factory Item.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Item(
      nome: data['nome'] ?? 'Nome Desconhecido',
      quantidade: data['quantidade'] ?? '0',
      comprado: data['comprado'] ?? false,
      preco: data['preco'] ?? 0.0,
      favorito: data['favorito'] ?? false,
      id: doc.id,
      categoria: Categoria.values[data['categoria'] ?? 0],
      data: data['data'] != null ? DateTime.parse(data['data']) : DateTime.now(),
    );
  }
}

enum Categoria {
  todos,
  alimentos,
  bebidas,
  higiene,
  limpeza,
  outros
}

