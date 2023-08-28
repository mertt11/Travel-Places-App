 import 'dart:convert';
 import 'package:http/http.dart' as http;

class EmailSender{
  String sendToWho;
  String nicknameOfSender; 
  String replyTo;
  String reciever;

  EmailSender(this.sendToWho,this.nicknameOfSender,this.replyTo,this.reciever);


   Future sendEmail() async {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      const serviceId = 'service_6ax2gwm';
      const templateId = 'template_s7esqnr';
      const userId = '2PV-ApeLULJAv7lDu';

      const subject='Ban';
    try{
      final response = await http.post(url,

      
      headers: {
        'origin':'http://localhost',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'sendToWho':sendToWho,//banlayacagın kisnin nickname i 
          'nicknameOfSender': nicknameOfSender,//get the admin nickname
          'subject':subject,
          'message': 'You have been banned from Travel Places App due to violation !!',
          'reply_to':'travelplacesnoreply@gmail.com',//hangi mail adresiyle mesajı göndermek istiyorsun
          'reciever':reciever,
        }
      }));
      print('Email feedback: ${response.statusCode}');
      print(response.body);

    }catch(err){
      print(err);
    }

 }
}