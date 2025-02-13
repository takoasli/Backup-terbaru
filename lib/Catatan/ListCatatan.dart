import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projek_skripsi/Catatan/bacaCatatan.dart';
import 'package:projek_skripsi/Catatan/moreDetailCatatan.dart';
import '../komponen/style.dart';

class ListCatatan extends StatefulWidget {
  const ListCatatan({super.key});

  @override
  State<ListCatatan> createState() => _ListCatatanState();
}

class _ListCatatanState extends State<ListCatatan> {
  late List<String> DokCatatan = [];
  List<Map<String, dynamic>> filteredCatatan = [];
  final List<String> kategoriHari = [
    'AC',
    'PC',
    'Laptop',
    'Motor',
    'Mobil'
  ];
  List<String> selectedCategories = [];

  final berhasil = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message: 'Data Catatan Servis berhasil Dihapus!',
      contentType: ContentType.success,
    ),
  );

  Future<void> getCatatan(List<String> selectedCategories) async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Catatan Servis');

    if (selectedCategories.isNotEmpty) {
      query = query.where('Jenis Aset', whereIn: selectedCategories);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    setState(() {
      DokCatatan = snapshot.docs.map((doc) => doc.id).toList();
    });
  }


  Future<void> hapusCatatan(String docServis) async {
    AwesomeDialog dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Yakin ingin menghapus?',
      desc: 'Data yang dihapus tidak dapat dikembalikan.',
      btnOkOnPress: () async {
        await FirebaseFirestore.instance.collection('Catatan Servis').doc(docServis).delete();
        getCatatan(selectedCategories);
        ScaffoldMessenger.of(context).showSnackBar(berhasil);
      },
      btnCancelOnPress: () {},
    );
    await dialog.show();
  }

  @override
  void initState(){
    super.initState();
    getCatatan(selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Manajemen Catatan',
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
        children: [
      Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(kategoriHari.length, (index) {
          return FilterChip(
            selected: selectedCategories.contains(kategoriHari[index]),
            showCheckmark: false,
            label: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(kategoriHari[index],
                style: TextStyle(
                  color: selectedCategories.contains(kategoriHari[index])
                      ? Warna.white
                      : Colors.black,
                ),
              ),
            ),
            backgroundColor: selectedCategories.contains(kategoriHari[index])
                ? Warna.lightgreen // Warna kalo dipilih
                : Warna.white, // Warna kalo tidak dipilih
            selectedColor: Warna.lightgreen, // Warna latar bela
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedCategories.clear();
                  selectedCategories.add(kategoriHari[index]);
                } else {
                  selectedCategories.remove(kategoriHari[index]);
                }
                getCatatan(selectedCategories);
              });
            },

          );
        }).toList(),
      ),
    ),


        const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Warna.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: DokCatatan.isEmpty // Periksa jika setelah filter tidak ada catatan yang ditemukan
                  ? Center(
                child: Text(
                  'Tidak ada catatan terkait aset yang dipilih',
                  style: TextStyle(
                    fontSize: 16,
                    color: Warna.black,
                    // Sesuaikan gaya teks sesuai kebutuhan
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: DokCatatan.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          DocumentSnapshot<Map<String, dynamic>> catatanDoc = await FirebaseFirestore.instance
                              .collection('Catatan Servis')
                              .doc(DokCatatan[index])
                              .get();

                          if (catatanDoc.exists) {
                            Map<String, dynamic> catatanData = catatanDoc.data() ?? {};

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailCatatan(
                                  data: catatanData,
                                ),
                              ),
                            );
                          } else {
                            // Dokumen tidak ditemukan atau kosong, handle kasus ini jika diperlukan
                            print('Dokumen tidak ditemukan');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: BacaCatatan(
                                  dokumenCatatan: DokCatatan[index],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
