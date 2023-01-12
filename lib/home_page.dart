import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/custom_snackbar.dart';
import 'widgets/loading_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey globalKey = GlobalKey();
  int imageNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Convert Widget to Image"),
      ),
      body: Column(
        children: [
          RepaintBoundary(
            key: globalKey,
            child: Container(
              height: 300,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Image Number: $imageNumber",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: _save,
            child: const Text("Save Image"),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    // show loading
    LoadingDialog.loadingWithText(context);

    final String? imagePath = await _convertWidgetToImage();
    if (imagePath == null) {
      // close loading
      Navigator.pop(context);

      return;
    }

    if (!await _saveImageToGallery(imagePath: imagePath)) {
      // close loading
      Navigator.pop(context);

      return;
    }

    // close loading
    Navigator.pop(context);

    // show success snackbar
    CustomSnackbar.success(context: context, label: "Image saved at gallery");

    setState(() {
      imageNumber += 1;
    });
  }

  Future<String?> _convertWidgetToImage() async {
    try {
      // get RenderRepaintBoundary from currentContext
      RenderRepaintBoundary boundary =
          globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

      // convert RenderRepaintBoundary to raw image data
      ui.Image image = await boundary.toImage();

      // convert raw image data to ByteData
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw "error";

      // convert ByteData to Uint8List
      Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // get temporary directory using path_provider
      final Directory directory = await _getTemporaryStorage();

      // create file on relative path
      final File imagePath = File(
          "${directory.path}/image-${DateTime.now().microsecondsSinceEpoch}.png");
      
      // wirte a list of bytes to a file
      final File imageResult = await imagePath.writeAsBytes(pngBytes);

      return imageResult.path;
    } catch (_) {
      // show erro snackbar
      CustomSnackbar.error(
        context: context,
        label: "Failed convert image",
      );

      return null;
    }
  }

  Future<Directory> _getTemporaryStorage() async {
    return await getTemporaryDirectory();
  }

  Future<bool> _saveImageToGallery({required String imagePath}) async {
    try {
      // save a Image File from temporary storage to gallery
      final bool? result = await GallerySaver.saveImage(imagePath);

      if (result == null) throw "error";

      if (result != true) throw "error";

      return true;
    } catch (_) {
      // show error snackbar
      CustomSnackbar.error(
        context: context,
        label: "Failed save image at gallery",
      );

      return false;
    }
  }
}
