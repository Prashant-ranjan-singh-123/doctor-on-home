

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' as fs;
//import 'package:stripe_payment/stripe_payment.dart';
import 'package:toast/toast.dart';

import '../en.dart';
import '../main.dart';

class MyCardDetails extends StatefulWidget {

  bool doPop;
  MyCardDetails(this.doPop);

  @override
  State<StatefulWidget> createState() {
    return MyCardDetailsState();
  }
}

class MyCardDetailsState extends State<MyCardDetails> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  // CardFieldInputDetails? _card;
  bool letItFocus = false;
  Color THEME_COLOR = Colors.cyanAccent;
  Color GREY = Colors.grey.shade500;

  //Token _paymentToken = Token();

  @override
  void initState() {
    // TODO: implement initState
    if(widget.doPop){
      justPop();
    }else{
      // Stripe.publishableKey = STRIPE_KEY;
    }
    super.initState();
  }

  justPop() async{
    await Future.delayed(Duration(milliseconds:500));
    Navigator.pop(context, true);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold();
    // return MaterialApp(
    //   //title: 'Flutter Credit Card View Demo',
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: Scaffold(
    //     resizeToAvoidBottomInset: true,
    //     body: SafeArea(
    //       child: Stack(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.all(16.0),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 SizedBox(
    //                   height: 10,
    //                 ),
    //
    //                 Container(
    //                   padding: EdgeInsets.all(16),
    //                   width: double.maxFinite,
    //                   decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.circular(15),
    //                     color: _card?.complete ?? false ? THEME_COLOR : Colors.grey.shade200,
    //                   ),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text(
    //                         "Card Number",
    //                         style: TextStyle(
    //                           color: BLACK,
    //                           fontSize: 12,
    //                         ),
    //                       ),
    //                       SizedBox(
    //                         height: 5,
    //                       ),
    //                       Text(
    //                         "XXXX XXXX XXXX ${_card?.last4 == null ? "XXXX" : _card!.last4}",
    //                         style: TextStyle(
    //                           color: GREY,
    //                           fontSize: 20,
    //                         ),
    //                       ),
    //                       SizedBox(
    //                         height: 20,
    //                       ),
    //                       Row(
    //                         children: [
    //                           Expanded(
    //                               child: Column(
    //                                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 children: [
    //                                   Text(
    //                                     "Expiration Month",
    //                                     style: TextStyle(
    //                                       color: BLACK,
    //                                       fontSize: 12,
    //                                     ),
    //                                   ),
    //                                   SizedBox(
    //                                     height: 5,
    //                                   ),
    //                                   Text(
    //                                     _card?.expiryMonth == null ? "XX" : _card!.expiryMonth.toString(),
    //                                     style: TextStyle(
    //                                       color: GREY,
    //                                       fontSize: 20,
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                           ),
    //                           Expanded(
    //                               child: Column(
    //                                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 children: [
    //                                   Text(
    //                                     "Expiration Year",
    //                                     style: TextStyle(
    //                                       color: BLACK,
    //                                       fontSize: 12,
    //                                     ),
    //                                   ),
    //                                   SizedBox(
    //                                     height: 5,
    //                                   ),
    //                                   Text(
    //                                     _card?.expiryYear == null ? "20XX" : _card!.expiryYear.toString(),
    //                                     style: TextStyle(
    //                                       color: GREY,
    //                                       fontSize: 20,
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                           ),
    //                         ],
    //                       ),
    //                       SizedBox(
    //                         height: 20,
    //                       ),
    //                       Row(
    //                         children: [
    //                           // Expanded(
    //                           //   child: Column(
    //                           //     crossAxisAlignment: CrossAxisAlignment.start,
    //                           //     children: [
    //                           //       Text(
    //                           //         "CVV",
    //                           //         style: TextStyle(
    //                           //           color: BLACK,
    //                           //           fontSize: 12,
    //                           //         ),
    //                           //       ),
    //                           //       SizedBox(
    //                           //         height: 5,
    //                           //       ),
    //                           //       Text(
    //                           //         "XXX",
    //                           //         style: TextStyle(
    //                           //           color: GREY,
    //                           //           fontSize: 20,
    //                           //         ),
    //                           //       ),
    //                           //     ],
    //                           //   ),
    //                           // ),
    //                           Expanded(
    //                             child: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 Text(
    //                                   "Brand",
    //                                   style: TextStyle(
    //                                     color: BLACK,
    //                                     fontSize: 12,
    //                                   ),
    //                                 ),
    //                                 SizedBox(
    //                                   height: 5,
    //                                 ),
    //                                 Text(
    //                                   _card?.brand == null ? "------" : _card!.brand!,
    //                                   style: TextStyle(
    //                                     color: GREY,
    //                                     fontSize: 20,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //
    //                 SizedBox(
    //                   height: 10,
    //                 ),
    //
    //                 Row(
    //                   children: [
    //                     Icon(
    //                       Icons.security,
    //                       color: THEME_COLOR,
    //                       size: 20,
    //                     ),
    //                     SizedBox(
    //                       width: 10,
    //                     ),
    //                     Text(
    //                       "Payment secured by Stripe",
    //                       style: TextStyle(
    //                         fontSize: 12
    //                       ),
    //                     ),
    //
    //                     Expanded( child: Divider( thickness: 1, indent: 10,) )
    //
    //                   ],
    //                 ),
    //
    //                 SizedBox(
    //                   height: 30,
    //                 ),
    //
    //                 Text(
    //                   "Fill in your card details",
    //                   style: TextStyle(
    //                       fontSize: 12
    //                   ),
    //                 ),
    //
    //                 CardField(
    //                   autofocus: true,
    //                   decoration: InputDecoration(
    //                     border: UnderlineInputBorder(
    //                         borderSide: BorderSide(
    //                           color: THEME_COLOR,
    //                         )
    //                     ),
    //                     enabledBorder: UnderlineInputBorder(
    //                         borderSide: BorderSide(
    //                           color: THEME_COLOR,
    //                         )
    //                     ),
    //                     focusedBorder: UnderlineInputBorder(
    //                         borderSide: BorderSide(
    //                           color: THEME_COLOR,
    //                         )
    //                     ),
    //                   ),
    //                   onCardChanged: (card) {
    //                     setState((){
    //                       _card = card;
    //                     });
    //                   },
    //
    //                 ),
    //
    //                 SizedBox(
    //                   height: 30,
    //                 ),
    //
    //                 InkWell(
    //                   onTap: (){
    //                     //Navigator.push(context, MaterialPageRoute(builder: (context) => MyCardDetails()));
    //
    //                      makePayment();
    //                   },
    //                   child: Container(
    //                     width: double.maxFinite,
    //                     decoration: BoxDecoration(
    //                       borderRadius: BorderRadius.circular(20),
    //                       color: THEME_COLOR,
    //                     ),
    //                     padding: EdgeInsets.all(12),
    //                     child: Center(
    //                       child: Text(
    //                         'Make payment',
    //                         style: TextStyle(
    //                             fontSize: 15
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //
    //               ],
    //             ),
    //           ),
    //           widget.doPop ? Container(
    //             color: THEME_COLOR,
    //             child: Center(
    //               child: CircularProgressIndicator(
    //                 color: WHITE,
    //               ),
    //             ),
    //           ) : SizedBox(),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  showdialog(String e){
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            title: Text(ALERT[LANGUAGE_TYPE],style: TextStyle(
              fontFamily: 'GlobalFonts',
              color: BLACK,
              fontWeight: FontWeight.bold,
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.toString(),style: TextStyle(
                  fontFamily: 'GlobalFonts',
                  color: BLACK,
                  fontSize: 15,
                ),)
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Retry',style: TextStyle(
                  fontFamily: 'GlobalFonts',
                  color: THEME_COLOR,
                  fontWeight: FontWeight.w900,
                ),),
              ),

            ],
          );
        }
    );
  }

  makePayment() async{
    // if(_card?.complete == true){
    //   try {
    //
    //
    //     // 2. Create payment method
    //     await Stripe.instance.createToken(
    //         CreateTokenParams(type: TokenType.Card)).then((value) {
    //       if(value.id != null){
    //         Toast.show(PROCESSING,);
    //         Navigator.pop(context, value.id);
    //       }else{
    //         errorDialog(INVALID_DETAILS);
    //       }
    //     });
    //
    //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     //     content: Text('Success: The token was created successfully!')));
    //     return;
    //   } catch (e) {
    //     errorDialog(e.toString());
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(SnackBar(content: Text('Error: $e')));
    //     rethrow;
    //   }
    // }else{
    //   errorDialog(INVALID_DETAILS[LANGUAGE_TYPE]);
    // }
  }



  errorDialog(String error){
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            title: Text(ALERT[LANGUAGE_TYPE],style:  TextStyle(
              fontFamily: 'GlobalFonts',
              color: BLACK,
              fontWeight: FontWeight.bold,
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error ,style:  TextStyle(
                  fontFamily: 'GlobalFonts',
                  color: BLACK,
                  fontSize: 15,
                ),)
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: THEME_COLOR,
                ),
                // color: THEME_COLOR,
                child: Text(YES[LANGUAGE_TYPE],style:  TextStyle(
                  fontFamily: 'GlobalFonts',
                  color: BLACK,
                  fontWeight: FontWeight.w900,
                ),),
              ),
            ],
          );
        }
    );
  }

}