import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'order.dart';

class Detail extends StatefulWidget {
  final OrderItem orderItem;

  const Detail({required this.orderItem, Key? key}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late String selectedStatus;
  List<String> statusOptions = [
    'PENDING',
    'PROSES',
    'DIKIRIM',
    'SELESAI',
    'BATAL'
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.orderItem.status;
  }

  Future<void> updateOrderStatus() async {
    final response = await http.post(
      Uri.parse(
          'https://galonumkm.000webhostapp.com/api/admin/order/update.php'),
      body: {
        'id': widget.orderItem.id.toString(),
        'user_id': widget.orderItem.userId.toString(),
        'tukar_kupon_id': widget.orderItem.tukar_kupon_id.toString(),
        'tukar_kupon_total': widget.orderItem.tukar_kupon_total.toString(),
        'status': selectedStatus,
      },
    );

    if (response.statusCode == 200) {
      // Success
      print('Order status updated successfully.');
      showSnackBar('Order status updated successfully.');

      // Redirect ke halaman OrderList setelah tampil SnackBar
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderList()),
        );
      });
    } else {
      // Handle error response
      print('Failed to update order status. Error: ${response.statusCode}');
      showSnackBar('Failed to update order status.');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${widget.orderItem.id}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Nama: ${widget.orderItem.username}'),
            Text('Jenis Galon: ${widget.orderItem.jenisGalon}'),
            Text('Alamat: ${widget.orderItem.alamat}'),
            Text('Jumlah: ${widget.orderItem.jumlah}'),
            Text('Tukar Kupon: ${widget.orderItem.product_name}'),
            Text('Harga: ${widget.orderItem.harga}'),
            const SizedBox(height: 16.0),
            Text(
              'Status:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                updateOrderStatus();
              },
              child: Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }
}
