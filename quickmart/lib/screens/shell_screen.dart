import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmart/routes/app_router.dart';

//Common Screen
class ShellScreen extends StatelessWidget {
  final Widget? child;
  const ShellScreen({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          )
        ],
        //go: is bacl jbutton will take you out of application
        //push: keeps the first one and adds a screen on top of it
        onTap: (index) {
          if (index == 0) {
            context.go(AppRouter.home.path);
          } else if (index == 1) {
            context.goNamed(AppRouter.cart.name);
          } else if (index == 2) {
            context.goNamed(AppRouter.favourite.name);
          }
        },
      ),
    );
  }
}
