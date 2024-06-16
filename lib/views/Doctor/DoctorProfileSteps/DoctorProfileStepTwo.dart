import 'package:appcode3/en.dart';
import 'package:appcode3/views/Doctor/DoctorProfileSteps/ChooseLocation.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';

class DoctorProfileStepTwo extends StatefulWidget {
  @override
  _DoctorProfileStepTwoState createState() => _DoctorProfileStepTwoState();
}

class _DoctorProfileStepTwoState extends State<DoctorProfileStepTwo> {

  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  LatLng? _center;
  Future? getLocation;
  TextEditingController textEditingController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  locateMarker(LatLng latLng) async{
    final marker = Marker(
      markerId: MarkerId("curr_loc"),
      position: latLng,
      infoWindow: InfoWindow(title: 'Doctor location'),
    );
    setState(() {
      _markers["Current Location"] = marker;
    });

    GeoCode geoCode = GeoCode();

    final coordinates = new Coordinates(latitude: latLng.latitude, longitude: latLng.longitude);
    print(coordinates);
    var addresses = await geoCode.reverseGeocoding(
      longitude: coordinates.longitude!,
      latitude: coordinates.latitude!
    );
    var first = addresses;
    print(addresses);
    print("${first.toString()}");
    setState(() {
      // addressLine = first.addressLine;
      textEditingController.text = first.toString();
      // mapController.(CameraUpdate.newCameraPosition(CameraPosition(target: _center,zoom: 15 ))).catchError((e){
      //   Toast.show(e, context);
      // });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation = _getLocationStart();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mapController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColorLight,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    labelText: ADDRESS,
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                    ),
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
                    ),
                    //errorText: isNameError ? ENTER_NAME : null,
                  ),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14
                  ),
                  // onChanged: (val){
                  //   setState(() {
                  //     name = val;
                  //     isNameError = false;
                  //   });
                  // },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FutureBuilder(
                    future: getLocation,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ChooseLocation(_center!),
                            ));
                          },
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            //scrollGesturesEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: _center!,
                              zoom: 15.0,
                            ),
                            onTap: (latLang) {
                              //Toast.show(latLang.toString(), context,duration: 2);
                              setState(() {
                                //_getLocation(latLang);
                                _center = latLang;
                                locateMarker(_center!);
                              });
                            },
                            buildingsEnabled: true,
                            compassEnabled: true,
                            markers: _markers.values.toSet(),
                          ),
                        );
                      }
                    }
                  ),
                ),
              ),
              SizedBox(height: 70,),
            ],
          ),
        ),
    );
  }

   _getLocationStart() async {
    print('Started');
    //Toast.show("loading", context);
    // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) async{
    //   setState(() {
    //     _center = LatLng(value.latitude, value.longitude);
    //     //locateMarker(_center);
    //   });
    // })
    //     .catchError((e){
    //   Toast.show(e.toString(), context,duration: 3);
    //   print(e);
    // });

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      {
        setState(() {
          _center = LatLng(value.latitude, value.longitude);
        });
        return value;
      }
    }).catchError((e) {
      // Toast.show(e.toString(), duration: 3);
      Toast.show(e.toString());
      print(e);
    });
  }


}
