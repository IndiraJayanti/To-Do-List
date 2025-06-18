import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final Color greenText;
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.greenText,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: greenText,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Got something to plan today?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=80',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomeScreenWithStack extends StatelessWidget {
  const MyHomeScreenWithStack({super.key});

  @override
  Widget build(BuildContext context) {
    const double headerHeight = kToolbarHeight + 60;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: headerHeight - 20),
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Item ${index + 1}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeHeader(
              greenText: Colors.green,
              onProfileTap: () {
                print("Profile tapped!");
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyAppStack());
}

class MyAppStack extends StatelessWidget {
  const MyAppStack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixed Header Stack Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomeScreenWithStack(),
    );
  }
}
