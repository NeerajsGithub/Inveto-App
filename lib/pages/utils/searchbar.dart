// searchBarPage.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:practice/pages/product.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';

class SearchBarPage extends StatefulWidget {
  @override
  _SearchBarPageState createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    Provider.of<HomeProvider>(context, listen: false).filterProducts(query);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text(
          'Search',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Color.fromARGB(164, 238, 238, 238),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                Expanded(
                  child: Consumer<HomeProvider>(
                    builder: (context, homeProvider, _) {
                      final data = homeProvider.filteredProducts;
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final product = data[index];
                          final image = product['productPath'];
                          return Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(31, 164, 164, 164),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      image ?? 'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png',
                                      width: 40,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        product['storeName'] ?? 'N/A',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 26,
                                            color: const Color.fromARGB(
                                                255, 65, 65, 65)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Quantity: ${product['totalQuantity'] ?? 'N/A'} ',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 85, 85, 85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${product['productDescription'] ?? 'N/A'}',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 89, 89, 89)),
                                ),
                                SizedBox(height: 6),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    if (product.containsKey('racks') &&
                                        product['racks'] is List)
                                      ...product['racks'].map<Widget>(
                                          (rack) => GestureDetector(
                                                onTap: () {
                                                  Navigator.push<void>(
                                                    context,
                                                    MaterialPageRoute<void>(
                                                      builder: (BuildContext
                                                              context) =>
                                                          ProductPage(
                                                        p_id: rack['product_id'],
                                                        quantity: rack["quantity"],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Chip(
                                                  key: UniqueKey(),
                                                  backgroundColor:
                                                      Colors.white,
                                                  label: Text(
                                                    rack['rack'] ?? '',
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 96, 95, 95)),
                                                  ),
                                                  side: BorderSide(
                                                      color: Colors.black12),
                                                ),
                                              )),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.width * 0.04,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.423),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(7, 103, 92, 1).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.1),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.keyboard_arrow_left,
                            size: 30, color: Colors.white),
                        onPressed: () {
                          print(Provider.of<HomeProvider>(context, listen: false).filteredProducts);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
