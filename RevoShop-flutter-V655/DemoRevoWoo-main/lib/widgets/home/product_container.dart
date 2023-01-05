import 'package:flutter/material.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/widgets/home/card_item_small.dart';

class ProductContainer extends StatelessWidget {
  final List<ProductModel>? products;
  const ProductContainer({Key? key, this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: ListView.separated(
        itemCount: products!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return CardItem(
            product: products![i],
            i: i,
            itemCount: products!.length,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: 5,
          );
        },
      ),
    );
  }
}
