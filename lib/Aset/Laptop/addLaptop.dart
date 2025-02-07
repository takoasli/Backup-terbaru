import 'dart:io';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../main.dart';
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';
import 'manajemenLaptop.dart';

class AddLaptop extends StatefulWidget {
  const AddLaptop({super.key});

  @override
  State<AddLaptop> createState() => _AddLaptopState();
}

class KebutuhanModelLaptop {
  String namaKebutuhanLaptop;
  int masaKebutuhanLaptop;
  int randomID;

  KebutuhanModelLaptop(
      this.namaKebutuhanLaptop,
      this.masaKebutuhanLaptop,
      this.randomID
      );
}
enum LaptopStatus { aktif, rusak, hilang }
LaptopStatus selectedStatus = LaptopStatus.aktif;

class _AddLaptopState extends State<AddLaptop> {
  String selectedRuangan = "";
  final merekLaptopController = TextEditingController();
  final IdLaptopController = TextEditingController();
  final CPUController = TextEditingController();
  final RamController = TextEditingController();
  final VGAController = TextEditingController();
  final ImglaptopController = TextEditingController();
  final StorageController = TextEditingController();
  final isiKebutuhan_Laptop = TextEditingController();
  final MonitorController = TextEditingController();
  final MasaKebutuhanController = TextEditingController();
  final ImagePicker _gambarLaptop = ImagePicker();
  List Kebutuhan_Laptop = [
  ];
  List<String> Ruangan = [
    "ADM FAKTURIS",
    "ADM INKASO",
    "ADM SALES",
    "ADM PRODUKSI",
    "LAB",
    "APJ",
    "DIGITAL MARKETING",
    "Ruangan EKSPOR",
    "KASIR",
    "HRD",
    "KEPALA GUDANG",
    "MANAGER MARKETING",
    "MANAGER PRODUKSI",
    "MANAGER QC-R&D",
    "MEETING",
    "STUDIO",
    "TELE SALES",
    "MANAGER EKSPORT"
  ];


  void PilihGambarLaptop() async {
    final pilihLaptop =
        await _gambarLaptop.pickImage(source: ImageSource.gallery);
    if (pilihLaptop != null) {
      setState(() {
        ImglaptopController.text = pilihLaptop.path;
      });
    }
  }

  Future<String> unggahGambarLaptop(File gambarLaptop) async {
    try {
      if (!gambarLaptop.existsSync()) {
        print('File tidak ditemukan!');
        return '';
      }
      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('Laptop')
          .child(ImglaptopController.text.split('/').last);

      UploadTask uploadLaptop = penyimpanan.putFile(gambarLaptop);
      await uploadLaptop;
      String fotoLaptop = await penyimpanan.getDownloadURL();
      return fotoLaptop;
    } catch (e) {
      print('$e');
      return '';
    }
  }

  String getStatusLaptop(LaptopStatus status) {
    switch (status) {
      case LaptopStatus.aktif:
        return 'Aktif';
      case LaptopStatus.rusak:
        return 'Rusak';
      case LaptopStatus.hilang:
        return 'Hilang';
      default:
        return '';
    }
  }

  void myAlarmFunctionLaptop() {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    print('Alarm terpicu untuk kebutuhan Laptop!');
  }

  void SimpanKebutuhan_Laptop() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_Laptop.add(KebutuhanModelLaptop(
          isiKebutuhan_Laptop.text,
          masaKebutuhan,
          randomId
        ));

        isiKebutuhan_Laptop.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => AlarmFunctionLaptop(randomId),
          exact: true,
          wakeup: true,
        );

        print('Alarm berhasil diset');
        Navigator.of(context).pop();
        // SetAlarmLaptop(Kebutuhan_Laptop.last);
      } catch (error) {
        print('Error saat mengatur alarm: $error');
        // Lakukan penanganan kesalahan jika parsing gagal
      }
    } else {
      print('Input Masa Kebutuhan tidak boleh kosong');
      // Tindakan jika input kosong
    }
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }

  void tambahKebutuhan_Laptop(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhan_Laptop,
            onAdd: SimpanKebutuhan_Laptop,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan Laptop',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  void AlarmFunctionLaptop(int id) {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Aset Laptop yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id, // Menggunakan ID yang diberikan sebagai parameter
    );
  }

  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan_Laptop.removeAt(index);
    });
  }

  void SimpanLaptop() async{
    try{
      String lokasiGambarPC = ImglaptopController.text;
      String fotoLaptop = '';
      String status = getStatusLaptop(selectedStatus);
      List<Map<String, dynamic>> ListKebutuhan_Laptop = Kebutuhan_Laptop.map((kebutuhan) {
        var timeKebutuhan = contTimeService(kebutuhan.masaKebutuhanLaptop);
        return {
          'Nama Kebutuhan Laptop': kebutuhan.namaKebutuhanLaptop,
          'Masa Kebutuhan Laptop': kebutuhan.masaKebutuhanLaptop,
          'Waktu Kebutuhan Laptop': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan Laptop': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan.randomID
        };
      }).toList();


      if (lokasiGambarPC.isNotEmpty) {
        File imgLaptop = File(lokasiGambarPC);
        fotoLaptop = await unggahGambarLaptop(imgLaptop);
      }

      await tambahLaptop(
        merekLaptopController.text.trim(),
        IdLaptopController.text.trim(),
        selectedRuangan,
        CPUController.text.trim(),
        int.parse(RamController.text.trim()),
        int.parse(StorageController.text.trim()),
        VGAController.text.trim(),
        MonitorController.text.trim(),
        ListKebutuhan_Laptop,
        fotoLaptop,
        status
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data Laptop Berhasil Ditambahkan',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManajemenLaptop()),
          );
        },
      ).show();
      print('Data Laptop Berhasil Ditambahkan');
      // myAlarmFunctionLaptop();

    } catch (e) {
      print("Error : $e");
    }
  }

  Future tambahLaptop (String merek, String ID, String selectedRuangan,
      String CPU, int ram, int storage, String vga, String monitor,List<Map<String, dynamic>> kebutuhan, String gambarLaptop,
      String status) async{
    await FirebaseFirestore.instance.collection('Laptop').add({
      'Merek Laptop' : merek,
      'ID Laptop' : ID,
      'Ruangan' : selectedRuangan,
      'CPU' : CPU,
      'RAM' : ram,
      'Kapasitas Penyimpanan' : storage,
      'VGA' : vga,
      'Ukuran Monitor' : monitor,
      'Kebutuhan Laptop' : kebutuhan,
      'Gambar Laptop' : gambarLaptop,
      'Jenis Aset' : 'Laptop',
      'Status' : status,

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Tambah Data Laptop',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          width: 370,
          height: 580,
          decoration: BoxDecoration(
            color: Warna.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Merek Laptop',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: merekLaptopController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'ID Laptop',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: IdLaptopController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Status',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                Column(
                  children: [
                    RadioListTile<LaptopStatus>(
                      title: Text('Aktif'),
                      value: LaptopStatus.aktif,
                      groupValue: selectedStatus,
                      onChanged: (LaptopStatus? value){
                        setState(() {
                          selectedStatus = value ?? LaptopStatus.aktif;
                        });
                      },
                    ),
                    RadioListTile<LaptopStatus>(
                      title: Text('Rusak'),
                      value: LaptopStatus.rusak,
                      groupValue: selectedStatus,
                      onChanged: (LaptopStatus? value){
                        setState(() {
                          selectedStatus = value ?? LaptopStatus.rusak;
                        });
                      },
                    ),
                    RadioListTile<LaptopStatus>(
                      title: Text('Hilang'),
                      value: LaptopStatus.hilang,
                      groupValue: selectedStatus,
                      onChanged: (LaptopStatus? value){
                        setState(() {
                          selectedStatus = value ?? LaptopStatus.hilang;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Ruangan',
                    style: TextStyles.title.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                DropdownSearch<String>(
                  popupProps: PopupProps.menu(
                    showSelectedItems: true,
                  ),
                  items: Ruangan,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      hintText: "Pilih Ruangan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                      )
                    ),
                  ),
                  onChanged: (selectedValue){
                    print(selectedValue);
                    setState(() {
                      selectedRuangan = selectedValue ?? "";
                    });
                  },
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'CPU',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: CPUController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'RAM (GB)',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: RamController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Storage (GB)',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: StorageController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'VGA',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: VGAController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Ukuran Layar (inch)',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: MonitorController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Gambar Laptop',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),

                FieldImage(
                    controller: ImglaptopController,
                    selectedImageName: ImglaptopController.text.isNotEmpty
                        ? ImglaptopController.text.split('/').last
                        : '',
                    onPressed: PilihGambarLaptop),
                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: Kebutuhan_Laptop.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(Kebutuhan_Laptop[index].namaKebutuhanLaptop),
                      subtitle: Text('${Kebutuhan_Laptop[index].masaKebutuhanLaptop} Bulan'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          ApusKebutuhan(index);
                        },
                        color: Colors.red,
                      ),
                    );
                  },
                ),


                InkWell(
                  onTap: tambahKebutuhan_Laptop,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Row(
                      children: [Icon(Icons.add),
                        SizedBox(width: 5),
                        Text('Tambah Kebutuhan...')],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: SimpanLaptop,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Warna.green,
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    child: Container(
                      width: 200,
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyles.title
                              .copyWith(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
