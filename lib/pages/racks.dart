import 'dart:ui';
import 'package:practice/pages/product.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:practice/pages/other/qr_scanner.dart';
import 'package:practice/pages/product.dart';
import 'package:practice/pages/utils/notifications.dart';
import 'package:practice/pages/utils/profile.dart';
import 'package:practice/pages/utils/searchbar.dart';

class StorePreviewPage extends StatelessWidget {
  const StorePreviewPage({Key? key, required this.store}) : super(key: key);

  final Map<String, dynamic> store;

  Widget storePreview(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.03, horizontal: MediaQuery.of(context).size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: store['data'].keys.length, // Use keys.length instead of data.length
              itemBuilder: (context, index) {
                String rackKey = store['data'].keys.toList()[index];
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => {},
                          icon: Icon(Icons.filter_list, color: Color.fromARGB(255, 78, 78, 78)),
                          label: Text(
                            'Rack ${rackKey.toUpperCase()} (${store['storeName']})', // Display rack key
                            style: TextStyle(fontWeight: FontWeight.w500, color: Color.fromARGB(255, 102, 102, 102)),
                          ),
                        ),
                        rackManage(rackKey, context, store),
                      ],
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

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Perform some action
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget rackManage(String rackKey, BuildContext context, Map<String, dynamic> store) {
    List<Widget> columnButtons = [];

    // Calculate button width and height based on screen width
    final buttonWidth = MediaQuery.of(context).size.width * 0.20;
    final buttonHeight = buttonWidth * (3.1 / 3);

    for (int i = 1; i <= 6; i++) {
      List<Widget> rowWidgets = [];
      for (int j = 1; j <= 4; j++) {
        String label = rackKey + (i).toString() + (j).toString();
        if (store['data'][rackKey] != null &&
            store['data'][rackKey].where((rack) => rack['rack'] == label && rack['status'] == 'occupied').isNotEmpty) {
          rowWidgets.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
              child: SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () {
                    var rack = store['data'][rackKey]?.firstWhere(
                      (rack) => rack['rack'] == label && rack['status'] == 'occupied',
                    );
                    print(rack);

                    String productId = rack['product_id'];
                    
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ProductPage( p_id: productId ,  store: store , rackId : label , quantity : rack['quantity']),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(6, 119, 106, 1).withOpacity(0.7),
                    ),
                    elevation: MaterialStateProperty.all<double>(0),

                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(color: Color.fromARGB(255, 237, 237, 237), fontSize: MediaQuery.of(context).size.width * 0.032),
                  ),
                ),
              ),
            ),
          );
        } else {
          rowWidgets.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
              child: SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(215, 219, 219, 0.719).withOpacity(0.7),
                    ),
                    elevation: MaterialStateProperty.all<double>(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(color: Color.fromARGB(255, 130, 130, 130), fontSize: MediaQuery.of(context).size.width * 0.032),
                  ),
                ),
              ),
            ),
          );
        }
      }
      columnButtons.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowWidgets,
          ),
        ),
      );
    }

    return Column(
      children: columnButtons,
    );
  }

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

  @override
  Widget build(BuildContext context) {
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
          Column(
            children: [
              Expanded(
                child: storePreview(context),
              ),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.width * 0.04,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.33),
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
                            icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                            onPressed: () async {
                              try {
                                final status = await Permission.camera.request();
                                if (status.isGranted) {
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(builder: (context) => QRViewExample()),
                                  );
                                } else {
                                  print('Camera permission denied.');
                                }
                              } catch (e) {
                                print('Error requesting camera permission: $e');
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.person_outlined, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (context) => ProfilePage()),
                               );
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