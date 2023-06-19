import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:umkm_galon/admin/orders/detail.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({Key? key}) : super(key: key);

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<OrderItem> orders = [];
  List<OrderItem> filteredOrders = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://galonumkm.000webhostapp.com/api/admin/order/history_order.php'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        orders = responseData
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();
        filteredOrders = orders;
        isLoading = false;
      });
    } else {
      // Handle error response
      print('Failed to fetch orders. Error: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData(String query) {
    setState(() {
      filteredOrders = orders
          .where((order) =>
              order.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget getBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (filteredOrders.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada pemesanan hari ini',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: Text(
                    'ID: ${filteredOrders[index].id}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${filteredOrders[index].username}'),
                      Text('Jenis Galon: ${filteredOrders[index].jenisGalon}'),
                      Text('Alamat: ${filteredOrders[index].alamat}'),
                      Text('Jumlah: ${filteredOrders[index].jumlah}'),
                      Text('Harga: ${filteredOrders[index].harga}'),
                    ],
                  ),
                  trailing: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: _getStatusColor(filteredOrders[index].status),
                    ),
                    child: Center(
                      child: Text(
                        filteredOrders[index].status,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Color.fromARGB(255, 202, 187, 50);
      case 'PROSES':
        return Colors.blue;
      case 'DIKIRIM':
        return Colors.orange;
      case 'SELESAI':
        return Colors.green;
      case 'BATAL':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemesanan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterData(value);
              },
              decoration: InputDecoration(
                labelText: 'Cari Pesanan',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(child: getBody()),
        ],
      ),
    );
  }
}

class OrderItem {
  final int id;
  final String userId;
  final String jenisGalon;
  final String alamat;
  final String username;
  final int jumlah;
  final double harga;
  late final String status;

  OrderItem({
    required this.id,
    required this.jenisGalon,
    required this.alamat,
    required this.username,
    required this.jumlah,
    required this.harga,
    required this.status,
    required this.userId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
        id: int.parse(json['id']),
        jenisGalon: json['jenisGalon'],
        alamat: json['alamat'],
        jumlah: int.parse(json['jumlah']),
        harga: double.parse(json['harga']),
        status: json['status'],
        userId: json['user_id'],
        username: json['username']);
  }
}
