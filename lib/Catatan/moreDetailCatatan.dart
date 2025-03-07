import 'package:flutter/material.dart';
import '../Aset/ControllerLogic.dart';
import '../komponen/style.dart';

class DetailCatatan extends StatefulWidget {
  const DetailCatatan({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  State<DetailCatatan> createState() => _DetailCatatanState();
}

class _DetailCatatanState extends State<DetailCatatan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF80C5AD),
        title: Text(
          '${widget.data['ID Aset']}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              Container(
                width: 370,
                height: 100,
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.home_repair_service_outlined, size: 40),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.data['Nama Aset']}',
                          style: TextStyles.title.copyWith(fontSize: 20),
                        ),
                        Text(
                          '${widget.data['ID Aset']}',
                          style: TextStyles.body.copyWith(fontSize: 17),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'Lokasi',
                    style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: 350,
                height: 40,
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Text(
                      '${widget.data['Lokasi Aset']}',
                      style: TextStyles.body.copyWith(fontSize: 17),
                    )
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'List Kebutuhan',
                    style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.data['List Kebutuhan'].length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> kebutuhan = widget.data['List Kebutuhan'][index];
                    String namaKebutuhan = kebutuhan['Nama Kebutuhan'];
                    String statusKebutuhan = kebutuhan['status'];

                    return ListTile(
                      title: Text(namaKebutuhan),
                      subtitle: Text(statusKebutuhan),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'Biaya',
                    style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: widget.data['Catatan Biaya'].isEmpty // Periksa jika daftar biaya kosong
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Tidak ada Biaya apapun',
                      style: TextStyle(
                        fontSize: 16,
                        color: Warna.black,
                        // Sesuaikan gaya teks sesuai kebutuhan
                      ),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.data['Catatan Biaya'].length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> kebutuhan = widget.data['Catatan Biaya'][index];
                    String namaKebutuhan = kebutuhan['Nama Biaya'];
                    double hargaBiaya = kebutuhan['Harga Biaya'];

                    String hargaBiayaRupiah = convertToRupiah(hargaBiaya);

                    return ListTile(
                      title: Text(namaKebutuhan),
                      subtitle: Text(hargaBiayaRupiah),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'Catatan Tambahan',
                    style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: 350,
                height: 150,
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    '${widget.data['Catatan Tambahan']}',
                    style: TextStyles.body.copyWith(fontSize: 17),
                  )
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: 350,
                height: 40,
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Total:',
                        style: TextStyles.title.copyWith(
                          fontSize: 18,
                          color: Warna.darkgrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          convertToRupiah(widget.data['Total Biaya']),
                          style: TextStyles.title.copyWith(
                            fontSize: 18,
                            color: Warna.darkgrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
