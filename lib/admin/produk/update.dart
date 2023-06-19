import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:umkm_galon/admin/produk/produk.dart';

class UpdateProduk extends StatefulWidget {
  const UpdateProduk({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _UpdateProdukState createState() => _UpdateProdukState();
}

class _UpdateProdukState extends State<UpdateProduk> {
  late Timer _timer;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();
  final image = TextEditingController();

  File? imagepath;
  String? imagename;
  String? imagedata;
  String? imageData;
  ImagePicker imagePicker = ImagePicker();
  bool isLoading = false;

  Future<void> getImage() async {
    var getimage = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imagepath = File(getimage!.path);
      imagename = getimage.path.split('/').last;
      imagedata = base64.encode(imagepath!.readAsBytesSync());
    });
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    String url =
        "https://galonumkm.000webhostapp.com/product/detail.php?id=${widget.id}";

    try {
      var response = await http.get(Uri.parse(url));
      var result = jsonDecode(response.body);
      imageData =
          "https://galonumkm.000webhostapp.com/product/" + result[0]['image'];

      setState(() {
        name.text = result[0]['name'];
        description.text = result[0]['description'];
        image.text = result[0]['image'];
        price.text = result[0]['price'];
        stock.text = result[0]['stok'];
        isLoading = false;
      });
    } catch (exc) {
      debugPrint("Error: $exc");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> insert() async {
    setState(() {
      isLoading = true;
    });
    if (imagepath == null) {
      try {
        String url = 'https://galonumkm.000webhostapp.com/product/update.php';

        var res = await http.post(Uri.parse(url), body: {
          'id': widget.id,
          'name': name.text,
          'description': description.text,
          'price': price.text,
          'stok': stock.text,
          'previmage': image.text
        });

        var response = jsonDecode(res.body);
        debugPrint(res.body);
        if (response['success'] == 'true') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            showCloseIcon: true,
            title: "Sukses Mengedit Data",
            btnOkOnPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Produk()),
              );
            },
          ).show();
        } else if (response['failed'] == 'already') {
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
                MaterialPageRoute(builder: (context) => const Produk()),
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
    } else {
      try {
        String url = 'https://galonumkm.000webhostapp.com/product/update.php';

        var res = await http.post(Uri.parse(url), body: {
          'id': widget.id,
          'name': name.text,
          'description': description.text,
          'image': imagename,
          'price': price.text,
          'stok': stock.text,
          'data': imagedata
        });

        var response = jsonDecode(res.body);
        debugPrint(res.body);
        if (response['success'] == 'true') {
          debugPrint('uploaded');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            showCloseIcon: true,
            title: "Sukses Mengedit Data",
            btnOkOnPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Produk()),
              );
            },
          ).show();
        } else if (response['failed'] == 'already') {
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
                MaterialPageRoute(builder: (context) => const Produk()),
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
                  enabled: !isLoading,
                  controller: name,
                  decoration: InputDecoration(
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
                  enabled: !isLoading,
                  controller: description,
                  decoration: InputDecoration(
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
                imageData != null && imagepath == null
                    ? Image.network(
                        imageData!,
                        width: 250,
                        height: 250,
                      )
                    : imagepath != null
                        ? Image.file(
                            imagepath!,
                            width: 250,
                            height: 250,
                          )
                        : const Text('Image not chosen yet'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : () => getImage(),
                  child: const Text('Pilih Gambar'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  controller: price,
                  decoration: InputDecoration(
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
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  controller: stock,
                  decoration: InputDecoration(
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
                  onPressed: isLoading
                      ? null
                      : () {
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
