import 'package:flutter/material.dart';
import 'package:travel_places/screen/profile_screen.dart';
import 'package:travel_places/screen/home_screen.dart';
import 'package:travel_places/screen/add_place_screen.dart';
import 'package:travel_places/screen/community_screen.dart';
import 'package:travel_places/widget/widget_role.dart';

class SelectionScreen extends StatefulWidget{
  const SelectionScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _SelectionScreenState();
  }
}

class _SelectionScreenState extends State<SelectionScreen>{
  int _selectedIndex = 0;
  String? role;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const AddPlaceScreen(),
    const ProfileScreen(),
    const CommunityScreen(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedIndex == 3 ? WidgetRole(child:_widgetOptions.elementAt(_selectedIndex))
                                   : _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Community',
            ),
          ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
