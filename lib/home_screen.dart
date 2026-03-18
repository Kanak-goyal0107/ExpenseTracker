import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let me track your balance"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/img.png"),
              fit: BoxFit.cover,
          ),
        ),
            child:Align(
              alignment: Alignment.topCenter,
            child: Card(
              margin: EdgeInsets.all(20),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Today's Expenses",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    ListTile(
                      leading: Icon(Icons.fastfood),
                      title: Text("Food"),
                      trailing: Text("₹200"),
                    ),

                    ListTile(
                      leading: Icon(Icons.shopping_bag),
                      title: Text("Shopping"),
                      trailing: Text("₹500"),
                    ),
                    ListTile(
                      leading: Icon(Icons.shopping_bag),
                      title: Text("Movie"),
                      trailing: Text("₹300"),
                    ),

                  ],
                ),
              ),
            ),
            ),

      ),
    );
  }
}