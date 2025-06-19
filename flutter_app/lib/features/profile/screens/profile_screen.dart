import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_app/graphql/query_mutation.dart';
import '../../authentication/screens/welcome_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      MyGraphQLProvider.of(context).updateToken(null);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF7),
      body: Column(
        children: [
          Query(
            options: QueryOptions(
              document: gql(meQuery),
              fetchPolicy: FetchPolicy.cacheAndNetwork,
            ),
            builder:
                (
                  QueryResult result, {
                  VoidCallback? refetch,
                  FetchMore? fetchMore,
                }) {
                  // Menampilkan header dengan teks placeholder saat loading
                  if (result.isLoading) {
                    return const ProfileHeader(
                      userName: "Memuat...",
                      userEmail: "...",
                    );
                  }

                  // Menampilkan header dengan pesan error jika gagal
                  if (result.hasException) {
                    return const ProfileHeader(
                      userName: "Gagal Memuat Data",
                      userEmail: "Coba lagi",
                    );
                  }

                  // Mengambil data jika berhasil
                  final user = result.data?['me'];
                  final String? userName = user?['name'];
                  final String? userEmail = user?['email'];

                  // Menampilkan header dengan data pengguna
                  return ProfileHeader(
                    userName: userName,
                    userEmail: userEmail,
                  );
                },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  ProfileMenuItem(
                    icon: Icons.edit,
                    title: "Edit Profile",
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: "Ganti Password",
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: "Notifikasi",
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.info_outline,
                    title: "Tentang Aplikasi",
                    onTap: () {},
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD9534F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
