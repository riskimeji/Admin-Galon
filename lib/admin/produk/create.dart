import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:convert/convert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:umkm_galon/admin/produk/produk.dart';

class CreateProduk extends StatefulWidget {
  const CreateProduk({Key? key}) : super(key: key);

  @override
  _CreateProdukState createState() => _CreateProdukState();
}

class _CreateProdukState extends State<CreateProduk> {
  late Timer _timer;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();

  File? imagepath;
  String? imagename;
  String? imagedata;

  ImagePicker imagePicker = ImagePicker();
  bool isLoading = false;

  Future<void> getImage() async {
    var getimage = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imagepath = File(getimage!.path);
      imagename = getimage.path.split('/').last;
      imagedata = base64.encode(imagepath!.readAsBytesSync());
      print(imagepath);
      print(imagename);
      print(imagedata);
    });
  }

  Future<void> insert() async {
    setState(() {
      isLoading = true;
    });

    try {
      String url = 'https://galonumkm.000webhostapp.com/product/insert.php';
      var res = await http.post(Uri.parse(url), body: {
        'name': name.text,
        'description': description.text,
        'image': imagename,
        'price': price.text,
        'stok': stock.text,
        'data': imagedata
      });

      var response = jsonDecode(res.body);
      debugPrint(res.body);
      if (response["success"] == "true") {
        debugPrint('uploaded');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          showCloseIcon: true,
          title: "Sukses Menambahkan Data",
          btnOkOnPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Produk()),
            );
          },
        ).show();
      } else if (response["failed"] == "already") {
        debugPrint('error');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          showCloseIcon: true,
          title: "Nama produk sudah digunakan",
          btnOkColor: Colors.red,
          btnOkOnPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateProduk()),
            );
          },
        ).show();
      }
    } catch (exc) {
      print(exc);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Produk')),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Masukkan Nama Produk',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama Produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: description,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Deskripsi Produk',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                imagepath != null
                    ? Image.file(
                        imagepath!,
                        width: 250,
                        height: 250,
                      )
                    : const Text('Image not chosen yet'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => getImage(),
                  child: const Text('Pilih Gambar'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: price,
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Jumlah Kupon per Produk',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: stock,
                  decoration: InputDecoration(
                    labelText: 'Stok',
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Total Stok Tersedia',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      insert();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('SIMPAN'),
                ),
                const SizedBox(height: 10),
                Visibility(
                  visible: isLoading,
                  child: const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
