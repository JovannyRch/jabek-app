import 'package:flutter/material.dart';
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/models/sale.dart';
import 'package:jebek_app/screens/sales/sale_detail_screen.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class SalesScreen extends StatefulWidget {
  Product? product;

  SalesScreen({Key? key, this.product}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Sale> sales = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String searchQuery = '';
  int totalSales = 0;

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
        widget.product != null
            ? "/sales/product/${widget.product?.id}"
            : "/sales",
        currentPage,
        Sale.fromJson,
        queryParameters:
            searchQuery.isNotEmpty ? {"search": searchQuery} : null,
      );

      setState(() {
        sales.addAll(response.data);
        currentPage++;
        hasMore = response.hasMore;
        totalSales = response.total;
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
        title: Text(
          searchQuery.isNotEmpty
              ? "Búsqueda: $searchQuery"
              : widget.product != null
              ? "Ventas de ${widget.product?.name}"
              : "Ventas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          searchQuery.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                    sales.clear();
                    currentPage = 1;
                    hasMore = true;
                  });
                  fetchSales();
                },
              )
              : const SizedBox(),
          widget.product == null
              ? IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _openSearchDialog();
                },
              )
              : const SizedBox(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            sales.clear();
            currentPage = 1;
            hasMore = true;
          });
          await fetchSales();
        },
        child:
            sales.isEmpty && searchQuery.isNotEmpty && !isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 50, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No se encontraron ventas con el folio: $searchQuery",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            sales.clear();
                            currentPage = 1;
                            hasMore = true;
                          });
                          fetchSales();
                        },
                        child: Text("Ver todas las ventas"),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: sales.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == sales.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final sale = sales[index];
                    return _renderSaleCard(sale);
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-sale',
        onPressed: () async {
          final check = await checkSalesLimit(totalSales, context);
          if (!check) {
            return;
          }
          final response = await Navigator.pushNamed(context, '/create-sale');
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
      searchQuery = '';
      sales.clear();
      currentPage = 1;
      hasMore = true;
    });
    fetchSales();
  }

  void _openSearchDialog() async {
    TextEditingController searchController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Buscar Venta"),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Ingrese folio de venta",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Buscar"),
              onPressed: () {
                Navigator.of(context).pop(searchController.text);
                setState(() {
                  searchQuery = searchController.text;
                  sales.clear();
                  currentPage = 1;
                  hasMore = true;
                });
                fetchSales();
              },
            ),
          ],
        );
      },
    );

    // Si se ingresó un folio, actualizamos la búsqueda y reiniciamos la lista
    if (result != null && result.isNotEmpty) {
      setState(() {
        searchQuery = result;
        sales.clear();
        currentPage = 1;
        hasMore = true;
      });
      fetchSales();
    }
  }

  Widget _renderSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.receipt, color: Colors.white),
        ),
        title: Text(
          "Folio: ${sale.folio}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Producto: ${sale.product?.name}"),
            const SizedBox(height: 4),
            Text("Cantidad: ${sale.quantity}"),
            const SizedBox(height: 4),
            Text("Total: ${formatCurrency(sale.totalPrice)}"),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("Ganancia: "),
                Text(
                  formatCurrency(sale.profit),
                  style: TextStyle(
                    color: sale.profit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Fecha: ${formatDate(sale.date)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final response = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleDetailScreen(sale: sale),
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
