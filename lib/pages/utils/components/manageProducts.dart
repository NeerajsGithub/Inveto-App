import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice/global_func.dart';
import 'package:practice/pages/product.dart';
import 'package:practice/provider/homeProvider.dart'; // Import your HomeProvider
import 'package:provider/provider.dart';

class ManageProductsPage extends StatefulWidget {
  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  File? _imageUrl; // Declare _imageUrl as nullable File

  @override
  void initState() {
    super.initState();
    Provider.of<HomeProvider>(context, listen: false).fetchProducts(context);
  }

 void _showCreateProductDialog(BuildContext context) {
  final provider = Provider.of<HomeProvider>(context, listen: false);
  TextEditingController _productIdController = TextEditingController();
  TextEditingController _productDescriptionController = TextEditingController();
  TextEditingController _productCategoryController = TextEditingController();
  File? _imageUrl;

  Future<void> _getImageFromDevice() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageUrl = File(image.path);
      });
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Add Product"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _getImageFromDevice();
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imageUrl != null ? FileImage(_imageUrl!) : null,
                      child: _imageUrl == null
                          ? Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[800])
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _productIdController,
                    decoration: InputDecoration(
                      hintText: "Enter Product ID",
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _productDescriptionController,
                    decoration: InputDecoration(
                      hintText: "Enter Product Description",
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _productCategoryController,
                    decoration: InputDecoration(
                      hintText: "Enter Product Category",
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            actions: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(6, 148, 132, 1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton(
                  autofocus: true,
                  onPressed: () async {
                    final storeId = provider.stores[0]['storeID'];
                    if (_imageUrl != null) {
                      await Provider.of<HomeProvider>(context, listen: false).submitProductDetails(
                        _productIdController.text,
                        _productDescriptionController.text,
                        _productCategoryController.text,
                        _imageUrl!,
                        storeId,
                        context,
                      );
                      Navigator.pop(context); // Close dialog after submission
                    } else {
                      print('Please select an image.');
                    }
                  },
                  child: Text(
                    "Create",
                    style: TextStyle(
                      color: Color.fromRGBO(68, 68, 68, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
 Future<void> _getImageFromDevice() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageUrl = File(pickedFile.path);
      });
    }
  }

  
  Future<void> _refresh() async {
  final provider = Provider.of<HomeProvider>(context, listen: false);
  await provider.fetchProducts(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manage Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(225, 51, 51, 51),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: provider.stores.isNotEmpty ?
       RefreshIndicator(
        backgroundColor: Colors.white,
          color: Color.fromRGBO(6, 148, 132, 1),
          onRefresh: _refresh,
        child: Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            final products = homeProvider.products;
            return Stack(
              children: [
                currentUser != null && products.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final image = product['image_url'];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      ProductPage(p_id: product['product_id']!),
                                ),
                              );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 7, horizontal: 25),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(107, 231, 230, 230),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                child: ListTile(
                                  leading: Image.network(
                                    'https://clever-shape-81254.pktriot.net/uploads/products/$image', // Assuming 'image_url' is a key in your product map
                                    width: 80, // Adjust size as needed
                                  ),
                                  title: Text(
                                    product['product_name'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis, // Replace with your product name variable
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 58, 58, 58),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Category: ${product['category']}', // Assuming 'quantity' is a key in your product map
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Color.fromARGB(255, 71, 71, 71)),
                                    onPressed: () {
                                      if(provider.stores.isNotEmpty) {
                                        final storeId = provider.stores[0]['storeID'];
                                      provider.deleteProduct(product['product_id']!, storeId , context);
                                      }
                                      provider.fetchProducts(context);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text('No products available'),
                      ),
                Positioned(
                  bottom: MediaQuery.of(context).size.width * 0.04,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.423),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(7, 103, 92, 1).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add, size: 30, color: Colors.white),
                              onPressed: () {
                                _showCreateProductDialog(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      )
      :
      Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageLoader(
                'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png',
                MediaQuery.of(context).size.width * 0.20,
              ),
              Text(
                'At least one store ',
                style: TextStyle(color: const Color.fromARGB(255, 65, 65, 65), fontSize: 20),
              ),
              Text(
                'should be available to access',
                style: TextStyle(color: const Color.fromARGB(255, 65, 65, 65)),
              ),
              SizedBox(height: 70,)
            ],
          ),
      ),
    );
  }
}
