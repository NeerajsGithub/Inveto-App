import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:practice/global_func.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeProvider extends ChangeNotifier {
  bool _isAuth = false;
  bool get isAuth => _isAuth;

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  List<Map<String, dynamic>> _members = [];
   List<Map<String, dynamic>> get members => _members;

  List<dynamic> _requests = [];
  List<dynamic> get requests => _requests;

  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> get filteredProducts => _filteredProducts;

  List<Map<String, dynamic>> _finalResult = [];
  List<Map<String, dynamic>> get finalResult => _finalResult;

  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> get stores => _stores;

  List<Map<String, String>> _products = [];

    void setStoresToNull() {
    _stores = [];
    notifyListeners();
  }

  void setMembersToNull() {
    _members = [];
    notifyListeners();
  }

  void setRequestsToNull() {
    _requests = [];
    notifyListeners();
  }

  void setProductsToNull() {
    _products = [];
    notifyListeners();
  }

  void setCurrentUserToNull() {
    _currentUser = null;
    notifyListeners();
  }

  // List<Map<String, String>> _products = [
  //   {
  //     "product_id": "P011",
  //     "product_name": "GIGABYTE NVIDIA GeForce RTX 3060 WINDFORCE OC 12GB GDDR6 pci_e_x16 Graphics Card (GV-N3060WF2OC-12GD)",
  //     "quantity": "15",
  //     "image_url": "https://m.media-amazon.com/images/I/71OFKtclW4L._SL1500_.jpg",
  //     "category": "Computer Hardware"
  //   },
  //   {
  //     "product_id": "P012",
  //     "product_name": "ViewSonic Gaming (Originated in USA) 24 Inch Full Hd,IPS,1Ms,165Hz Refresh Rate Monitor, HDR10, Free Sync, sRGB 104%, Eye Care",
  //     "quantity": "20",
  //     "image_url": "https://m.media-amazon.com/images/I/61Njp6OstkL._SL1200_.jpg",
  //     "category": "Computer Hardware"
  //   },
  //   {
  //     "product_id": "P013",
  //     "product_name": "Portronics Power Plate 7 with 6 USB Port + 8 Power Sockets Smart Electric Universal Extension Board Multi Plug with 2500W",
  //     "quantity": "10",
  //     "image_url": "https://m.media-amazon.com/images/I/518grrfPw8L._SL1200_.jpg",
  //     "category": "Electronics"
  //   },
  //   {
  //     "product_id": "P014",
  //     "product_name": "Bosch Professional GSB 500 RE Corded-Electric Drill Tool Set, 10 mm (Blue), 500 Watt, (100 Pc Accessory Set)",
  //     "quantity": "5",
  //     "image_url": "https://m.media-amazon.com/images/I/81fP7IRuKKL._SL1500_.jpg",
  //     "category": "Tools"
  //   },
  //   {
  //     "product_id": "P015",
  //     "product_name": "CP PLUS 2MP Full HD Smart Wi-Fi CCTV Home Security Camera | 360° with Pan Tilt | View & Talk | Motion Alert | Night Vision",
  //     "quantity": "12",
  //     "image_url": "https://m.media-amazon.com/images/I/31Nk80-hUUL.jpg",
  //     "category": "Security Cameras"
  //   },
  //   {
  //     "product_id": "P016",
  //     "product_name": "IBELL Impact Drill ID13-75, 650W, Copper Armature, Chuck 13mm, 2800 RPM, 2 mode selector",
  //     "quantity": "10",
  //     "image_url": "https://m.media-amazon.com/images/I/714rkFrqqXL._SL1500_.jpg",
  //     "category": "Tools"
  //   },
  // ];

  List<Map<String, String>> get products => _products;

  HomeProvider() {
    _loadAuthState();
    _loadCurrentUser();
  }

Future<void> downloadAndOpenExcelFile(BuildContext context, String ownerID , String email ) async {
  final url = Uri.parse('https://clever-shape-81254.pktriot.net/stores/get-file'); // Replace with your server URL
  try {
    // Check and request the permission
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Make the POST request with the email in the body
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Specify JSON content type
        },
        body: jsonEncode({
          'email' : email,
          'owner' : ownerID,
        }),
      );
  
      // Check the response status code
      if (response.statusCode == 200) {
        // Get the directory to save the file
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/${currentUser?["email"]}.xlsx';
        print("Saving file to: $filePath");

        // Check if the file exists and delete it if it does
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          print("Existing file deleted");
        }

        // Write the new file
        await file.writeAsBytes(response.bodyBytes);
        print("File written successfully");

        // Check if the file exists after writing
        if (await file.exists()) {
          print("File exists, opening...");

          // Open the file using open_file package
          final result = await OpenFile.open(filePath);
          print("OpenFile result: ${result.message}");
        } else {
          print("File was not created successfully");
        }
      } else {
        print('Failed to download file: ${response.statusCode} ${response.reasonPhrase}');
      }
    } else {
      print('Permission denied');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  Future<void> addToRack(String rackId, String productId, String storeId , String quantity , String owner) async {
    print('$rackId $productId $storeId $quantity');
    final body = {
      'email': _currentUser!['email'],
      'rackId': rackId,
      'productId': productId,
      'storeId': storeId,
      'quantity' : quantity,
      'owner' : owner.toString(),
    };

    try {
      final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/add-to-rack');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Product added to rack successfully');
        await fetchStores();
      } else {
        final responseBody = json.decode(response.body);
        print('Failed to add product to rack: ${responseBody['message']}');
      }
    } catch (error) {
      // Handle any other errors
      print('Error adding product to rack: $error');
    }
  }

  Future<void> deleteRack(String rackId, String productId, String storeId , String quantity , String owner) async {
    print('$rackId $productId $storeId');
    final body = {
      'email': _currentUser!['email'],
      'rackId': rackId,
      'productId': productId,
      'storeId': storeId,
      'quantity' : quantity,
      'owner' : owner.toString(),
    };

    try {
      final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/delete-rack');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Product deleted uun rack successfully');
        await fetchStores();
      } else {
        final responseBody = json.decode(response.body);
        print('Failed to deleterack: ${responseBody['message']}');
      }
    } catch (error) {
      // Handle any other errors
      print('Error deleting rack: $error');
    }
  }

 Future<void> fetchMembers(String email) async {
  try {
    final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/fetch-members');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<String> memberIds = List<String>.from(data['members']);

      List<Map<String, dynamic>> fetchedMembers = [];
      for (String id in memberIds) {
        final memberDetails = await fetchUserDetails(id: id);
        if (memberDetails != null) {
          fetchedMembers.add(memberDetails);
        }
      }

      _members = fetchedMembers;
      notifyListeners();
    } else {
      print('Failed to load members: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching members: $e');
  }
}

  Future<void> fetchRequests() async {
    try {
      final currentUserEmail = _currentUser!['email'];
      final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/requests');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': currentUserEmail}),
      );

      if (response.statusCode == 200) {
            final List<dynamic> responseData = jsonDecode(response.body);
          _requests = responseData;
          notifyListeners(); // Notify listeners after updating members
          } else {
        print('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails({String? id}) async {

  final String email = currentUser!= null ? currentUser!['email'] : '';
  try {
    String queryParameter;
    if (id != null) {
      queryParameter = 'id=$id';
    } else if (email.isNotEmpty) {
      queryParameter = 'email=$email';
    } else {
      print('Error: Both email and id are null.');
      return null;
    }

    final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/userDetails?$queryParameter');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (id != null) {
        return {
          'id': data['id'],
          'name': data['name'],
          'email': data['email'],
          'image': data['image'],
          'gender': data['gender']
        };
      } else {
        final currentUserDetails = {
          'id': data['id'],
          'name': data['name'],
          'gender': data['gender'],
          'email': email,
          'image': data['image']
        };

        // Save updated user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode(currentUserDetails));

        setCurrentUser(currentUserDetails);
      }
    } else {
      print('Failed to fetch user details. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user details: $e');
  }

  return null; // Return null if fetching by email and updating current user
}

  Future<void> deleteStore(  storeID) async {
    if (_currentUser != null) {
      final currentUserEmail = _currentUser!['email'];
      try {
        final response = await http.post(
        Uri.parse('https://clever-shape-81254.pktriot.net/stores/delete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },  
        body: jsonEncode(<String, dynamic>{
          'email' : currentUserEmail,
          'storeID' : storeID,
        }),
      );

        if (response.statusCode == 200) {
          print('Store deleted');
        } else {
          print('Failed to delete store ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching user details: $e');
      }
    } else {
      print('Current user is null. Cannot fetch details.');
    }
  }

Future<void> deleteProduct(String productID, String storeId , BuildContext context) async {
  if (_currentUser != null && _stores.isNotEmpty) {
    final currentUserEmail = _currentUser!['email'];
      try {
        final response = await http.post(
          Uri.parse('https://clever-shape-81254.pktriot.net/users/delete-product'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'email': currentUserEmail,
            'pid': productID,
            'storeId': storeId,
          }),
        );

        if (response.statusCode == 200) {
          print('Product deleted');
        } else {
          print('Failed to delete product ${response.statusCode}');
        }
      } catch (e) {
        print('Error deleting product: $e');
      }
    }
}


  Future<void> requestStore(  storeID , BuildContext context ) async {
    if (_currentUser != null) {
      final currentUserEmail = _currentUser!['email'];
      try {
        final response = await http.post(
        Uri.parse('https://clever-shape-81254.pktriot.net/users/request-stores'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },  
        body: jsonEncode(<String, dynamic>{
          'email' : currentUserEmail,
          'storeID' : storeID,
        }),
      );

        if(response.statusCode == 201) {
          invalidMessenger(context, 'Request already registered');
        }
        else if (response.statusCode == 200) {
          print('Request Added');
        } else {
          print('Failed to req  ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching user details: $e');
      }
    } else {
      print('Current user is null. Cannot fetch details.');
    }
  }

  Future<void> addMember(String memberEmail , BuildContext context) async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentUser = provider.currentUser;
    if (currentUser != null) {
      final currentUserEmail = _currentUser!['email'];
      try {
        final response = await http.post(
          Uri.parse('https://clever-shape-81254.pktriot.net/users/add-member'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'email': currentUserEmail,
            'memberEmail': memberEmail,
          }),
        );

        if (response.statusCode == 200) {
          validMessenger(context, "Memeber added successfully");
          print('Member Added');
          await fetchRequests();
        } else {
          print('Failed to add member ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding member: $e');
      }
    } else {
      print('Current user is null. Cannot add member.');
    }
  }

  Future<void> deleteRequest(String memberEmail , BuildContext context) async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentUser = provider.currentUser;
    if (currentUser != null) {
      final currentUserEmail = currentUser['email'];
      try {
      print(currentUserEmail);
      print(memberEmail);
        final response = await http.post(
          Uri.parse('https://clever-shape-81254.pktriot.net/users/delete-request'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'email': currentUserEmail,
            'memberEmail': memberEmail,
          }),
        );

          await fetchRequests();
        if (response.statusCode == 200) {
          print('Member Deleted');
          validMessenger(context, "Request rejected");
        } else {
          print('Failed to add member ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding member: $e');
      }
    } else {
      print('Current user is null. Cannot add member.');
    }
  }

  Future<void> deleteMember(String memberEmail , BuildContext context) async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    if (currentUser != null) {
      final currentUserEmail = currentUser['email'];
      try {
        final response = await http.post(
          Uri.parse('https://clever-shape-81254.pktriot.net/users/remove-member'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'email': currentUserEmail,
            'memberEmail': memberEmail,
          }),
        );

        if (response.statusCode == 200) {
          print('Member Deleted');
          await fetchMembers(currentUserEmail);
        } else {
          print('Failed to add member ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding member: $e');
      }
    } else {
      print('Current user is null. Cannot add member.');
    }
  }

  Future<void> submitProductDetails(String pname, String pdescription, String pcategory, File pimage, String storeId, BuildContext context) async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    if (currentUser == null) {
      invalidMessenger(context, "Login to access these functioanlities");
      return;
    }

    final String email = currentUser['email'] ?? '';

    // Prepare multipart request
    var request = http.MultipartRequest('POST', Uri.parse('https://clever-shape-81254.pktriot.net/users/products'));
    request.headers['Content-Type'] = 'application/json; charset=UTF-8';

    // Add fields to the request
    request.fields['id'] = pname;
    request.fields['description'] = pdescription;
    request.fields['category'] = pcategory;
    request.fields['email'] = email;
    request.fields['storeId'] = storeId;

    request.files.add(await http.MultipartFile.fromPath('image', pimage.path));

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        validMessenger(context, 'Product added successfully!');
        await provider.fetchProducts(context);
      } else {
        invalidMessenger(context, 'Failed to add product!');
      }
    } catch (error) {
      print('Error uploading product: $error');
      invalidMessenger(context, e.toString());
    }
  }

  Future<void> fetchProducts(BuildContext context) async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    // Ensure currentUser is not null before accessing its properties
    if (currentUser == null) {
      invalidMessenger(context, 'User is not logged in!');
      return;
    }

    final String email = currentUser['email'] ?? '';

    final response = await http.get(
      Uri.parse('https://clever-shape-81254.pktriot.net/users/products?email=$email'),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);

      if (decodedBody is List) {
        _products.clear();

        for (var item in decodedBody) {
          if (item is Map<String, dynamic>) {
            final Map<String, String> product = {
              'product_id': item['pid'].toString(),
              'product_name': item['product_description'].toString(),
              'quantity': item['quantity'].toString(),
              'image_url': item['image_url'].toString(),
              'category': item['category'].toString(),
            };
            _products.add(product);
          }
        }

        notifyListeners();
    } else {
        print('Response body is not a List: $decodedBody');
        invalidMessenger(context,'Failed to fetch products!');
      }
    } else {
      print('Failed to fetch products. Status code: ${response.statusCode}');
    }
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuth = prefs.getBool('isAuth') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    _isAuth = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuth', true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuth = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuth', false);
    await prefs.remove('currentUser'); // Clear currentUser on logout
    _currentUser = null; // Clear local currentUser
    notifyListeners();
  }

  void setCurrentUser(Map<String, dynamic> user) async {
    _currentUser = user;
    notifyListeners();

    // Save user data to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user));
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('currentUser');
    if (userData != null) {
      _currentUser = jsonDecode(userData);
      notifyListeners();
    }
  }

  void printSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserData = prefs.getString('currentUser');
    if (savedUserData != null) {
      print('Saved User Data: $savedUserData');
    } else {
      print('No user data found in SharedPreferences.');
    }
  }

void filterProducts(String query) {
  if (query.isEmpty) {
    _filteredProducts = [];
  } else {
    _filteredProducts = _products.where((product) {
      final String name = product["product_name"]?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    List<Map<String, dynamic>> finalResult = [];

    for (var product in _filteredProducts) {
      int totalQuantity = 0;
      for (var store in _stores) {
        var storeData = store["data"];
        List<dynamic> racks = [];
          for (var row in storeData.values) {
            for( var rowValues in row ) {
              if( int.parse(rowValues["product_id"]) == int.parse(product["product_id"])) {
                print("found");
                int quantity = int.tryParse(rowValues["quantity"] ?? "0") ?? 0; // Parse quantity as integer
                 totalQuantity += quantity;
                 print(quantity); // Add to total quantity
                racks.add({
                "rack": rowValues["rack"],
                "status": rowValues["status"],
                "quantity": rowValues["quantity"],
                "product_id" : rowValues["product_id"],
              });
              } 
            }
          }

        if (racks.isNotEmpty) {
          String imgPath = product["image_url"];
          finalResult.add({
            "storeName": store["storeName"],
            "productDescription": product["product_name"],
            "productPath": "https://clever-shape-81254.pktriot.net/uploads/products/$imgPath",
            "racks": racks,
            "totalQuantity": totalQuantity,
          });
        }
      }
    }

    _filteredProducts = finalResult;
  }

  notifyListeners();
}


  Future<void> createStore(String email, String storeName, BuildContext context) async {
     try {
      final response = await http.post(
        Uri.parse('https://clever-shape-81254.pktriot.net/stores/create-store'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'storeName': storeName,
        }),
      );

      if (response.statusCode == 200) {
        validMessenger(context, "Stpre registered successfully");
        await fetchStores();
        Navigator.of(context).pop();
      } else {
        invalidMessenger(context, "An error occured , try again later");
      }
    } catch (e) {
      print('Error creating store: $e');
    }
  }

  Future<void> fetchStores() async {
    try {
      final url = Uri.parse('https://clever-shape-81254.pktriot.net/stores/get-stores');
      String userEmail = currentUser!['email'] ?? '';
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        _stores = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        notifyListeners();
      } else {
        print('Failed to load stores: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stores: $e');
    }
  }

  Future<void> updateUserDetails(BuildContext context, String name, String gender, File? imageFile) async {
  try {
    final url = Uri.parse('https://clever-shape-81254.pktriot.net/users/update');
    var request = http.MultipartRequest('POST', url);

    var provider = Provider.of<HomeProvider>(context, listen: false);
    var currentUser = provider.currentUser;

    if (currentUser == null) {
      print('Current user is null');
      return;
    }

    String userEmail = currentUser['email'] ?? '';

    if (userEmail.isEmpty) {
      print('User email is empty');
      return;
    }

    request.fields['email'] = userEmail;
    request.fields['name'] = name;
    request.fields['gender'] = gender;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final response = await request.send();
    print("sent");

    if (response.statusCode == 200) {
      Navigator.pop(context);     // Optionally, you can fetch the updated user details here to refresh the local state
      print('User details updated successfully');
      await provider.fetchUserDetails();
    } else {
      print('Failed to update user details: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating user details: $e');
  }
}
}



  //   {  
  //     'id' : '1',
  //     'name': 'Store A',
  //     'size': 'Large',
  //     'imageUrl': 'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png',
  //     'inventory': 150,
  //     'lastUpdated': 'June 6, 2024',
  //     'data': {
  //      "A": [
  //     {"rack": "A11", "status": "available", "product_id": ""},
  //     {"rack": "A12", "status": "occupied", "product_id": "P012"},
  //     {"rack": "A13", "status": "available", "product_id": ""},
  //     {"rack": "A14", "status": "overflowed", "product_id": "P014"},
  //     {"rack": "A15", "status": "available", "product_id": ""},
  //     {"rack": "A16", "status": "overflowed", "product_id": "P016"},
  //     {"rack": "A17", "status": "available", "product_id": ""},
  //     {"rack": "A18", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A19", "status": "occupied", "product_id": "P012"},
  //     {"rack": "A20", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A21", "status": "occupied", "product_id": "P012"},
  //     {"rack": "A22", "status": "occupied", "product_id": "P015"},
  //     {"rack": "A23", "status": "available", "product_id": ""},
  //     {"rack": "A24", "status": "overflowed", "product_id": "P011"},
  //     {"rack": "A25", "status": "available", "product_id": ""},
  //     {"rack": "A26", "status": "overflowed", "product_id": "P012"},
  //     {"rack": "A27", "status": "available", "product_id": ""},
  //     {"rack": "A28", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A29", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A30", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A31", "status": "available", "product_id": ""},
  //     {"rack": "A32", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A33", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A34", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A35", "status": "available", "product_id": ""},
  //     {"rack": "A36", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A37", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A38", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A39", "status": "available", "product_id": ""},
  //     {"rack": "A40", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A41", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A42", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A43", "status": "available", "product_id": ""},
  //     {"rack": "A44", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A45", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A46", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A47", "status": "available", "product_id": ""},
  //     {"rack": "A48", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A49", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A50", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A51", "status": "available", "product_id": ""},
  //     {"rack": "A52", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A53", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A54", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A55", "status": "available", "product_id": ""},
  //     {"rack": "A56", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A57", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A58", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A59", "status": "available", "product_id": ""},
  //     {"rack": "A60", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A61", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A62", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A63", "status": "available", "product_id": ""},
  //     {"rack": "A64", "status": "occupied", "product_id": "P014"}
  //   ],
  //     "B": [
  //     {"rack": "B11", "status": "available", "product_id": ""},
  //     {"rack": "B12", "status": "occupied", "product_id": "P012"},
  //     {"rack": "B13", "status": "available", "product_id": ""},
  //     {"rack": "B14", "status": "occupied", "product_id": "P014"},
  //     {"rack": "B15", "status": "available", "product_id": ""},
  //     {"rack": "B16", "status": "overflowed", "product_id": "P016"},
  //     {"rack": "B17", "status": "available", "product_id": ""},
  //     {"rack": "B18", "status": "occupied", "product_id": "P012"},
  //     {"rack": "B19", "status": "occupied", "product_id": "P029"},
  //     {"rack": "B20", "status": "occupied", "product_id": "P030"},
  //     {"rack": "B21", "status": "occupied", "product_id": "P031"},
  //     {"rack": "B22", "status": "occupied", "product_id": "P032"},
  //     {"rack": "B23", "status": "available", "product_id": ""},
  //     {"rack": "B24", "status": "overflowed", "product_id": "P034"},
  //     {"rack": "B25", "status": "available", "product_id": ""},
  //     {"rack": "B26", "status": "overflowed", "product_id": "P036"},
  //     {"rack": "B27", "status": "available", "product_id": ""},
  //     {"rack": "B28", "status": "occupied", "product_id": "P038"},
  //     {"rack": "B29", "status": "occupied", "product_id": "P039"},
  //     {"rack": "B30", "status": "occupied", "product_id": "P040"},
  //     {"rack": "B31", "status": "available", "product_id": ""},
  //     {"rack": "B32", "status": "occupied", "product_id": "P042"},
  //     {"rack": "B33", "status": "occupied", "product_id": "P043"},
  //     {"rack": "B34", "status": "occupied", "product_id": "P044"},
  //     {"rack": "B35", "status": "available", "product_id": ""},
  //     {"rack": "B36", "status": "occupied", "product_id": "P046"},
  //     {"rack": "B37", "status": "occupied", "product_id": "P047"},
  //     {"rack": "B38", "status": "occupied", "product_id": "P048"},
  //     {"rack": "B39", "status": "available", "product_id": ""},
  //     {"rack": "B40", "status": "occupied", "product_id": "P050"},
  //     {"rack": "B41", "status": "occupied", "product_id": "P051"},
  //     {"rack": "B42", "status": "occupied", "product_id": "P052"},
  //     {"rack": "B43", "status": "available", "product_id": ""},
  //     {"rack": "B44", "status": "occupied", "product_id": "P054"},
  //     {"rack": "B45", "status": "occupied", "product_id": "P055"},
  //     {"rack": "B46", "status": "occupied", "product_id": "P056"},
  //     {"rack": "B47", "status": "available", "product_id": ""},
  //     {"rack": "B48", "status": "occupied", "product_id": "P058"},
  //     {"rack": "B49", "status": "occupied", "product_id": "P059"},
  //     {"rack": "B50", "status": "occupied", "product_id": "P060"},
  //     {"rack": "B51", "status": "available", "product_id": ""},
  //     {"rack": "B52", "status": "occupied", "product_id": "P062"},
  //     {"rack": "B53", "status": "occupied", "product_id": "P063"},
  //     {"rack": "B54", "status": "occupied", "product_id": "P064"},
  //     {"rack": "B55", "status": "available", "product_id": ""},
  //     {"rack": "B56", "status": "occupied", "product_id": "P066"},
  //     {"rack": "B57", "status": "occupied", "product_id": "P067"},
  //     {"rack": "B58", "status": "occupied", "product_id": "P068"},
  //     {"rack": "B59", "status": "available", "product_id": ""},
  //     {"rack": "B60", "status": "occupied", "product_id": "P070"},
  //     {"rack": "B61", "status": "occupied", "product_id": "P071"},
  //     {"rack": "B62", "status": "occupied", "product_id": "P072"},
  //     {"rack": "B63", "status": "available", "product_id": ""},
  //     {"rack": "B64", "status": "occupied", "product_id": "P074"}
  //   ],
  //      "C": [
  //     {"rack": "C11", "status": "available", "product_id": ""},
  //     {"rack": "C12", "status": "occupied", "product_id": "P042"},
  //     {"rack": "C13", "status": "available", "product_id": ""},
  //     {"rack": "C14", "status": "overflowed", "product_id": "P044"},
  //     {"rack": "C15", "status": "available", "product_id": ""},
  //     {"rack": "C16", "status": "overflowed", "product_id": "P046"},
  //     {"rack": "C17", "status": "available", "product_id": ""},
  //     {"rack": "C18", "status": "occupied", "product_id": "P048"},
  //     {"rack": "C19", "status": "occupied", "product_id": "P049"},
  //     {"rack": "C20", "status": "occupied", "product_id": "P050"},
  //     {"rack": "C21", "status": "occupied", "product_id": "P051"},
  //     {"rack": "C22", "status": "occupied", "product_id": "P052"},
  //     {"rack": "C23", "status": "available", "product_id": ""},
  //     {"rack": "C24", "status": "overflowed", "product_id": "P054"},
  //     {"rack": "C25", "status": "available", "product_id": ""},
  //     {"rack": "C26", "status": "overflowed", "product_id": "P056"},
  //     {"rack": "C27", "status": "available", "product_id": ""},
  //     {"rack": "C28", "status": "occupied", "product_id": "P058"},
  //     {"rack": "C29", "status": "occupied", "product_id": "P059"},
  //     {"rack": "C30", "status": "occupied", "product_id": "P060"},
  //     {"rack": "C31", "status": "available", "product_id": ""},
  //     {"rack": "C32", "status": "occupied", "product_id": "P062"},
  //     {"rack": "C33", "status": "occupied", "product_id": "P063"},
  //     {"rack": "C34", "status": "occupied", "product_id": "P064"},
  //     {"rack": "C35", "status": "available", "product_id": ""},
  //     {"rack": "C36", "status": "occupied", "product_id": "P066"},
  //     {"rack": "C37", "status": "occupied", "product_id": "P067"},
  //     {"rack": "C38", "status": "occupied", "product_id": "P068"},
  //     {"rack": "C39", "status": "available", "product_id": ""},
  //     {"rack": "C40", "status": "occupied", "product_id": "P070"},
  //     {"rack": "C41", "status": "occupied", "product_id": "P071"},
  //     {"rack": "C42", "status": "occupied", "product_id": "P072"},
  //     {"rack": "C43", "status": "available", "product_id": ""},
  //     {"rack": "C44", "status": "occupied", "product_id": "P074"},
  //     {"rack": "C45", "status": "occupied", "product_id": "P075"},
  //     {"rack": "C46", "status": "occupied", "product_id": "P076"},
  //     {"rack": "C47", "status": "available", "product_id": ""},
  //     {"rack": "C48", "status": "occupied", "product_id": "P078"},
  //     {"rack": "C49", "status": "occupied", "product_id": "P079"},
  //     {"rack": "C50", "status": "occupied", "product_id": "P080"},
  //     {"rack": "C51", "status": "available", "product_id": ""},
  //     {"rack": "C52", "status": "occupied", "product_id": "P082"},
  //     {"rack": "C53", "status": "occupied", "product_id": "P083"},
  //     {"rack": "C54", "status": "occupied", "product_id": "P084"},
  //     {"rack": "C55", "status": "available", "product_id": ""},
  //     {"rack": "C56", "status": "occupied", "product_id": "P086"},
  //     {"rack": "C57", "status": "occupied", "product_id": "P087"},
  //     {"rack": "C58", "status": "occupied", "product_id": "P088"},
  //     {"rack": "C59", "status": "available", "product_id": ""},
  //     {"rack": "C60", "status": "occupied", "product_id": "P090"},
  //     {"rack": "C61", "status": "occupied", "product_id": "P091"},
  //     {"rack": "C62", "status": "occupied", "product_id": "P092"},
  //     {"rack": "C63", "status": "available", "product_id": ""},
  //     {"rack": "C64", "status": "occupied", "product_id": "P094"}
  //      ],
  //     "D": [
  //     {"rack": "D11", "status": "available", "product_id": ""},
  //     {"rack": "D12", "status": "occupied", "product_id": "P062"},
  //     {"rack": "D13", "status": "available", "product_id": ""},
  //     {"rack": "D14", "status": "overflowed", "product_id": "P064"},
  //     {"rack": "D15", "status": "available", "product_id": ""},
  //     {"rack": "D16", "status": "overflowed", "product_id": "P066"},
  //     {"rack": "D17", "status": "available", "product_id": ""},
  //     {"rack": "D18", "status": "occupied", "product_id": "P068"},
  //     {"rack": "D19", "status": "occupied", "product_id": "P069"},
  //     {"rack": "D20", "status": "occupied", "product_id": "P070"},
  //     {"rack": "D21", "status": "occupied", "product_id": "P071"},
  //     {"rack": "D22", "status": "occupied", "product_id": "P072"},
  //     {"rack": "D23", "status": "available", "product_id": ""},
  //     {"rack": "D24", "status": "overflowed", "product_id": "P074"},
  //     {"rack": "D25", "status": "available", "product_id": ""},
  //     {"rack": "D26", "status": "overflowed", "product_id": "P076"},
  //     {"rack": "D27", "status": "available", "product_id": ""},
  //     {"rack": "D28", "status": "occupied", "product_id": "P078"},
  //     {"rack": "D29", "status": "occupied", "product_id": "P079"},
  //     {"rack": "D30", "status": "occupied", "product_id": "P080"},
  //     {"rack": "D31", "status": "available", "product_id": ""},
  //     {"rack": "D32", "status": "occupied", "product_id": "P082"},
  //     {"rack": "D33", "status": "occupied", "product_id": "P083"},
  //     {"rack": "D34", "status": "occupied", "product_id": "P084"},
  //     {"rack": "D35", "status": "available", "product_id": ""},
  //     {"rack": "D36", "status": "occupied", "product_id": "P086"},
  //     {"rack": "D37", "status": "occupied", "product_id": "P087"},
  //     {"rack": "D38", "status": "occupied", "product_id": "P088"},
  //     {"rack": "D39", "status": "available", "product_id": ""},
  //     {"rack": "D40", "status": "occupied", "product_id": "P090"},
  //     {"rack": "D41", "status": "occupied", "product_id": "P091"},
  //     {"rack": "D42", "status": "occupied", "product_id": "P092"},
  //     {"rack": "D43", "status": "available", "product_id": ""},
  //     {"rack": "D44", "status": "occupied", "product_id": "P094"},
  //     {"rack": "D45", "status": "occupied", "product_id": "P095"},
  //     {"rack": "D46", "status": "occupied", "product_id": "P096"},
  //     {"rack": "D47", "status": "available", "product_id": ""},
  //     {"rack": "D48", "status": "occupied", "product_id": "P098"},
  //     {"rack": "D49", "status": "occupied", "product_id": "P099"},
  //     {"rack": "D50", "status": "occupied", "product_id": "P100"},
  //     {"rack": "D51", "status": "available", "product_id": ""},
  //     {"rack": "D52", "status": "occupied", "product_id": "P102"},
  //     {"rack": "D53", "status": "occupied", "product_id": "P103"},
  //     {"rack": "D54", "status": "occupied", "product_id": "P104"},
  //     {"rack": "D55", "status": "available", "product_id": ""},
  //     {"rack": "D56", "status": "occupied", "product_id": "P106"},
  //     {"rack": "D57", "status": "occupied", "product_id": "P107"},
  //     {"rack": "D58", "status": "occupied", "product_id": "P108"},
  //     {"rack": "D59", "status": "available", "product_id": ""},
  //     {"rack": "D60", "status": "occupied", "product_id": "P110"},
  //     {"rack": "D61", "status": "occupied", "product_id": "P111"},
  //     {"rack": "D62", "status": "occupied", "product_id": "P112"},
  //     {"rack": "D63", "status": "available", "product_id": ""},
  //     {"rack": "D64", "status": "occupied", "product_id": "P114"}
  //   ],
  //     "E": [
  //     {"rack": "E11", "status": "available", "product_id": ""},
  //     {"rack": "E12", "status": "occupied", "product_id": "P082"},
  //     {"rack": "E13", "status": "available", "product_id": ""},
  //     {"rack": "E14", "status": "overflowed", "product_id": "P084"},
  //     {"rack": "E15", "status": "available", "product_id": ""},
  //     {"rack": "E16", "status": "overflowed", "product_id": "P086"},
  //     {"rack": "E17", "status": "available", "product_id": ""},
  //     {"rack": "E18", "status": "occupied", "product_id": "P088"},
  //     {"rack": "E19", "status": "occupied", "product_id": "P089"},
  //     {"rack": "E20", "status": "occupied", "product_id": "P090"},
  //     {"rack": "E21", "status": "occupied", "product_id": "P091"},
  //     {"rack": "E22", "status": "occupied", "product_id": "P092"},
  //     {"rack": "E23", "status": "available", "product_id": ""},
  //     {"rack": "E24", "status": "overflowed", "product_id": "P094"},
  //     {"rack": "E25", "status": "available", "product_id": ""},
  //     {"rack": "E26", "status": "overflowed", "product_id": "P096"},
  //     {"rack": "E27", "status": "available", "product_id": ""},
  //     {"rack": "E28", "status": "occupied", "product_id": "P098"},
  //     {"rack": "E29", "status": "occupied", "product_id": "P099"},
  //     {"rack": "E30", "status": "occupied", "product_id": "P100"},
  //     {"rack": "E31", "status": "available", "product_id": ""},
  //     {"rack": "E32", "status": "occupied", "product_id": "P102"},
  //     {"rack": "E33", "status": "occupied", "product_id": "P103"},
  //     {"rack": "E34", "status": "occupied", "product_id": "P104"},
  //     {"rack": "E35", "status": "available", "product_id": ""},
  //     {"rack": "E36", "status": "occupied", "product_id": "P106"},
  //     {"rack": "E37", "status": "occupied", "product_id": "P107"},
  //     {"rack": "E38", "status": "occupied", "product_id": "P108"},
  //     {"rack": "E39", "status": "available", "product_id": ""},
  //     {"rack": "E40", "status": "occupied", "product_id": "P110"},
  //     {"rack": "E41", "status": "occupied", "product_id": "P111"},
  //     {"rack": "E42", "status": "occupied", "product_id": "P112"},
  //     {"rack": "E43", "status": "available", "product_id": ""},
  //     {"rack": "E44", "status": "occupied", "product_id": "P114"},
  //     {"rack": "E45", "status": "occupied", "product_id": "P115"},
  //     {"rack": "E46", "status": "occupied", "product_id": "P116"},
  //     {"rack": "E47", "status": "available", "product_id": ""},
  //     {"rack": "E48", "status": "occupied", "product_id": "P118"},
  //     {"rack": "E49", "status": "occupied", "product_id": "P119"},
  //     {"rack": "E50", "status": "occupied", "product_id": "P120"},
  //     {"rack": "E51", "status": "available", "product_id": ""},
  //     {"rack": "E52", "status": "occupied", "product_id": "P122"},
  //     {"rack": "E53", "status": "occupied", "product_id": "P123"},
  //     {"rack": "E54", "status": "occupied", "product_id": "P124"},
  //     {"rack": "E55", "status": "available", "product_id": ""},
  //     {"rack": "E56", "status": "occupied", "product_id": "P126"},
  //     {"rack": "E57", "status": "occupied", "product_id": "P127"},
  //     {"rack": "E58", "status": "occupied", "product_id": "P128"},
  //     {"rack": "E59", "status": "available", "product_id": ""},
  //     {"rack": "E60", "status": "occupied", "product_id": "P130"},
  //     {"rack": "E61", "status": "occupied", "product_id": "P131"},
  //     {"rack": "E62", "status": "occupied", "product_id": "P132"},
  //     {"rack": "E63", "status": "available", "product_id": ""},
  //     {"rack": "E64", "status": "occupied", "product_id": "P134"}
  //   ],
  //     "F": [
  //     {"rack": "F11", "status": "available", "product_id": ""},
  //     {"rack": "F12", "status": "occupied", "product_id": "P102"},
  //     {"rack": "F13", "status": "available", "product_id": ""},
  //     {"rack": "F14", "status": "overflowed", "product_id": "P104"},
  //     {"rack": "F15", "status": "available", "product_id": ""},
  //     {"rack": "F16", "status": "overflowed", "product_id": "P106"},
  //     {"rack": "F17", "status": "available", "product_id": ""},
  //     {"rack": "F18", "status": "occupied", "product_id": "P108"},
  //     {"rack": "F19", "status": "occupied", "product_id": "P109"},
  //     {"rack": "F20", "status": "occupied", "product_id": "P110"},
  //     {"rack": "F21", "status": "occupied", "product_id": "P111"},
  //     {"rack": "F22", "status": "occupied", "product_id": "P112"},
  //     {"rack": "F23", "status": "available", "product_id": ""},
  //     {"rack": "F24", "status": "overflowed", "product_id": "P114"},
  //     {"rack": "F25", "status": "available", "product_id": ""},
  //     {"rack": "F26", "status": "overflowed", "product_id": "P116"},
  //     {"rack": "F27", "status": "available", "product_id": ""},
  //     {"rack": "F28", "status": "occupied", "product_id": "P118"},
  //     {"rack": "F29", "status": "occupied", "product_id": "P119"},
  //     {"rack": "F30", "status": "occupied", "product_id": "P120"},
  //     {"rack": "F31", "status": "available", "product_id": ""},
  //     {"rack": "F32", "status": "occupied", "product_id": "P122"},
  //     {"rack": "F33", "status": "occupied", "product_id": "P123"},
  //     {"rack": "F34", "status": "occupied", "product_id": "P124"},
  //     {"rack": "F35", "status": "available", "product_id": ""},
  //     {"rack": "F36", "status": "occupied", "product_id": "P126"},
  //     {"rack": "F37", "status": "occupied", "product_id": "P127"},
  //     {"rack": "F38", "status": "occupied", "product_id": "P128"},
  //     {"rack": "F39", "status": "available", "product_id": ""},
  //     {"rack": "F40", "status": "occupied", "product_id": "P130"},
  //     {"rack": "F41", "status": "occupied", "product_id": "P131"},
  //     {"rack": "F42", "status": "occupied", "product_id": "P132"},
  //     {"rack": "F43", "status": "available", "product_id": ""},
  //     {"rack": "F44", "status": "occupied", "product_id": "P134"},
  //     {"rack": "F45", "status": "occupied", "product_id": "P135"},
  //     {"rack": "F46", "status": "occupied", "product_id": "P136"},
  //     {"rack": "F47", "status": "available", "product_id": ""},
  //     {"rack": "F48", "status": "occupied", "product_id": "P138"},
  //     {"rack": "F49", "status": "occupied", "product_id": "P139"},
  //     {"rack": "F50", "status": "occupied", "product_id": "P140"},
  //     {"rack": "F51", "status": "available", "product_id": ""},
  //     {"rack": "F52", "status": "occupied", "product_id": "P142"},
  //     {"rack": "F53", "status": "occupied", "product_id": "P143"},
  //     {"rack": "F54", "status": "occupied", "product_id": "P144"},
  //     {"rack": "F55", "status": "available", "product_id": ""},
  //     {"rack": "F56", "status": "occupied", "product_id": "P146"},
  //     {"rack": "F57", "status": "occupied", "product_id": "P147"},
  //     {"rack": "F58", "status": "occupied", "product_id": "P148"},
  //     {"rack": "F59", "status": "available", "product_id": ""},
  //     {"rack": "F60", "status": "occupied", "product_id": "P150"},
  //     {"rack": "F61", "status": "occupied", "product_id": "P151"},
  //     {"rack": "F62", "status": "occupied", "product_id": "P152"},
  //     {"rack": "F63", "status": "available", "product_id": ""},
  //     {"rack": "F64", "status": "occupied", "product_id": "P154"}
  //   ]
  //     }
  //   },
  //   {
  //     'id' : '3',
  //     'name': 'Store C',
  //     'size': 'Small',
  //     'imageUrl': 'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png',
  //     'inventory': 80,
  //     'lastUpdated': 'June 6, 2024',
  //     'data': {
  //     'A': [
  //       {'rack': 'A11', 'status': 'available','product_id' : 'P011',},
  //       {'rack': 'A12', 'status': 'occupied','product_id' : 'P012',},
  //       {'rack': 'A13', 'status': 'available','product_id' : 'P012',},
  //       {'rack': 'A14', 'status': 'overflowed','product_id' : 'P014',},
  //       {'rack': 'A21', 'status': 'available','product_id' : 'P015',},
  //       {'rack': 'A22', 'status': 'overflowed','product_id' : 'P016',},
  //       {'rack': 'A23', 'status': 'available','product_id' : 'P015',},
  //       {'rack': 'A24', 'status': 'occupied','product_id' : 'P013',},
  //       {'rack': 'A31', 'status': 'occupied','product_id' : 'P012',},
  //       {'rack': 'A32', 'status': 'occupied','product_id' : 'P013',},
  //       {'rack': 'A33', 'status': 'occupied','product_id' : 'P012',},
  //       {'rack': 'A34', 'status': 'occupied','product_id' : 'P015',},
  //       {'rack': 'A41', 'status': 'available','product_id' : 'P016',},
  //       {'rack': 'A42', 'status': 'overflowed','product_id' : 'P014',},
  //       {'rack': 'A43', 'status': 'available','product_id' : 'P013',},
  //       {'rack': 'A44', 'status': 'overflowed','product_id' : 'P012',},
  //       {'rack': 'A51', 'status': 'available','product_id' : 'P011',},
  //       {'rack': 'A52', 'status': 'occupied','product_id' : 'P014',},
  //       {'rack': 'A53', 'status': 'occupied','product_id' : 'P013'},
  //       {'rack': 'A54', 'status': 'occupied','product_id' : 'P014',}
  //     ],
  //     'B': [
  //       {'rack': 'B11', 'status': 'available','product_id' : 'P021'},
  //       {'rack': 'B12', 'status': 'occupied','product_id' : 'P022'},
  //       {'rack': 'B13', 'status': 'available','product_id' : 'P023'},
  //       {'rack': 'B14', 'status': 'overflowed','product_id' : 'P024'},
  //       {'rack': 'B21', 'status': 'available','product_id' : 'P025'},
  //       {'rack': 'B22', 'status': 'overflowed','product_id' : 'P026'},
  //       {'rack': 'B23', 'status': 'available','product_id' : 'P027'},
  //       {'rack': 'B24', 'status': 'occupied','product_id' : 'P028'},
  //       {'rack': 'B31', 'status': 'occupied','product_id' : 'P029'},
  //       {'rack': 'B32', 'status': 'occupied','product_id' : 'P030'},
  //       {'rack': 'B33', 'status': 'occupied','product_id' : 'P031'},
  //       {'rack': 'B34', 'status': 'occupied','product_id' : 'P032'},
  //       {'rack': 'B41', 'status': 'available','product_id' : 'P033'},
  //       {'rack': 'B42', 'status': 'overflowed','product_id' : 'P034'},
  //       {'rack': 'B43', 'status': 'available','product_id' : 'P035'},
  //       {'rack': 'B44', 'status': 'overflowed','product_id' : 'P036'},
  //       {'rack': 'B51', 'status': 'available','product_id' : 'P037'},
  //       {'rack': 'B52', 'status': 'occupied','product_id' : 'P038'},
  //       {'rack': 'B53', 'status': 'occupied','product_id' : 'P039'},
  //       {'rack': 'B54', 'status': 'occupied','product_id' : 'P040'}
  //     ],
  //     'C': [
  //       {'rack': 'C11', 'status': 'available','product_id' : 'P041'},
  //       {'rack': 'C12', 'status': 'occupied','product_id' : 'P042'},
  //       {'rack': 'C13', 'status': 'available','product_id' : 'P043'},
  //       {'rack': 'C14', 'status': 'overflowed','product_id' : 'P044'},
  //       {'rack': 'C21', 'status': 'available','product_id' : 'P045'},
  //       {'rack': 'C22', 'status': 'overflowed','product_id' : 'P046'},
  //       {'rack': 'C23', 'status': 'available','product_id' : 'P047'},
  //       {'rack': 'C24', 'status': 'occupied','product_id' : 'P048'},
  //       {'rack': 'C31', 'status': 'occupied','product_id' : 'P049'},
  //       {'rack': 'C32', 'status': 'occupied','product_id' : 'P050'},
  //       {'rack': 'C33', 'status': 'occupied','product_id' : 'P051'},
  //       {'rack': 'C34', 'status': 'occupied','product_id' : 'P052'},
  //       {'rack': 'C41', 'status': 'available','product_id' : 'P053'},
  //       {'rack': 'C42', 'status': 'overflowed','product_id' : 'P054'},
  //       {'rack': 'C43', 'status': 'available','product_id' : 'P055'},
  //       {'rack': 'C44', 'status': 'overflowed','product_id' : 'P056'},
  //       {'rack': 'C51', 'status': 'available','product_id' : 'P057'},
  //       {'rack': 'C52', 'status': 'occupied','product_id' : 'P058'},
  //       {'rack': 'C53', 'status': 'occupied','product_id' : 'P059'},
  //       {'rack': 'C54', 'status': 'occupied','product_id' : 'P060'}
  //     ],
  //     'D': [
  //       {'rack': 'D11', 'status': 'available','product_id' : 'P061'},
  //       {'rack': 'D12', 'status': 'occupied','product_id' : 'P062'},
  //       {'rack': 'D13', 'status': 'available','product_id' : 'P063'},
  //       {'rack': 'D14', 'status': 'overflowed','product_id' : 'P064'},
  //       {'rack': 'D21', 'status': 'available','product_id' : 'P065'},
  //       {'rack': 'D22', 'status': 'overflowed','product_id' : 'P066'},
  //       {'rack': 'D23', 'status': 'available','product_id' : 'P067'},
  //       {'rack': 'D24', 'status': 'occupied','product_id' : 'P068'},
  //       {'rack': 'D31', 'status': 'occupied','product_id' : 'P069'},
  //       {'rack': 'D32', 'status': 'occupied','product_id' : 'P070'},
  //       {'rack': 'D33', 'status': 'occupied','product_id' : 'P071'},
  //       {'rack': 'D34', 'status': 'occupied','product_id' : 'P072'},
  //       {'rack': 'D41', 'status': 'available','product_id' : 'P073'},
  //       {'rack': 'D42', 'status': 'overflowed','product_id' : 'P074'},
  //       {'rack': 'D43', 'status': 'available','product_id' : 'P075'},
  //       {'rack': 'D44', 'status': 'overflowed','product_id' : 'P076'},
  //       {'rack': 'D51', 'status': 'available','product_id' : 'P077'},
  //       {'rack': 'D52', 'status': 'occupied','product_id' : 'P078'},
  //       {'rack': 'D53', 'status': 'occupied','product_id' : 'P079'},
  //       {'rack': 'D54', 'status': 'occupied','product_id' : 'P080'}
  //     ],
  //     'E': [
  //       {'rack': 'E11', 'status': 'available','product_id' : 'P081'},
  //       {'rack': 'E12', 'status': 'occupied','product_id' : 'P082'},
  //       {'rack': 'E13', 'status': 'available','product_id' : 'P083'},
  //       {'rack': 'E14', 'status': 'overflowed','product_id' : 'P084'},
  //       {'rack': 'E21', 'status': 'available','product_id' : 'P085'},
  //       {'rack': 'E22', 'status': 'overflowed','product_id' : 'P086'},
  //       {'rack': 'E23', 'status': 'available','product_id' : 'P087'},
  //       {'rack': 'E24', 'status': 'occupied','product_id' : 'P088'},
  //       {'rack': 'E31', 'status': 'occupied','product_id' : 'P089'},
  //       {'rack': 'E32', 'status': 'occupied','product_id' : 'P090'},
  //       {'rack': 'E33', 'status': 'occupied','product_id' : 'P091'},
  //       {'rack': 'E34', 'status': 'occupied','product_id' : 'P092'},
  //       {'rack': 'E41', 'status': 'available','product_id' : 'P093'},
  //       {'rack': 'E42', 'status': 'overflowed','product_id' : 'P094'},
  //       {'rack': 'E43', 'status': 'available','product_id' : 'P095'},
  //       {'rack': 'E44', 'status': 'overflowed','product_id' : 'P096'},
  //       {'rack': 'E51', 'status': 'available','product_id' : 'P097'},
  //       {'rack': 'E52', 'status': 'occupied','product_id' : 'P098'},
  //       {'rack': 'E53', 'status': 'occupied','product_id' : 'P099'},
  //       {'rack': 'E54', 'status': 'occupied','product_id' : 'P100'}
  //     ],
  //     'F': [
  //       {'rack': 'F11', 'status': 'available','product_id' : 'P101'},
  //       {'rack': 'F12', 'status': 'occupied','product_id' : 'P102'},
  //       {'rack': 'F13', 'status': 'available','product_id' : 'P103'},
  //       {'rack': 'F14', 'status': 'overflowed','product_id' : 'P104'},
  //       {'rack': 'F21', 'status': 'available','product_id' : 'P105'},
  //       {'rack': 'F22', 'status': 'overflowed','product_id' : 'P106'},
  //       {'rack': 'F23', 'status': 'available','product_id' : 'P107'},
  //       {'rack': 'F24', 'status': 'occupied','product_id' : 'P108'},
  //       {'rack': 'F31', 'status': 'occupied','product_id' : 'P109'},
  //       {'rack': 'F32', 'status': 'occupied','product_id' : 'P110'},
  //       {'rack': 'F33', 'status': 'occupied','product_id' : 'P111'},
  //       {'rack': 'F34', 'status': 'occupied','product_id' : 'P112'},
  //       {'rack': 'F41', 'status': 'available','product_id' : 'P113'},
  //       {'rack': 'F42', 'status': 'overflowed','product_id' : 'P114'},
  //       {'rack': 'F43', 'status': 'available','product_id' : 'P115'},
  //       {'rack': 'F44', 'status': 'overflowed','product_id' : 'P116'},
  //       {'rack': 'F51', 'status': 'available','product_id' : 'P117'},
  //       {'rack': 'F52', 'status': 'occupied','product_id' : 'P118'},
  //       {'rack': 'F53', 'status': 'occupied','product_id' : 'P119'},
  //       {'rack': 'F54', 'status': 'occupied','product_id' : 'P120'}
  //     ]
  //     }
  //   },
  //   {
  //     'id' : '4',
  //     'name': 'Store D',
  //     'size': 'Small',
  //     'imageUrl': 'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png',
  //     'inventory': 70,
  //     'lastUpdated': 'June 6, 2024',
  //     'data': {
  //      "A": [
  //     {"rack": "A11", "status": "available", "product_id": ""},
  //     {"rack": "A12", "status": "occupied", "product_id": "P012"},
  //     {"rack": "A13", "status": "available", "product_id": ""},
  //     {"rack": "A14", "status": "overflowed", "product_id": "P014"},
  //     {"rack": "A15", "status": "available", "product_id": ""},
  //     {"rack": "A16", "status": "overflowed", "product_id": "P016"},
  //     {"rack": "A17", "status": "available", "product_id": ""},
  //     {"rack": "A18", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A19", "status": "occupied", "product_id": "P012"},
  //     {"rack": "A20", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A21", "status": "occupied", "product_id": "P012"},
  //     {"rack": "A22", "status": "occupied", "product_id": "P015"},
  //     {"rack": "A23", "status": "available", "product_id": ""},
  //     {"rack": "A24", "status": "overflowed", "product_id": "P014"},
  //     {"rack": "A25", "status": "available", "product_id": ""},
  //     {"rack": "A26", "status": "overflowed", "product_id": "P012"},
  //     {"rack": "A27", "status": "available", "product_id": ""},
  //     {"rack": "A28", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A29", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A30", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A31", "status": "available", "product_id": ""},
  //     {"rack": "A32", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A33", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A34", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A35", "status": "available", "product_id": ""},
  //     {"rack": "A36", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A37", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A38", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A39", "status": "available", "product_id": ""},
  //     {"rack": "A40", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A41", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A42", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A43", "status": "available", "product_id": ""},
  //     {"rack": "A44", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A45", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A46", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A47", "status": "available", "product_id": ""},
  //     {"rack": "A48", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A49", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A50", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A51", "status": "available", "product_id": ""},
  //     {"rack": "A52", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A53", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A54", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A55", "status": "available", "product_id": ""},
  //     {"rack": "A56", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A57", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A58", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A59", "status": "available", "product_id": ""},
  //     {"rack": "A60", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A61", "status": "occupied", "product_id": "P013"},
  //     {"rack": "A62", "status": "occupied", "product_id": "P014"},
  //     {"rack": "A63", "status": "available", "product_id": ""},
  //     {"rack": "A64", "status": "occupied", "product_id": "P014"}
  //   ],
  //     "B": [
  //     {"rack": "B11", "status": "available", "product_id": ""},
  //     {"rack": "B12", "status": "occupied", "product_id": "P022"},
  //     {"rack": "B13", "status": "available", "product_id": ""},
  //     {"rack": "B14", "status": "overflowed", "product_id": "P024"},
  //     {"rack": "B15", "status": "available", "product_id": ""},
  //     {"rack": "B16", "status": "overflowed", "product_id": "P026"},
  //     {"rack": "B17", "status": "available", "product_id": ""},
  //     {"rack": "B18", "status": "occupied", "product_id": "P028"},
  //     {"rack": "B19", "status": "occupied", "product_id": "P029"},
  //     {"rack": "B20", "status": "occupied", "product_id": "P030"},
  //     {"rack": "B21", "status": "occupied", "product_id": "P031"},
  //     {"rack": "B22", "status": "occupied", "product_id": "P032"},
  //     {"rack": "B23", "status": "available", "product_id": ""},
  //     {"rack": "B24", "status": "overflowed", "product_id": "P034"},
  //     {"rack": "B25", "status": "available", "product_id": ""},
  //     {"rack": "B26", "status": "overflowed", "product_id": "P036"},
  //     {"rack": "B27", "status": "available", "product_id": ""},
  //     {"rack": "B28", "status": "occupied", "product_id": "P038"},
  //     {"rack": "B29", "status": "occupied", "product_id": "P039"},
  //     {"rack": "B30", "status": "occupied", "product_id": "P040"},
  //     {"rack": "B31", "status": "available", "product_id": ""},
  //     {"rack": "B32", "status": "occupied", "product_id": "P042"},
  //     {"rack": "B33", "status": "occupied", "product_id": "P043"},
  //     {"rack": "B34", "status": "occupied", "product_id": "P044"},
  //     {"rack": "B35", "status": "available", "product_id": ""},
  //     {"rack": "B36", "status": "occupied", "product_id": "P046"},
  //     {"rack": "B37", "status": "occupied", "product_id": "P047"},
  //     {"rack": "B38", "status": "occupied", "product_id": "P048"},
  //     {"rack": "B39", "status": "available", "product_id": ""},
  //     {"rack": "B40", "status": "occupied", "product_id": "P050"},
  //     {"rack": "B41", "status": "occupied", "product_id": "P051"},
  //     {"rack": "B42", "status": "occupied", "product_id": "P052"},
  //     {"rack": "B43", "status": "available", "product_id": ""},
  //     {"rack": "B44", "status": "occupied", "product_id": "P054"},
  //     {"rack": "B45", "status": "occupied", "product_id": "P055"},
  //     {"rack": "B46", "status": "occupied", "product_id": "P056"},
  //     {"rack": "B47", "status": "available", "product_id": ""},
  //     {"rack": "B48", "status": "occupied", "product_id": "P058"},
  //     {"rack": "B49", "status": "occupied", "product_id": "P059"},
  //     {"rack": "B50", "status": "occupied", "product_id": "P060"},
  //     {"rack": "B51", "status": "available", "product_id": ""},
  //     {"rack": "B52", "status": "occupied", "product_id": "P062"},
  //     {"rack": "B53", "status": "occupied", "product_id": "P063"},
  //     {"rack": "B54", "status": "occupied", "product_id": "P064"},
  //     {"rack": "B55", "status": "available", "product_id": ""},
  //     {"rack": "B56", "status": "occupied", "product_id": "P066"},
  //     {"rack": "B57", "status": "occupied", "product_id": "P067"},
  //     {"rack": "B58", "status": "occupied", "product_id": "P068"},
  //     {"rack": "B59", "status": "available", "product_id": ""},
  //     {"rack": "B60", "status": "occupied", "product_id": "P070"},
  //     {"rack": "B61", "status": "occupied", "product_id": "P071"},
  //     {"rack": "B62", "status": "occupied", "product_id": "P072"},
  //     {"rack": "B63", "status": "available", "product_id": ""},
  //     {"rack": "B64", "status": "occupied", "product_id": "P074"}
  //   ],
  //      "C": [
  //     {"rack": "C11", "status": "available", "product_id": ""},
  //     {"rack": "C12", "status": "occupied", "product_id": "P042"},
  //     {"rack": "C13", "status": "available", "product_id": ""},
  //     {"rack": "C14", "status": "overflowed", "product_id": "P044"},
  //     {"rack": "C15", "status": "available", "product_id": ""},
  //     {"rack": "C16", "status": "overflowed", "product_id": "P046"},
  //     {"rack": "C17", "status": "available", "product_id": ""},
  //     {"rack": "C18", "status": "occupied", "product_id": "P048"},
  //     {"rack": "C19", "status": "occupied", "product_id": "P049"},
  //     {"rack": "C20", "status": "occupied", "product_id": "P050"},
  //     {"rack": "C21", "status": "occupied", "product_id": "P051"},
  //     {"rack": "C22", "status": "occupied", "product_id": "P052"},
  //     {"rack": "C23", "status": "available", "product_id": ""},
  //     {"rack": "C24", "status": "overflowed", "product_id": "P054"},
  //     {"rack": "C25", "status": "available", "product_id": ""},
  //     {"rack": "C26", "status": "overflowed", "product_id": "P056"},
  //     {"rack": "C27", "status": "available", "product_id": ""},
  //     {"rack": "C28", "status": "occupied", "product_id": "P058"},
  //     {"rack": "C29", "status": "occupied", "product_id": "P059"},
  //     {"rack": "C30", "status": "occupied", "product_id": "P060"},
  //     {"rack": "C31", "status": "available", "product_id": ""},
  //     {"rack": "C32", "status": "occupied", "product_id": "P062"},
  //     {"rack": "C33", "status": "occupied", "product_id": "P063"},
  //     {"rack": "C34", "status": "occupied", "product_id": "P064"},
  //     {"rack": "C35", "status": "available", "product_id": ""},
  //     {"rack": "C36", "status": "occupied", "product_id": "P066"},
  //     {"rack": "C37", "status": "occupied", "product_id": "P067"},
  //     {"rack": "C38", "status": "occupied", "product_id": "P068"},
  //     {"rack": "C39", "status": "available", "product_id": ""},
  //     {"rack": "C40", "status": "occupied", "product_id": "P070"},
  //     {"rack": "C41", "status": "occupied", "product_id": "P071"},
  //     {"rack": "C42", "status": "occupied", "product_id": "P072"},
  //     {"rack": "C43", "status": "available", "product_id": ""},
  //     {"rack": "C44", "status": "occupied", "product_id": "P074"},
  //     {"rack": "C45", "status": "occupied", "product_id": "P075"},
  //     {"rack": "C46", "status": "occupied", "product_id": "P076"},
  //     {"rack": "C47", "status": "available", "product_id": ""},
  //     {"rack": "C48", "status": "occupied", "product_id": "P078"},
  //     {"rack": "C49", "status": "occupied", "product_id": "P079"},
  //     {"rack": "C50", "status": "occupied", "product_id": "P080"},
  //     {"rack": "C51", "status": "available", "product_id": ""},
  //     {"rack": "C52", "status": "occupied", "product_id": "P082"},
  //     {"rack": "C53", "status": "occupied", "product_id": "P083"},
  //     {"rack": "C54", "status": "occupied", "product_id": "P084"},
  //     {"rack": "C55", "status": "available", "product_id": ""},
  //     {"rack": "C56", "status": "occupied", "product_id": "P086"},
  //     {"rack": "C57", "status": "occupied", "product_id": "P087"},
  //     {"rack": "C58", "status": "occupied", "product_id": "P088"},
  //     {"rack": "C59", "status": "available", "product_id": ""},
  //     {"rack": "C60", "status": "occupied", "product_id": "P090"},
  //     {"rack": "C61", "status": "occupied", "product_id": "P091"},
  //     {"rack": "C62", "status": "occupied", "product_id": "P092"},
  //     {"rack": "C63", "status": "available", "product_id": ""},
  //     {"rack": "C64", "status": "occupied", "product_id": "P094"}
  //      ],
  //     "D": [
  //     {"rack": "D11", "status": "available", "product_id": ""},
  //     {"rack": "D12", "status": "occupied", "product_id": "P062"},
  //     {"rack": "D13", "status": "available", "product_id": ""},
  //     {"rack": "D14", "status": "overflowed", "product_id": "P064"},
  //     {"rack": "D15", "status": "available", "product_id": ""},
  //     {"rack": "D16", "status": "overflowed", "product_id": "P066"},
  //     {"rack": "D17", "status": "available", "product_id": ""},
  //     {"rack": "D18", "status": "occupied", "product_id": "P068"},
  //     {"rack": "D19", "status": "occupied", "product_id": "P069"},
  //     {"rack": "D20", "status": "occupied", "product_id": "P070"},
  //     {"rack": "D21", "status": "occupied", "product_id": "P071"},
  //     {"rack": "D22", "status": "occupied", "product_id": "P072"},
  //     {"rack": "D23", "status": "available", "product_id": ""},
  //     {"rack": "D24", "status": "overflowed", "product_id": "P074"},
  //     {"rack": "D25", "status": "available", "product_id": ""},
  //     {"rack": "D26", "status": "overflowed", "product_id": "P076"},
  //     {"rack": "D27", "status": "available", "product_id": ""},
  //     {"rack": "D28", "status": "occupied", "product_id": "P078"},
  //     {"rack": "D29", "status": "occupied", "product_id": "P079"},
  //     {"rack": "D30", "status": "occupied", "product_id": "P080"},
  //     {"rack": "D31", "status": "available", "product_id": ""},
  //     {"rack": "D32", "status": "occupied", "product_id": "P082"},
  //     {"rack": "D33", "status": "occupied", "product_id": "P083"},
  //     {"rack": "D34", "status": "occupied", "product_id": "P084"},
  //     {"rack": "D35", "status": "available", "product_id": ""},
  //     {"rack": "D36", "status": "occupied", "product_id": "P086"},
  //     {"rack": "D37", "status": "occupied", "product_id": "P087"},
  //     {"rack": "D38", "status": "occupied", "product_id": "P088"},
  //     {"rack": "D39", "status": "available", "product_id": ""},
  //     {"rack": "D40", "status": "occupied", "product_id": "P090"},
  //     {"rack": "D41", "status": "occupied", "product_id": "P091"},
  //     {"rack": "D42", "status": "occupied", "product_id": "P092"},
  //     {"rack": "D43", "status": "available", "product_id": ""},
  //     {"rack": "D44", "status": "occupied", "product_id": "P094"},
  //     {"rack": "D45", "status": "occupied", "product_id": "P095"},
  //     {"rack": "D46", "status": "occupied", "product_id": "P096"},
  //     {"rack": "D47", "status": "available", "product_id": ""},
  //     {"rack": "D48", "status": "occupied", "product_id": "P098"},
  //     {"rack": "D49", "status": "occupied", "product_id": "P099"},
  //     {"rack": "D50", "status": "occupied", "product_id": "P100"},
  //     {"rack": "D51", "status": "available", "product_id": ""},
  //     {"rack": "D52", "status": "occupied", "product_id": "P102"},
  //     {"rack": "D53", "status": "occupied", "product_id": "P103"},
  //     {"rack": "D54", "status": "occupied", "product_id": "P104"},
  //     {"rack": "D55", "status": "available", "product_id": ""},
  //     {"rack": "D56", "status": "occupied", "product_id": "P106"},
  //     {"rack": "D57", "status": "occupied", "product_id": "P107"},
  //     {"rack": "D58", "status": "occupied", "product_id": "P108"},
  //     {"rack": "D59", "status": "available", "product_id": ""},
  //     {"rack": "D60", "status": "occupied", "product_id": "P110"},
  //     {"rack": "D61", "status": "occupied", "product_id": "P111"},
  //     {"rack": "D62", "status": "occupied", "product_id": "P112"},
  //     {"rack": "D63", "status": "available", "product_id": ""},
  //     {"rack": "D64", "status": "occupied", "product_id": "P114"}
  //   ],
  //     "E": [
  //     {"rack": "E11", "status": "available", "product_id": ""},
  //     {"rack": "E12", "status": "occupied", "product_id": "P082"},
  //     {"rack": "E13", "status": "available", "product_id": ""},
  //     {"rack": "E14", "status": "overflowed", "product_id": "P084"},
  //     {"rack": "E15", "status": "available", "product_id": ""},
  //     {"rack": "E16", "status": "overflowed", "product_id": "P086"},
  //     {"rack": "E17", "status": "available", "product_id": ""},
  //     {"rack": "E18", "status": "occupied", "product_id": "P088"},
  //     {"rack": "E19", "status": "occupied", "product_id": "P089"},
  //     {"rack": "E20", "status": "occupied", "product_id": "P090"},
  //     {"rack": "E21", "status": "occupied", "product_id": "P091"},
  //     {"rack": "E22", "status": "occupied", "product_id": "P092"},
  //     {"rack": "E23", "status": "available", "product_id": ""},
  //     {"rack": "E24", "status": "overflowed", "product_id": "P094"},
  //     {"rack": "E25", "status": "available", "product_id": ""},
  //     {"rack": "E26", "status": "overflowed", "product_id": "P096"},
  //     {"rack": "E27", "status": "available", "product_id": ""},
  //     {"rack": "E28", "status": "occupied", "product_id": "P098"},
  //     {"rack": "E29", "status": "occupied", "product_id": "P099"},
  //     {"rack": "E30", "status": "occupied", "product_id": "P100"},
  //     {"rack": "E31", "status": "available", "product_id": ""},
  //     {"rack": "E32", "status": "occupied", "product_id": "P102"},
  //     {"rack": "E33", "status": "occupied", "product_id": "P103"},
  //     {"rack": "E34", "status": "occupied", "product_id": "P104"},
  //     {"rack": "E35", "status": "available", "product_id": ""},
  //     {"rack": "E36", "status": "occupied", "product_id": "P106"},
  //     {"rack": "E37", "status": "occupied", "product_id": "P107"},
  //     {"rack": "E38", "status": "occupied", "product_id": "P108"},
  //     {"rack": "E39", "status": "available", "product_id": ""},
  //     {"rack": "E40", "status": "occupied", "product_id": "P110"},
  //     {"rack": "E41", "status": "occupied", "product_id": "P111"},
  //     {"rack": "E42", "status": "occupied", "product_id": "P112"},
  //     {"rack": "E43", "status": "available", "product_id": ""},
  //     {"rack": "E44", "status": "occupied", "product_id": "P114"},
  //     {"rack": "E45", "status": "occupied", "product_id": "P115"},
  //     {"rack": "E46", "status": "occupied", "product_id": "P116"},
  //     {"rack": "E47", "status": "available", "product_id": ""},
  //     {"rack": "E48", "status": "occupied", "product_id": "P118"},
  //     {"rack": "E49", "status": "occupied", "product_id": "P119"},
  //     {"rack": "E50", "status": "occupied", "product_id": "P120"},
  //     {"rack": "E51", "status": "available", "product_id": ""},
  //     {"rack": "E52", "status": "occupied", "product_id": "P122"},
  //     {"rack": "E53", "status": "occupied", "product_id": "P123"},
  //     {"rack": "E54", "status": "occupied", "product_id": "P124"},
  //     {"rack": "E55", "status": "available", "product_id": ""},
  //     {"rack": "E56", "status": "occupied", "product_id": "P126"},
  //     {"rack": "E57", "status": "occupied", "product_id": "P127"},
  //     {"rack": "E58", "status": "occupied", "product_id": "P128"},
  //     {"rack": "E59", "status": "available", "product_id": ""},
  //     {"rack": "E60", "status": "occupied", "product_id": "P130"},
  //     {"rack": "E61", "status": "occupied", "product_id": "P131"},
  //     {"rack": "E62", "status": "occupied", "product_id": "P132"},
   
  //     {"rack": "E63", "status": "available", "product_id": ""},
  //     {"rack": "E64", "status": "occupied", "product_id": "P134"}
  //   ],
  //     "F": [
  //     {"rack": "F11", "status": "available", "product_id": ""},
  //     {"rack": "F12", "status": "occupied", "product_id": "P102"},
  //     {"rack": "F13", "status": "available", "product_id": ""},
  //     {"rack": "F14", "status": "overflowed", "product_id": "P104"},
  //     {"rack": "F15", "status": "available", "product_id": ""},
  //     {"rack": "F16", "status": "overflowed", "product_id": "P106"},
  //     {"rack": "F17", "status": "available", "product_id": ""},
  //     {"rack": "F18", "status": "occupied", "product_id": "P108"},
  //     {"rack": "F19", "status": "occupied", "product_id": "P109"},
  //     {"rack": "F20", "status": "occupied", "product_id": "P110"},
  //     {"rack": "F21", "status": "occupied", "product_id": "P111"},
  //     {"rack": "F22", "status": "occupied", "product_id": "P112"},
  //     {"rack": "F23", "status": "available", "product_id": ""},
  //     {"rack": "F24", "status": "overflowed", "product_id": "P114"},
  //     {"rack": "F25", "status": "available", "product_id": ""},
  //     {"rack": "F26", "status": "overflowed", "product_id": "P116"},
  //     {"rack": "F27", "status": "available", "product_id": ""},
  //     {"rack": "F28", "status": "occupied", "product_id": "P118"},
  //     {"rack": "F29", "status": "occupied", "product_id": "P119"},
  //     {"rack": "F30", "status": "occupied", "product_id": "P120"},
  //     {"rack": "F31", "status": "available", "product_id": ""},
  //     {"rack": "F32", "status": "occupied", "product_id": "P122"},
  //     {"rack": "F33", "status": "occupied", "product_id": "P123"},
  //     {"rack": "F34", "status": "occupied", "product_id": "P124"},
  //     {"rack": "F35", "status": "available", "product_id": ""},
  //     {"rack": "F36", "status": "occupied", "product_id": "P126"},
  //     {"rack": "F37", "status": "occupied", "product_id": "P127"},
  //     {"rack": "F38", "status": "occupied", "product_id": "P128"},
  //     {"rack": "F39", "status": "available", "product_id": ""},
  //     {"rack": "F40", "status": "occupied", "product_id": "P130"},
  //     {"rack": "F41", "status": "occupied", "product_id": "P131"},
  //     {"rack": "F42", "status": "occupied", "product_id": "P132"},
  //     {"rack": "F43", "status": "available", "product_id": ""},
  //     {"rack": "F44", "status": "occupied", "product_id": "P134"},
  //     {"rack": "F45", "status": "occupied", "product_id": "P135"},
  //     {"rack": "F46", "status": "occupied", "product_id": "P136"},
  //     {"rack": "F47", "status": "available", "product_id": ""},
  //     {"rack": "F48", "status": "occupied", "product_id": "P138"},
  //     {"rack": "F49", "status": "occupied", "product_id": "P139"},
  //     {"rack": "F50", "status": "occupied", "product_id": "P140"},
  //     {"rack": "F51", "status": "available", "product_id": ""},
  //     {"rack": "F52", "status": "occupied", "product_id": "P142"},
  //     {"rack": "F53", "status": "occupied", "product_id": "P143"},
  //     {"rack": "F54", "status": "occupied", "product_id": "P144"},
  //     {"rack": "F55", "status": "available", "product_id": ""},
  //     {"rack": "F56", "status": "occupied", "product_id": "P146"},
  //     {"rack": "F57", "status": "occupied", "product_id": "P147"},
  //     {"rack": "F58", "status": "occupied", "product_id": "P148"},
  //     {"rack": "F59", "status": "available", "product_id": ""},
  //     {"rack": "F60", "status": "occupied", "product_id": "P150"},
  //     {"rack": "F61", "status": "occupied", "product_id": "P151"},
  //     {"rack": "F62", "status": "occupied", "product_id": "P152"},
  //     {"rack": "F63", "status": "available", "product_id": ""},
  //     {"rack": "F64", "status": "occupied", "product_id": "P154"}
  //   ]
  //   }},
  //   ];
  //   }
    