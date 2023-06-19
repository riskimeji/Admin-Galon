import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:umkm_galon/admin/orders/detail.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<OrderItem> orders = [];
  bool isLoading = false;

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
        'https://galonumkm.000webhostapp.com/api/admin/order/order.php'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        orders = responseData
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();
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

  void navigateToDetail(OrderItem orderItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detail(orderItem: orderItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemesanan'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : orders.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada pemesanan hari ini',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          navigateToDetail(orders[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              leading: Text(
                                'ID: ${orders[index].id}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nama: ${orders[index].username}'),
                                  Text(
                                      'Jenis Galon: ${orders[index].jenisGalon}'),
                                  Text('Alamat: ${orders[index].alamat}'),
                                  Text('Jumlah: ${orders[index].jumlah}'),
                                  Text(
                                      'Tukar Kupon: ${orders[index].product_name}'),
                                  Text('Harga: ${orders[index].harga}'),
                                ],
                              ),
                              trailing: Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: _getStatusColor(orders[index].status),
                                ),
                                child: Center(
                                  child: Text(
                                    orders[index].status,
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
                  ),
                ),
    );
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
}

class OrderItem {
  final int id;
  final String userId;
  final String tukar_kupon_id;
  final String jenisGalon;
  final String alamat;
  final String username;
  final String product_name;
  final int jumlah;
  final int tukar_kupon_total;
  final double harga;
  late final String status;

  OrderItem({
    required this.id,
    required this.tukar_kupon_id,
    required this.jenisGalon,
    required this.alamat,
    required this.username,
    required this.product_name,
    required this.jumlah,
    required this.tukar_kupon_total,
    required this.harga,
    required this.status,
    required this.userId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
        id: int.parse(json['id']),
        tukar_kupon_id: json['tukar_kupon_id'],
        jenisGalon: json['jenisGalon'],
        alamat: json['alamat'],
        jumlah: int.parse(json['jumlah']),
        tukar_kupon_total: int.parse(json['tukar_kupon_total']),
        harga: double.parse(json['harga']),
        status: json['status'],
        userId: json['user_id'],
        username: json['username'],
        product_name: json['product_name']);
  }
}
