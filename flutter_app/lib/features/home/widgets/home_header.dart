import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final Color greenText;
  final VoidCallback onProfileTap;
  final String? userName; // Parameter untuk nama pengguna

  const HomeHeader({
    super.key,
    required this.greenText,
    required this.onProfileTap,
    this.userName, // Ditambahkan di constructor
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName != null && userName!.isNotEmpty
                        ? 'Halo, $userName!'
                        : 'Hello!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
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
                  'https://cdn.pixabay.com/photo/2022/08/10/18/10/cat-7377822_960_720.png',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
