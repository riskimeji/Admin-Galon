import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:umkm_galon/admin/produk/create.dart';
import 'package:http/http.dart' as http;
import 'package:umkm_galon/admin/produk/update.dart';

class Produk extends StatefulWidget {
  const Produk({Key? key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  List data = [];
  List filteredData = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  Future<void> deleteData(String id) async {
    var url = "https://galonumkm.000webhostapp.com/product/delete.php";
    var response = await http.post(Uri.parse(url), body: {'id': id});
    debugPrint(response.body);
    fetchUser();
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  fetchUser() async {
    setState(() {
      isLoading = true;
    });
    var url = "https://galonumkm.000webhostapp.com/product/views.php";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var items = jsonDecode(response.body);
      setState(() {
        data = items;
        filteredData = items;
        isLoading = false;
      });
    } else {
      setState(() {
        data = [];
        filteredData = [];
        isLoading = false;
      });
    }
  }

  void filterData(String query) {
    List filteredItems = [];
    filteredItems.addAll(data);
    if (query.isNotEmpty) {
      filteredItems.retainWhere((item) {
        String itemName = item['name'].toString().toLowerCase();
        return itemName.contains(query.toLowerCase());
      });
    }
    setState(() {
      filteredData = filteredItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => const CreateProduk())));
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
          title: const Text('Produk'),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ))),
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
                labelText: 'Cari produk',
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

  Widget getBody() {
    if (filteredData.contains(null) || filteredData.length < 0 || isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        return getCard(filteredData[index]);
      },
    );
  }

  Widget getCard(items) {
    var id = items['id'];
    var name = items['name'];
    var desc = items['description'];
    var imageUrl =
        "https://galonumkm.000webhostapp.com/product/" + items['image'];
    var stock = items['stok'];
    var price = items['price'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateProduk(
                  id: items['id'],
                ),
              ),
            );
          },
          child: ListTile(
            title: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(imageUrl.toString()),
                    ),
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(60 / 2),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name.toString(),
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        desc.toString(),
                        style:
                            const TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Stok: " + stock.toString(),
                        style:
                            const TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Harga : " + price.toString(),
                        style: const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 187, 84, 76)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => deleteData(id.toString()),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
