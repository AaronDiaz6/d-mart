import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';
import 'products.dart';
import 'product_card.dart';
import 'categories_screen.dart';
import 'category_products_screen.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'product_details_screen.dart';
import 'nav_bar.dart';
import 'flash_sales_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState()=>_HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex=0;
  String searchText='';
  final PageController _bannerController=PageController(viewportFraction:.91);
  Timer? _bannerTimer;
  final List<Map<String,String>> banners=[
    {'title':'FRESH FITS.\nFRESH ENERGY.','tag':'NEW SEASON STYLE','category':'Fashion','image':'photo-1483985988355-763728e1935b'},
    {'title':'STEP OUT\nIN STYLE.','tag':'SNEAKERS & MORE','category':'Shoes','image':'photo-1542291026-7eec264c27ff'},
    {'title':'TECH THAT\nMOVES YOU.','tag':'SMARTER EVERYDAY','category':'Electronics','image':'photo-1498049794561-7780e7231661'},
    {'title':'A LITTLE GLOW\nGOES A LONG WAY.','tag':'BEAUTY PICKS','category':'Beauty','image':'photo-1596462502278-27bfdc403348'},
    {'title':'MAKE HOME\nFEEL LIKE YOU.','tag':'HOME ESSENTIALS','category':'Home','image':'photo-1600210492486-724fe5c67fb0'},
  ];
  @override void initState(){super.initState();_bannerTimer=Timer.periodic(const Duration(seconds:4),(_){
    if(!_bannerController.hasClients)return;
    final next=((_bannerController.page??0).round()+1)%banners.length;
    _bannerController.animateToPage(next,duration:const Duration(milliseconds:650),curve:Curves.easeInOut);
  });}
  @override void dispose(){_bannerTimer?.cancel();_bannerController.dispose();super.dispose();}

  @override Widget build(BuildContext context){
    final pages=[_homeContent(),const CategoriesScreen(),const FlashSalesScreen(),const WishlistScreen(),const CartScreen(),const ProfileScreen()];
    return Scaffold(body:SafeArea(bottom:false,child:pages[selectedIndex]),
      bottomNavigationBar:DMartNavBar(index:selectedIndex,onTap:(i)=>setState(()=>selectedIndex=i)));
  }

  String _url(String id)=>'https://images.unsplash.com/$id?auto=format&fit=crop&w=1200&q=85';
  Widget _homeContent(){
    final filtered=searchText.isEmpty?featuredProducts:products.where((p)=>p.name.toLowerCase().contains(searchText.toLowerCase())||
      p.category.toLowerCase().contains(searchText.toLowerCase())).toList();
    return CustomScrollView(slivers:[
      SliverAppBar(pinned:true,backgroundColor:DMartApp.black,foregroundColor:Colors.white,
        title:Row(children:[const Text('D-MART',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.5))]),
        actions:[IconButton(onPressed:()=>setState(()=>selectedIndex=4),icon:const Icon(Icons.shopping_cart_outlined,color:DMartApp.lime))],
        bottom:PreferredSize(preferredSize:const Size.fromHeight(68),child:Padding(
          padding:const EdgeInsets.fromLTRB(16,4,16,14),child:Container(
            decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),
              boxShadow:[BoxShadow(color:DMartApp.lime.withOpacity(.45),blurRadius:14,spreadRadius:1)]),
            child:TextField(
              onChanged:(v)=>setState(()=>searchText=v),
              decoration:InputDecoration(hintText:'Search your next favourite...',
                prefixIcon:const Icon(Icons.search),filled:true,fillColor:DMartApp.panel,
                contentPadding:EdgeInsets.zero,
                border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),
                  borderSide:const BorderSide(color:DMartApp.lime,width:1.2)),
                enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),
                  borderSide:const BorderSide(color:DMartApp.lime,width:1.2)),
                focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),
                  borderSide:const BorderSide(color:DMartApp.lime,width:2))))))),),
      SliverToBoxAdapter(child:SizedBox(height:228,child:PageView.builder(
        controller:_bannerController,itemCount:banners.length,
        itemBuilder:(context,i){final b=banners[i];return GestureDetector(
          onTap:()=>Navigator.push(context,MaterialPageRoute(
            builder:(_)=>CategoryProductsScreen(category:b['category']!))),
          child:Container(margin:const EdgeInsets.fromLTRB(0,15,12,12),
            decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),color:DMartApp.black),
            child:ClipRRect(borderRadius:BorderRadius.circular(22),child:Stack(fit:StackFit.expand,children:[
              Image.network(_url(b['image']!),fit:BoxFit.cover,
                errorBuilder:(_,__,___)=>Container(color:DMartApp.black)),
              DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
                begin:Alignment.centerLeft,end:Alignment.centerRight,
                colors:[Colors.black.withOpacity(.82),Colors.black.withOpacity(.05)]))),
              Positioned(left:20,top:22,bottom:20,right:12,child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,
                children:[Text(b['tag']!,style:const TextStyle(color:DMartApp.lime,
                  fontWeight:FontWeight.w900,fontSize:10,letterSpacing:1.5)),
                  const SizedBox(height:9),Text(b['title']!,style:const TextStyle(
                    color:Colors.white,fontSize:25,height:1.03,fontWeight:FontWeight.w900)),
                  const SizedBox(height:12),Container(padding:const EdgeInsets.symmetric(horizontal:13,vertical:8),
                    decoration:BoxDecoration(color:DMartApp.lime,borderRadius:BorderRadius.circular(20)),
                    child:const Text('EXPLORE NOW  →',style:TextStyle(fontSize:10,
                      fontWeight:FontWeight.w900,color:DMartApp.black)))]
              ))
            ]))));
        }))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,4,16,12),
        child:Row(children:[const Text('Shop the vibe',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
          const Spacer(),Text('Swipe to explore',style:TextStyle(color:Colors.white54,fontSize:11))]))),
      SliverToBoxAdapter(child:SizedBox(height:120,child:ListView.separated(
        padding:const EdgeInsets.symmetric(horizontal:16),scrollDirection:Axis.horizontal,
        itemCount:categories.length,separatorBuilder:(_,__)=>const SizedBox(width:12),
        itemBuilder:(context,i){final cat=categories[i];
          return GestureDetector(onTap:()=>Navigator.push(context,MaterialPageRoute(
            builder:(_)=>CategoryProductsScreen(category:cat))),
            child:SizedBox(width:100,child:Column(children:[
              ClipRRect(borderRadius:BorderRadius.circular(18),child:Image.network(categoryInfo.firstWhere((c)=>c.name==cat).coverUrl,
                width:100,height:82,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(
                  width:100,height:82,color:DMartApp.panel,child:const Icon(Icons.image,color:DMartApp.lime)))),
              const SizedBox(height:6),Text(cat,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12))
            ])));
        }))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,18,16,12),
        child:Row(children:[const Icon(Icons.bolt_rounded,color:DMartApp.lime),
          const Text('Flash sales',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
          const Spacer(),const FlashCountdown()]))),
      const SliverToBoxAdapter(child:Padding(padding:EdgeInsets.only(left:16),child:FlashSaleStrip(height:150))),
      SliverToBoxAdapter(child:Align(alignment:Alignment.centerRight,child:TextButton(
        onPressed:()=>setState(()=>selectedIndex=2),child:const Text('See all deals  →')))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(16,20,16,12),
        child:Row(children:[const Text('Picked for you',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
          const Spacer(),Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),
            decoration:BoxDecoration(color:DMartApp.lime,borderRadius:BorderRadius.circular(20)),
            child:const Text('HOT PICKS',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900)))]))),
      if(filtered.isEmpty)const SliverToBoxAdapter(child:Padding(padding:EdgeInsets.all(30),
        child:Center(child:Text('No products found. Try another search.'))))
      else SliverPadding(padding:const EdgeInsets.fromLTRB(14,0,14,22),
        sliver:SliverGrid(delegate:SliverChildBuilderDelegate(
          (_,i)=>ProductCard(product:filtered[i]),childCount:filtered.length),
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:2,mainAxisSpacing:13,crossAxisSpacing:13,childAspectRatio:.64))),
    ]);
  }
}
