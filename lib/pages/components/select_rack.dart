import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:practice/global_func.dart';
import 'package:practice/pages/homepage.dart';
import 'package:practice/pages/product.dart';
import 'package:practice/pages/utils/searchbar.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';

class SelectRackPage extends StatefulWidget {
  const SelectRackPage({Key? key, required this.store , required this.pid , this.quantity }) : super(key: key);

  final Map<String, dynamic> store;
  final pid;
  final quantity;

  @override
  _SelectRackPageState createState() => _SelectRackPageState();
}

class _SelectRackPageState extends State<SelectRackPage> {
  String? selectedRack;

  void selectRack(String rack) {
    setState(() {
      selectedRack = rack;
      print(selectedRack);
    });
  }

  Widget storePreview(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.03, horizontal: MediaQuery.of(context).size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: widget.store['data'].length,
              itemBuilder: (context, index) {
                String alphabet = String.fromCharCode('A'.codeUnitAt(0) + index);
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
                            'Rack ${index + 1} (${widget.store['storeName']})',
                            style: TextStyle(fontWeight: FontWeight.w500, color: Color.fromARGB(255, 102, 102, 102)),
                          ),
                        ),
                        rackManage(alphabet, context, widget.store),
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

   Widget rackManage(String rackKey, BuildContext context, Map<String, dynamic> store) {
    List<Widget> columnButtons = [];

    // Calculate button width and height based on screen width
    final buttonWidth = MediaQuery.of(context).size.width * 0.20;
    final buttonHeight = buttonWidth * (3.1 / 3);

    for (int i = 1; i <= 6; i++) {
      List<Widget> rowWidgets = [];
      for (int j = 1; j <= 4; j++) {
        String label = rackKey + (i).toString() + (j).toString();
        bool isSelected = selectedRack == label;
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

                    if(rack['status'] == 'occupied') invalidMessenger(context, "Rack is currently occupied.");
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
                  onPressed: () {
                    selectRack(label);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(215, 219, 219, 0.719).withOpacity(0.7),
                    ),
                    elevation: MaterialStateProperty.all<double>(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        width: isSelected ? 1.5 : 0,
                        color: Color.fromARGB(163, 102, 102, 102)
                      )
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

    final provider = Provider.of<HomeProvider>(context, listen: false);

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
                            icon: Icon(Icons.confirmation_num_outlined, color: Colors.white),
                            onPressed: () {
                              print(widget.pid);
                              if(provider.stores[0]['owner'] == null) invalidMessenger(context, "At least one store is required.");
                              provider.addToRack(selectedRack.toString(), widget.pid, widget.store['storeID'] ,widget.quantity , provider.stores[0]['owner']);
                               Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => StorePage()),
                                ModalRoute.withName('/'), 
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
