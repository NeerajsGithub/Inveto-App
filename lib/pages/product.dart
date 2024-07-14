import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:practice/global_func.dart';
import 'package:practice/pages/utils/notifications.dart';
import 'package:practice/pages/utils/searchbar.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  final String p_id;
  final String? rackId;
  final dynamic store;
  final quantity; // Change the type to match your store data type

  ProductPage({Key? key, required this.p_id, this.store , this.rackId , this.quantity}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {

    String enteredQuantity;
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final productList = provider.products;
    final currentProduct = productList.firstWhere(
      (product) => product['product_id'] == widget.p_id,
    );
    final image = currentProduct['image_url'];

    Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SearchBarPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
    void getQuantity(BuildContext context) {
      TextEditingController quantityController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Dispatch"),
            content: TextField(
              autofocus: true,
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter dispatch quantity",
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
                    setState(() {
                       int? enteredQuantityValue = int.tryParse(quantityController.text);
                       int? maxQuantity = int.tryParse(widget.quantity);
                      if (enteredQuantityValue == null || enteredQuantityValue > maxQuantity!) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Entered quantity is invalid")),
                        );
                      }
                      else {
                      enteredQuantity = quantityController.text;
                      if(provider.stores[0]['owner'] == null) invalidMessenger(context, "At least one store is required.");
                      provider.deleteRack(widget.rackId! , widget.p_id, widget.store['storeID'] , enteredQuantity , provider.stores[0]['owner']);
                      provider.fetchStores();
                      Navigator.of(context).pop();
                      }
                    });  
                  },
                  child: Text(
                    "Confirm",
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.symmetric( horizontal: 12 ),
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
          actions: [
            IconButton(
              icon: Icon(Icons.search, size: 28, color: Color.fromARGB(255, 54, 54, 54)),
              onPressed: () {
                Navigator.of(context).push(_createRoute());
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, size: 28, color: Color.fromARGB(255, 54, 54, 54)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            ),
            SizedBox(width: 16,)
          ],
        ),
      body: Stack(
        children: [
           RefreshIndicator(
            backgroundColor: Colors.white,
          color: Color.fromRGBO(6, 148, 132, 1),
          onRefresh: _refresh,
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Expanded(
                child:Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 20),
                      child: Image.network(
                        'https://clever-shape-81254.pktriot.net/uploads/products/$image', // Assuming 'imageUrl' is a key in your product map
                      ),
                    ),
                ),
              ),
              SizedBox( height: 10,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.075),
                    child: Text(
                      currentProduct['category'] ?? 'Lorem Ipsum',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(12, 129, 115, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.075),
                    child: Text(
                      currentProduct['product_name'] ??
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 87, 87, 87),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.075),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(66, 198, 198, 198),
                            ),
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                            child: Column(
                              children: [
                                Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 72, 72, 72),
                                  ),
                                ),
                                Text(
                                  widget.quantity ?? "00",
                                  style: TextStyle( 
                                    fontSize: MediaQuery.of(context).size.width * 0.075,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(6, 148, 132, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(66, 198, 198, 198),
                            ),
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.056, horizontal: MediaQuery.of(context).size.width * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Code',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.055,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 72, 72, 72),
                                  ),
                                ),
                                Text(
                                  currentProduct['product_id'] ?? '00',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(6, 148, 132, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.network(
                          'https://tse1.mm.bing.net/th?id=OIP._f5N423m8QWqzD-cO9n2UwAAAA&pid=Api&rs=1&c=1&qlt=95&w=375&h=124'),
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
                           if (widget.quantity == null)
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          else
                            GestureDetector(child: Icon(Icons.delivery_dining,color: Colors.white,), onTap: () { getQuantity(context);},)
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