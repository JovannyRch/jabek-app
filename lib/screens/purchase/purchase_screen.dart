import 'package:flutter/material.dart';
import 'package:jebek_app/models/expense.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Expense> expenses = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        fetchExpenses();
      }
    });
  }

  Future<void> fetchExpenses() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.fetchPaginated<Expense>(
        "/expenses",
        currentPage,
        Expense.fromJson,
      );

      setState(() {
        expenses.addAll(response.data);
        currentPage++;
        hasMore = response.hasMore;
      });
    } catch (e) {
      print("Error al cargar gastos: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compras', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: expenses.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == expenses.length) {
            return Center(child: CircularProgressIndicator());
          }

          final expense = expenses[index];
          return ListTile(
            title: Text(expense.concept),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Monto: ${formatCurrency(expense.amount)}"),
                Text("Fecha: ${expense.date}"),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create-expense',
        onPressed: () async {
          final response = await Navigator.pushNamed(
            context,
            '/create_purchase',
          );

          if (response == true) {
            setState(() {
              expenses.clear();
              currentPage = 1;
              hasMore = true;
            });
            fetchExpenses();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
