import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DogScreen extends StatefulWidget {
  const DogScreen({Key? key}) : super(key: key);

  @override
  State<DogScreen> createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  int _selectedIndex = 0;
  String _dogImageUrl = '';
  late User _user;
   bool _isLoading = false;

  void _fetchRandomDogImage() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String imageUrl = responseData['message'];

      setState(() {
        _dogImageUrl = imageUrl;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load random dog image');
    }
  }


  void _fetchRandomUserProfile() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, dynamic> userMap = responseData['results'][0];
      final user = User.fromJson(userMap);
      setState(() {
        _user = user;
      });
    } else {
      throw Exception('Failed to load random user profile');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRandomDogImage();
    _fetchRandomUserProfile();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDogImageScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _dogImageUrl.isEmpty
                ? Text('No image available')
                : Image.network(
              _dogImageUrl,
              //width: 300,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
         // SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchRandomDogImage,
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }



  Widget _buildBluetoothScreen() {
    return Center(
      child: Text('Bluetooth Screen'),
    );
  }

  Widget _buildProfileScreen() {
    String dob = _user.dob;


    DateTime dateTime = DateTime.parse(dob);


    String formattedDate = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

    print("dob==${formattedDate}");

    return _user != null
        ? Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.blueGrey,
            backgroundImage: NetworkImage(_user.picture),
          ),
          SizedBox(height: 20),
          Text(
            '${_user.name}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${_user.location}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${_user.email}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Date of Birth'),
            subtitle: Text(formattedDate),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Number of days since registered'),
            subtitle: Text('${_user.registeredDays} days'),
          ),
        ],
      ),
    )
        : Center(child: CircularProgressIndicator());
  }


  @override
  Widget build(BuildContext context) {

    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = _buildDogImageScreen();
        break;
      case 1:
        currentScreen = _buildBluetoothScreen();
        break;
      case 2:
        currentScreen = _buildProfileScreen();
        break;
      default:
        currentScreen = _buildDogImageScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Fin InfoTech'),
      ),
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Dog Image',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'Bluetooth',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class User {
  final String name;
  final String location;
  final String email;
  final String dob;
  final int registeredDays;
  final String picture;

  User({
    required this.name,
    required this.location,
    required this.email,
    required this.dob,
    required this.registeredDays,
    required this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final dobDate = DateTime.parse(json['dob']['date']);
    final registeredDate = DateTime.parse(json['registered']['date']);
    final today = DateTime.now();


    final difference = today.difference(registeredDate);
    final registeredDays = difference.inDays;

    return User(
      name: '${json['name']['first']} ${json['name']['last']}',
      location: '${json['location']['city']}, ${json['location']['country']}',
      email: json['email'],
      dob: dobDate.toString(),
      registeredDays: registeredDays,
      picture: json['picture']['large'],
    );
  }
}
