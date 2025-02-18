import 'dart:async';

import 'package:flutter/material.dart';

import '../../Catatan/catatanAset.dart';
import '../../komponen/style.dart';
import '../../qrView.dart';
import '../ControllerLogic.dart';

class MoreDetailLaptop extends StatefulWidget {
  final Map<String, dynamic> data;
  const MoreDetailLaptop({super.key,
    required this.data});

  @override
  State<MoreDetailLaptop> createState() => _MoreDetailLaptopState();
}

class _MoreDetailLaptopState extends State<MoreDetailLaptop> {
  late DateTime targetDate = DateTime(2024, 2, 1);
  late Timer timer;
  double progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isBefore(targetDate)) {
        setState(() {
          progressValue = targetDate.difference(DateTime.now()).inSeconds /
              targetDate.difference(DateTime(targetDate.year, targetDate.month, 0)).inSeconds;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.data['Gambar Laptop'] ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: Text(
            '${widget.data['ID Laptop']}',
            style: TextStyles.title.copyWith(
                fontSize: 20,
                color: Warna.white
            )
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 370,
              height: 570,
              decoration: BoxDecoration(
                color: Warna.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      )
                          : Image.asset(
                        'gambar/laptop.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 30,
                      right: 30,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Warna.white,
                        ),
                        child: IconButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QRView(
                                    assetCollection: "Laptop",
                                    assetId: widget.data['ID Laptop'],
                                    assetName: widget.data['Merek Laptop'],
                                  ),
                                ));
                          },
                          icon: Icon(Icons.qr_code_2,
                              size: 33),
                        ),
                      )
                  ),
                  Positioned(
                      top: 100,
                      right: 30,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Warna.white,
                        ),
                        child: IconButton(
                          onPressed: (){
                            List<dynamic> kebutuhanLaptop = widget.data['Kebutuhan Laptop'];

                            List<String> namaKebutuhan = [];
                            for (var kebutuhan in kebutuhanLaptop) {
                              if (kebutuhan is Map<String, dynamic> && kebutuhan.containsKey('Nama Kebutuhan Laptop')) {
                                namaKebutuhan.add(kebutuhan['Nama Kebutuhan Laptop']);
                              }
                            }

                            Navigator.push(context, MaterialPageRoute(builder: (context) => Catatan(
                              List_Kebutuhan: namaKebutuhan,
                              ID_Aset: widget.data['ID Laptop'],
                              Nama_Aset: widget.data['Merek Laptop'],
                              Jenis_Aset: widget.data['Jenis Aset'],
                              lokasiAset: widget.data['Lokasi Ruangan'],)
                            )
                            );
                          },
                          icon: Icon(Icons.border_color_outlined,
                              size: 33),
                        ),
                      )
                  ),
                  Positioned(
                    top: 170,
                    child: Container(
                      width: 320,
                      height: 380,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Kebutuhan Servis',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              const SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.data['Kebutuhan Laptop'].length,
                                    itemBuilder: (context, index) {
                                      final kebutuhanLaptop = widget.data['Kebutuhan Laptop']
                                      [index]['Nama Kebutuhan Laptop'];
                                      final hariKebutuhanLaptop =
                                      widget.data['Kebutuhan Laptop'][index]
                                      ['Hari Kebutuhan Laptop'];
                                      final waktuKebutuhanLaptop =
                                      widget.data['Kebutuhan Laptop'][index]
                                      ['Waktu Kebutuhan Laptop'];

                                      final part = kebutuhanLaptop.split(': ');
                                      final hasSplit =
                                      part.length > 1 ? part[1] : kebutuhanLaptop;

                                      return SizedBox(
                                        height: 80,
                                        child: ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          title: Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              '- $hasSplit',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              showIndicator(
                                                getValueIndicator(
                                                    hariKebutuhanLaptop,
                                                    epochTimeToData(
                                                        waktuKebutuhanLaptop)),
                                                getProgressColor(
                                                    waktuKebutuhanLaptop),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    getRemainingTime(
                                                        waktuKebutuhanLaptop),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'Merek Laptop',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['Merek Laptop']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'ID laptop',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['ID Laptop']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'Lokasi Ruangan',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['Ruangan']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'CPU',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['CPU']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'RAM',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['RAM']} GB',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'Kapasitas Penyimpanan',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['Kapasitas Penyimpanan']} GB',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'VGA',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['VGA']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                  'Ukuran Monitor',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${widget.data['Ukuran Monitor']} inch',
                                style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
