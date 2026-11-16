import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class GmailService {
  final GoogleSignInAccount googleUser;

  GmailService(this.googleUser);

  Future fetchEmails() async {
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;

    if (accessToken == null) return [];

    final url = Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=100000');
    
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final messages = data['messages'] as List? ?? [];

      List emailDetails = [];

      for (var msg in messages) {
        final details = await fetchEmailDetails(msg['id'], accessToken);
        if (details != null) {
          emailDetails.add(details);
        }
      }
      return emailDetails;
    } else {
      throw Exception('Mailler yuklenemedi');
    }
  }

  Future fetchEmailDetails(String id, String accessToken) async {
    final url = Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/$id?format=metadata&metadataHeaders=Subject&metadataHeaders=From');
    
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final headers = data['payload']['headers'] as List;

      String subject = 'Konu Yok';
      String sender = 'Bilinmeyen Gonderen';

      for (var header in headers) {
        if (header['name'] == 'Subject') subject = header['value'];
        if (header['name'] == 'From') sender = header['value'];
      }

      return {
        'id': id,
        'sender': sender,
        'subject': subject,
        'snippet': data['snippet'] ?? '',
      };
    }
    return null;
  }
}