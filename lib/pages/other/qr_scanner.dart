import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:practice/pages/components/scanned_product.dart';
import 'package:practice/pages/homepage.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
         ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 220.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Color.fromRGBO(6, 127, 113, 1),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

void _onQRViewCreated(QRViewController controller) async {
  setState(() {
    this.controller = controller;
  });

  bool isNavigated = false;

  controller.scannedDataStream.listen((scanData) {
    if (!isNavigated) {
      setState(() {
        result = scanData;
        print(result?.code);
        isNavigated = true; // Set the flag to true to prevent further navigation
        controller.pauseCamera();
        final provider = Provider.of<HomeProvider>(context, listen: false);

        final matchingProduct = provider.products.firstWhere(
        (product) =>  product['product_id'] == result?.code,
          orElse: () => {},
        );

        if(matchingProduct.isNotEmpty) {
          Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ScannedProduct(p_id: (result!.code).toString()),
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
        }
        else {
           Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => StorePage(),
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
           ModalRoute.withName('/'), 
          );
          Future.delayed(Duration(microseconds: 1000));

           ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid unregistered QR!',
              style: TextStyle(color: Colors.white), // Change text color
            ),
            backgroundColor: Color.fromRGBO(7, 103, 92, 1).withOpacity(0.7),
            duration: Duration(seconds: 1),
          ),
        );  
        }
      });
    }
  });
}

void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
  log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
  if (!p) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('no Permission')),
    );
  }
}


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}