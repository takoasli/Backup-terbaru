import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:projek_skripsi/Aset/AC/AC.dart';
import 'package:projek_skripsi/Aset/Laptop/Laptop.dart';
import 'package:projek_skripsi/Aset/Mobil/Mobil.dart';
import 'package:projek_skripsi/Aset/Motor/Motor.dart';
import 'package:projek_skripsi/dashboard.dart';
import 'package:projek_skripsi/profile.dart';

import 'Aset/PC/PC.dart';
import 'komponen/bottomNavigation.dart';
import 'komponen/box.dart';
import 'komponen/style.dart';

class PilihInfoAset extends StatefulWidget {
  const PilihInfoAset({Key? key}) : super(key: key);

  @override
  State<PilihInfoAset> createState() => _PilihInfoAset();
}

class _PilihInfoAset extends State<PilihInfoAset> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF61BF9D),
          title: const Text(
            'Aset Info',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          elevation: 0,
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(17.0),
              child: Text(
                'Silahkan Pilih Aset',
                style: TextStyles.title.copyWith(
                  color: Warna.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Box(
                  text: 'AC',
                  warna: Warna.green,
                  gambar: 'gambar/ac.png',
                  halaman: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AC()),
                      );
                  },
                ),
                Box(
                  text: 'PC',
                  warna: Warna.green,
                  gambar: 'gambar/pc.png',
                  halaman: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PC()),
                    );
                  },
                ),
                Box(
                  text: 'Motor',
                  warna: Warna.green,
                  gambar: 'gambar/motor.png',
                  halaman: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Motor()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Box(
                      text: 'Mobil',
                      warna: Warna.green,
                      gambar: 'gambar/mobil.png',
                      halaman: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Mobil()),
                        );
                      },
                    ),

                    Box(
                        text: 'Laptop',
                        gambar: 'gambar/lepi2.png',
                        halaman: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Laptop()),
                          );
                        },
                        warna: Warna.green)
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            onPressed: () async {
              String barcode = await FlutterBarcodeScanner.scanBarcode(
                "#FF0000",
                "Cancel",
                true,
                ScanMode.QR,
              );

              print(barcode);
            },
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(
                color: Colors.green,
                width: 6.0,
                style: BorderStyle.solid,
              ),
            ),
            child: Image.asset(
              "gambar/qr_code.png",
              height: 50,
              width: 50,
            ),
          ),
        ),
        bottomNavigationBar: BottomNav(),
      ),
    );
  }
}
