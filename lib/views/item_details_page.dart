import 'package:flutter/material.dart';
import 'package:flutter_trabalho/views/home_page.dart';
import 'package:intl/intl.dart';

class ItemDetailsPage extends StatelessWidget {
  final Item item;

  const ItemDetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.nome,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Quantidade:', item.quantidade),
            _buildInfoRow('Preço:', 'R\$ ${item.preco.toStringAsFixed(2)}'),
            _buildInfoRow('Categoria:', item.categoria.name),
            _buildInfoRow(
              'Data:',
              DateFormat('dd/MM/yyyy').format(item.data),
            ),
            _buildInfoRow('Status:', item.comprado ? 'Comprado' : 'Pendente'),
            _buildInfoRow('Favorito:', item.favorito ? 'Sim' : 'Não'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
} 