import 'package:flutter/material.dart';


class TestScreen extends StatelessWidget {
  final List<Map> myProducts =
  List.generate(100000, (index) => {"id": index, "name": "Product $index"})
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kindacode.com'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // child: GridView.builder(
        //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        //         maxCrossAxisExtent: 200,
        //         childAspectRatio: 0.75,
        //         crossAxisSpacing: 10,
        //         mainAxisSpacing: 10),
        //     itemCount: myProducts.length,
        //     itemBuilder: (BuildContext ctx, index) {
        //       return nearByGridWidget(
        //         list[index].image,
        //         list[index].name,
        //         list[index].departmentName,
        //         list[index].id,
        //       );
        //     }),
      ),
    );
  }
}