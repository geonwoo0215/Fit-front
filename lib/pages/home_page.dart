import 'package:fit_fe/pages/board_page.dart';
import 'package:fit_fe/pages/create_post_page1.dart';
import 'package:fit_fe/pages/profile_page.dart';
import 'package:fit_fe/pages/rank_page.dart';
import 'package:fit_fe/pages/search_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _getAppBarTitle(),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: _getBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: (int index) {
          if (index != 2) {
            setState(() {
              _currentIndex = index;
            });
            print('Selected item: $index');
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostStep1(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return Text('Fit');
      case 1:
        return Text('검색');
      case 3:
        return Text('랭킹');
      case 4:
        return Text('프로필');
      default:
        return Text('Fit');
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return BoardPage();
      case 1:
        return SearchPage();
      case 3:
        return RankPage();
      case 4:
        return ProfilePage();
      default:
        return Center(child: Text('이곳에 홈 내용을 표시하면 됩니다.'));
    }
  }
}
