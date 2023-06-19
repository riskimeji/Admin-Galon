import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Coupon extends StatefulWidget {
  const Coupon({Key? key});

  @override
  State<Coupon> createState() => _CouponState();
}

class _CouponState extends State<Coupon> {
  List<CouponItem> coupons = [];
  List<CouponItem> filteredCoupons = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://galonumkm.000webhostapp.com/api/admin/coupon/view.php'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        coupons = responseData
            .map((item) => CouponItem.fromJson(item as Map<String, dynamic>))
            .toList();
        filteredCoupons = coupons;
        isLoading = false;
      });
    } else {
      // Handle error response
      print('Failed to fetch coupons. Error: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCoupons(String keyword) {
    setState(() {
      if (keyword.isNotEmpty) {
        filteredCoupons = coupons
            .where((coupon) =>
                coupon.username.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      } else {
        filteredCoupons = coupons;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kupon'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => filterCoupons(value),
                    decoration: InputDecoration(
                      labelText: 'Cari Kupon',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredCoupons.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada kupon',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCoupons.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(30.0),
                                      child: Image.network(
                                        'https://galonumkm.000webhostapp.com/product/${filteredCoupons[index].image}',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(filteredCoupons[index].username),
                                        const Spacer(),
                                        Text(filteredCoupons[index].date),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                            'Total: ${filteredCoupons[index].total}'),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: _getStatusColor(
                                                filteredCoupons[index].status),
                                          ),
                                          child: Text(
                                            filteredCoupons[index].status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color.fromARGB(255, 202, 187, 50);
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

class CouponItem {
  final int id;
  final String name;
  final String image;
  final int total;
  final String date;
  final String status;
  final String username;

  CouponItem({
    required this.id,
    required this.name,
    required this.image,
    required this.total,
    required this.date,
    required this.status,
    required this.username,
  });

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    return CouponItem(
      id: int.parse(json['id']),
      name: json['name'],
      image: json['image'],
      total: int.parse(json['total']),
      date: json['date'],
      status: json['status'],
      username: json['username'],
    );
  }
}
