import 'package:flutter/material.dart';
import 'package:medsystem_app/features/chat/presentation/pages/chat_page.dart';
import 'package:medsystem_app/features/auth/data/remote/auth_service.dart';
import 'package:medsystem_app/features/chat/data/remote/chat_service.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  // Services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/fondo.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Title at the top
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Chat",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Chat List
              Expanded(
                child: _builderList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _builderList() {
    return StreamBuilder(
      stream: chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Errors
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading chat list",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Data
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: snapshot.data!
              .map<Widget>((userData) => _builderListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _builderListItem(Map<String, dynamic> userData, BuildContext context) {
    // Display all users except the current user
    if (userData['email'] != authService.getCurrentUser()!.email) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverId: userData['uid'],
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white.withOpacity(0.8),
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Row(
              children: [
                // Circle Avatar
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    "assets/images/profile.jpg",
                  ),
                ),
                const SizedBox(width: 16),
                // Email Text
                Expanded(
                  child: Text(
                    userData['email'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
