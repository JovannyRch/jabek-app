import 'package:flutter/material.dart';
import 'package:jebek_app/models/expense.dart';
import 'package:jebek_app/screens/purchase/purchase_detail_screen.dart';
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
  int totalExpenses = 0;

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
        totalExpenses = response.total;
      });
    } catch (e) {
      print("Error al cargar compras: $e");
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
        title: const Text('Compras', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        /*  actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Aquí podrías implementar una búsqueda o filtro para las compras.
            },
          ),
        ], */
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            expenses.clear();
            currentPage = 1;
            hasMore = true;
          });
          await fetchExpenses();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: expenses.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == expenses.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final expense = expenses[index];
            return _renderExpenseItem(expense);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create-expense',
        onPressed: () async {
          final check = await checkPurchasesLimit(totalExpenses, context);

          if (!check) {
            return;
          }

          final response = await Navigator.pushNamed(
            context,
            '/create_purchase',
          );
          if (response == true) {
            _refreshData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _refreshData() {
    setState(() {
      expenses.clear();
      currentPage = 1;
      hasMore = true;
    });
    fetchExpenses();
  }

  Widget _renderExpenseItem(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.shopping_cart, color: Colors.white),
        ),
        title: Text(
          expense.concept,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Monto: ${formatCurrency(expense.amount)}"),
              const SizedBox(height: 4),
              Text(
                "Fecha: ${formatDate(expense.date)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final response = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailScreen(expense: expense),
            ),
          );

          if (response == true) {
            _refreshData();
          }
        },
      ),
    );
  }
}
