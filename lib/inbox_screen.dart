import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'gmail_service.dart';
import 'main.dart';

class InboxScreen extends StatefulWidget {
  final GoogleSignInAccount googleUser;
  final GoogleSignIn googleSignIn;

  const InboxScreen({
    super.key,
    required this.googleUser,
    required this.googleSignIn,
  });

  @override
  State createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future _emailsFuture;

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  void _loadEmails() {
    final gmailService = GmailService(widget.googleUser);
    setState(() {
      _emailsFuture = gmailService.fetchEmails();
    });
  }

  Future<void> _handleSignOut() async {
    await widget.googleSignIn.disconnect();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13161C),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.mail_rounded, color: Color(0xFF3B82F6), size: 26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gelen Kutusu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(
                    widget.googleUser.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: _loadEmails,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Cikis Yap',
            onPressed: _handleSignOut,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: _emailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('Hic e-posta bulunamadi.'));
          }

          final emails = snapshot.data as List;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index];
              final sender = email['sender'].toString();
              final subject = email['subject'].toString();
              final snippet = email['snippet'].toString();
              final initial = sender.isNotEmpty ? sender.replaceAll('"', '')[0].toUpperCase() : '?';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF13161C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF3B82F6).withOpacity(0.15),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13.5),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        snippet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}