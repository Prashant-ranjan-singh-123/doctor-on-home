
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChooseLocation extends StatefulWidget {

  LatLng latLng;

  ChooseLocation(this.latLng);

  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {

  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  locateMarker() async{
    final marker = Marker(
      markerId: MarkerId("curr_loc"),
      position: LatLng(widget.latLng.latitude, widget.latLng.longitude),
      infoWindow: InfoWindow(title: 'Doctor location'),
    );
    setState(() {
      _markers["Current Location"] = marker;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locateMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
          target: widget.latLng,
          zoom: 16.0,
        ),
        onTap: (latLang){
          //Toast.show(latLang.toString(), context,duration: 2);
          setState(() {
            //_getLocation(latLang);
          });
        },
        buildingsEnabled: true,
        compassEnabled: true,
        markers: _markers.values.toSet(),
      ),
    );
  }

}
