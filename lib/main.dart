import 'dart:async';
import 'dart:io';

import 'package:download_file_using_dio/constants.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(
  MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  )
);

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State < MyApp > {

  /// checking to show CircularProgressIndicator
  bool downloading = false;

  /// Display the downloaded percentage value
  String progressString = '';

  /// The path of the image downloaded to the user's phone
  String downloadedImagePath = '';

  /// Get storage premission request from user
  Future < bool > getStoragePremission() async {
    return await Permission.storage.request().isGranted;
  }

  /// Get user's phone download directory path
  Future < String > getDownloadFolderPath() async {
    return await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
  }

  /// Download image and return downloaded image path
  Future downloadFile(String downloadDirectory) async {
    Dio dio = Dio();
    var downloadedImagePath = '$downloadDirectory/image.jpg';
    try {
      await dio.download(
        imgUrl,
        downloadedImagePath,
        onReceiveProgress: (rec, total) {
          print("REC: $rec , TOTAL: $total");
          setState(() {
            downloading = true;
            progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
          });
        }
      );
    } catch (e) {
      print(e);
    }

    // Delay to show that the download is complete
    await Future.delayed(const Duration(seconds: 3));

    return downloadedImagePath;
  }
  
  /// Do download by user's click
  Future < void > doDownloadFile() async {
    if (await getStoragePremission()) {
      String downloadDirectory = await getDownloadFolderPath();
      await downloadFile(downloadDirectory).then((imagePath) {
        _diplayImage(imagePath);
      });
    }
  }
  
  /// Display image after download completed
  void _diplayImage(String downloadDirectory ) {
    setState(() {
      downloading = false;
      progressString = "COMPLETED";
      downloadedImagePath = downloadDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: downloading ?
      Center(
        child: SizedBox(
          height: 120.0,
          width: 200.0,
          child: Card(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: < Widget > [
                const CircularProgressIndicator(),
                  const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Downloading File: $progressString",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    )
              ],
            ),
          ),
        ),
      ) :
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          downloadedImagePath == '' ? Container() : Image.file(File(downloadedImagePath)),
          const SizedBox(height: 100, ),
            downloadedImagePath == '' ? MaterialButton(
              height: 50,
              child: const Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.green,
                onPressed: () => doDownloadFile()
            ) : Container()
        ],
      ),
    );
  }
}