import 'package:flutter/material.dart';
import 'main.dart';
import 'order_confirmation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState()=>_ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  String name='Wakungu Aaron Darren';
  String phone='';
  String email='';
  String address='';
  String photoUrl='';
  Future<void> editProfile() async {
    final nameC=TextEditingController(text:name), phoneC=TextEditingController(text:phone),
      emailC=TextEditingController(text:email), photoC=TextEditingController(text:photoUrl);
    final result=await showDialog<bool>(context:context,builder:(context)=>AlertDialog(
      title:const Text('Edit personal information'),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:nameC,decoration:const InputDecoration(labelText:'Full name')),
        TextField(controller:phoneC,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Phone number')),
        TextField(controller:emailC,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email')),
        TextField(controller:photoC,decoration:const InputDecoration(labelText:'Profile photo URL')),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('CANCEL')),
        FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('SAVE'))]));
    if(result==true) setState((){name=nameC.text.trim();phone=phoneC.text.trim();
      email=emailC.text.trim();photoUrl=photoC.text.trim();});
  }
  Future<void> editAddress() async {
    final c=TextEditingController(text:address);
    final result=await showDialog<bool>(context:context,builder:(context)=>AlertDialog(
      title:const Text('Delivery address'),
      content:TextField(controller:c,maxLines:3,decoration:const InputDecoration(
        hintText:'House, street, area, city',border:OutlineInputBorder())),
      actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('CANCEL')),
        FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('SAVE'))]));
    if(result==true)setState(()=>address=c.text.trim());
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('My profile'),actions:[
      IconButton(onPressed:editProfile,icon:const Icon(Icons.edit_outlined),tooltip:'Edit profile')]),
    body:ListView(padding:const EdgeInsets.all(18),children:[
      Center(child:Stack(children:[
        CircleAvatar(radius: fifty,backgroundColor:DMartApp.lime,
          backgroundImage:photoUrl.startsWith('http')?NetworkImage(photoUrl):null,
          child:photoUrl.startsWith('http')?null:const Icon(Icons.person,size:48,color:DMartApp.black)),
        Positioned(bottom:0,right:0,child:CircleAvatar(radius:17,backgroundColor:DMartApp.black,
          child:IconButton(padding:EdgeInsets.zero,onPressed:editProfile,
            icon:const Icon(Icons.camera_alt,size:17,color:Colors.white))))
      ])),
      const SizedBox(height:12),
      Center(child:Text(name.isEmpty?'Your name':name,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900))),
      Center(child:Text(email,style:const TextStyle(color:Colors.white60))),
      const SizedBox(height:22),
      Card(child:Column(children:[
        ListTile(leading:const CircleAvatar(backgroundColor:Color(0xFFC6F135),child:Icon(Icons.person_outline,color:DMartApp.black)),
          title:const Text('Personal information',style:TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text([name,phone,email].where((v)=>v.isNotEmpty).join('\n')),
          isThreeLine:true,trailing:const Icon(Icons.edit_outlined),onTap:editProfile),
        const Divider(height:1),
        ListTile(leading:const CircleAvatar(backgroundColor:Color(0xFFC6F135),child:Icon(Icons.location_on_outlined,color:DMartApp.black)),
          title:const Text('Delivery address',style:TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text(address.isEmpty?'Add your delivery address':address),
          trailing:const Icon(Icons.edit_outlined),onTap:editAddress),
        const Divider(height:1),
        ListTile(leading:const Icon(Icons.receipt_long_outlined),title:const Text('My orders'),
          trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,
            MaterialPageRoute(builder:(_)=>const OrderHistoryScreen()))),
      ])),
      const SizedBox(height:14),
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(
        color:DMartApp.black,borderRadius:BorderRadius.circular(18)),
        child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('GOOD PICKS. GOOD MOOD.',style:TextStyle(color:DMartApp.lime,fontWeight:FontWeight.w900,letterSpacing:1)),
          SizedBox(height:5),Text('Your everyday finds, all in one place.',style:TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.bold))
        ]))
    ]));
}
const double fifty=50;

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  @override Widget build(BuildContext context){
    final orders=OrderHistory.orders;
    return Scaffold(appBar:AppBar(title:const Text('My Orders')),
      body:orders.isEmpty?const Center(child:Text('No orders have been placed yet.')):
      ListView.builder(padding:const EdgeInsets.all(14),itemCount:orders.length,itemBuilder:(_,i){
        final order=orders[i];return Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.receipt_long)),
          title:Text('Order #${order.orderNumber}'),
          subtitle:Text('${order.items.length} product line(s) • ${order.date.toLocal()}'),
          trailing:Text('UGX ${order.total.toStringAsFixed(0)}',style:const TextStyle(fontWeight:FontWeight.bold))));
      }));
  }
}
