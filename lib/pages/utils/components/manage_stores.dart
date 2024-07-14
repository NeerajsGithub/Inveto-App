import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:practice/global_func.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';

class ManageStoresPage extends StatefulWidget {
  @override
  State<ManageStoresPage> createState() => _ManageStoresPageState();
}

class _ManageStoresPageState extends State<ManageStoresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchStores();
    });
  }

  void _showCreateStoreDialog(BuildContext context) {
    TextEditingController _storeNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Create Store"),
          content: TextField(
            autofocus: true,
            controller: _storeNameController,
            decoration: InputDecoration(
              hintText: "Enter store name",
              hintStyle: TextStyle(fontWeight: FontWeight.w400),
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
                onPressed: () {
                  String? userEmail = Provider.of<HomeProvider>(context, listen: false).currentUser != null ? Provider.of<HomeProvider>(context, listen: false).currentUser!['email'] : null;
                  String storeName = _storeNameController.text.trim();

                  if (userEmail != null && storeName.isNotEmpty) {
                    Provider.of<HomeProvider>(context, listen: false).createStore(userEmail, storeName , context);
                    _refresh();
                  } else {
                    print('User email is null or store name is empty $userEmail $storeName');
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Create",
                  style: TextStyle(color: Color.fromRGBO(68, 68, 68, 1), fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refresh() async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    await provider.fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context,listen: false);
    final List<Map<String, dynamic>> stores = provider.stores;
    final currentUser = provider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manage Stores',
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
      body: Stack(
        children: [
          currentUser != null && stores.isNotEmpty
              ? RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: Color.fromRGBO(6, 148, 132, 1),
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      final storeName = store['storeName'];
                      final storeImageUrl = 'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png';
                      final storeInventory = store['inventory']?.toString() ?? '0';

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 7, horizontal: 25),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(107, 231, 230, 230),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: ListTile(
                          leading: imageLoader(
                            storeImageUrl,
                            60,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storeName,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.06,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 58, 58, 58),
                                ),
                              ),
                              Text(
                                'Inventory: $storeInventory',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 87, 87, 87),
                                ),
                              ),
                            ],
                          ),
                          trailing: (provider.currentUser != null && provider.stores.isNotEmpty && provider.currentUser!['id'] == provider.stores[0]['owner'])
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: const Color.fromARGB(255, 87, 87, 87)),
                                  onPressed: () async {
                                    print(store['storeID']);
                                    provider.deleteStore(store['storeID']);
                                    provider.fetchStores();
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                )
              :  Center(
                    child: Text('No stores available'),
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
                                _showCreateStoreDialog(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
