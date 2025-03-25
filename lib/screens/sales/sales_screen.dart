import 'package:flutter/material.dart';
import 'package:jebek_app/models/sale.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class SalesScreen extends StatefulWidget {
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Sale> sales = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchSales();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        fetchSales();
      }
    });
  }

  Future<void> fetchSales() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.fetchPaginated<Sale>(
        "/sales",
        currentPage,
        Sale.fromJson,
      );

      setState(() {
        sales.addAll(response.data);
        currentPage++;
        hasMore = response.hasMore;
      });
    } catch (e) {
      print("Error al cargar ventas: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: sales.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sales.length) {
            return Center(child: CircularProgressIndicator());
          }

          final sale = sales[index];
          return ListTile(
            title: Text("Folio: ${sale.folio}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Producto: ${sale.product.name}"),
                Text("Cantidad: ${sale.quantity}"),
                Text("Total: ${formatCurrency(sale.totalPrice)}"),
                Text("Ganancia: \$${sale.profit}"),
                Text("Fecha: ${sale.date}"),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-sale',
        onPressed: () async {
          final response = await Navigator.pushNamed(context, '/create-sale');
          if (response == true) {
            setState(() {
              sales.clear();
              currentPage = 1;
              hasMore = true;
            });
            fetchSales();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
