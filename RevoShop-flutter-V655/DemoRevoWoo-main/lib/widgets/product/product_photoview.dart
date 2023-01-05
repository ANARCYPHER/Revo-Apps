import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ProductPhotoView extends StatelessWidget {
  final image;
  final bool? isFile;
  const ProductPhotoView({Key? key, this.image, this.isFile = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isFile!
              ? Container(
                  child: PhotoView(
                  imageProvider: FileImage(image),
                ))
              : Container(
                  child: PhotoView(
                  imageProvider: NetworkImage(image),
                )),
          Positioned(
            top: 25,
            left: 15,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
