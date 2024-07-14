import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:practice/global_func.dart';
import 'package:practice/pages/components/select_rack.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';

class SelectStore extends StatefulWidget {

  final pid;
  final pquantity;
  
  const SelectStore({Key? key, required this.pid , this.pquantity}) : super(key: key);
  @override
  State<SelectStore> createState() => _StorePageState();
}

class _StorePageState extends State<SelectStore> {

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    provider.fetchStores();
  });
}

  List<Map<String, dynamic>> fetchedStores = [];
  
  Widget showStores(HomeProvider provider, BuildContext context) {
  if (provider.stores.isEmpty) {
    return Center(
      child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageLoader(
              'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png',
              MediaQuery.of(context).size.width * 0.3,
            ),
            Text(
              'No stores available!',
              style: TextStyle(color: const Color.fromARGB(255, 65, 65, 65), fontSize: 20),
            ),
            Text(
              'Navigate to profile to manage stores',
              style: TextStyle(color: const Color.fromARGB(255, 65, 65, 65)),
            ),
          ],
        ),
    );
  } else {
    print(provider.stores);
    List<Widget> storeWidgets = provider.stores.map((store) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => SelectRackPage(store: store , pid: widget.pid, quantity:widget.pquantity ,),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
              },
            ),
          );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(107, 231, 230, 230),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Assuming imageLoader loads the image correctly
                imageLoader('https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png', 100),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        store['storeName'] ?? '', // Ensure 'storeName' is not null
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 58, 58, 58),
                        ),
                      ),
                      Text(
                        'Total Inventory: ${store['inventory'] ?? '0'} items', // Ensure 'inventory' is not null
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 79, 79, 79),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Last Updated: ${store['lastUpdated'] ?? 'Unknown'}', // Ensure 'lastUpdated' is not null
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: storeWidgets,
      ),
    );
  }
}

  Future<void> _refresh() async {
  final provider = Provider.of<HomeProvider>(context, listen: false);
  await provider.fetchStores();
}

  @override
  Widget build(BuildContext context) {
  final provider = Provider.of<HomeProvider>(context);

  void _showConnectStoreDialog(BuildContext context) {
    TextEditingController _storeCodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Connect Store"),
          content: TextField(
            autofocus: true,
            controller: _storeCodeController,
            decoration: InputDecoration(hintText: "Enter store code", hintStyle: TextStyle(fontWeight: FontWeight.w400)),
          ),
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Color.fromRGBO(6, 148, 132, 1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15)
              ),
              child: TextButton(
                onPressed: () {
                  if( _storeCodeController.text.isNotEmpty ) {
                    provider.requestStore(_storeCodeController.text , context);
                  }
                },
                child: Text("Connect", style: TextStyle(color: Color.fromRGBO(73, 73, 73, 1), fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        );
      },
    );
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
            cursorColor: Color.fromRGBO(6, 148, 132, 1),
            controller: _storeNameController,
            decoration: InputDecoration(hintText: "Enter store name", hintStyle: TextStyle(fontWeight: FontWeight.w400)),
          ),
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Color.fromRGBO(6, 148, 132, 1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15)
              ),
              child: TextButton(
                onPressed: () {
                  String? userEmail = provider.currentUser != null ? provider.currentUser!['email'] : null;
                  String storeName = _storeNameController.text.trim();

                  if (userEmail != null && storeName.isNotEmpty) {
                    provider.createStore(userEmail, storeName , context);
                  } else {
                    print('User email is null or store name is empty $userEmail $storeName');
                  }
                },
                child: Text("Create", style: TextStyle(color: Color.fromRGBO(68, 68, 68, 1), fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOptionDialog(BuildContext context) {
    showDialog(
      barrierColor: Color.fromARGB(113, 49, 49, 49),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Choose an option"),
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.store),
                  title: Text("Create Store"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showCreateStoreDialog(context);
                  },
                  tileColor: Color.fromRGBO(6, 148, 132, 1).withOpacity(0.1), // Background color with some opacity
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Rounded corners
                  ),
                ),
                SizedBox(height: 10, width: 100),
                ListTile(
                  leading: Icon(Icons.link),
                  title: Text("Connect Store"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showConnectStoreDialog(context);
                  },
                  tileColor: Color.fromRGBO(6, 148, 132, 1).withOpacity(0.1), // Background color with some opacity
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Rounded corners
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Image.asset(
              'lib/images/logo.png',
              height: 40,
              color: Color.fromRGBO(6, 148, 132, 1),
            ),
            SizedBox(width: 8),
            Text(
              'Inveto',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
    body: Stack(
      children: [
        RefreshIndicator(
          backgroundColor: Colors.white,
          color: Color.fromRGBO(6, 148, 132, 1),
          onRefresh: _refresh,
          child: Consumer<HomeProvider>(
            builder: (context, provider, child) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    sliver: SliverToBoxAdapter(
                      child: showStores(provider, context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.width * 0.04,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.425),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            
                          },
                        ),
                      ],
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