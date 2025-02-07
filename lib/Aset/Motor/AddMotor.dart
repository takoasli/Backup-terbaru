import 'dart:io';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_skripsi/Aset/Motor/ManajemenMotor.dart';

import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../main.dart';
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';

class AddMotor extends StatefulWidget {
  const AddMotor({super.key});

  @override
  State<AddMotor> createState() => _AddMotorState();
}
class KebutuhanModelMotor {
  String namaKebutuhanMotor;
  int masaKebutuhanMotor;
  int randomID;

  KebutuhanModelMotor(
      this.namaKebutuhanMotor,
      this.masaKebutuhanMotor,
      this.randomID
      );
}

enum MotorStatus { aktif, rusak, hilang }
MotorStatus selectedStatus = MotorStatus.aktif;

class _AddMotorState extends State<AddMotor> {
  final ImagePicker _gambarMotor = ImagePicker();
  final merekMotorController = TextEditingController();
  final idMotorController = TextEditingController();
  final kapasitasMesinController = TextEditingController();
  final pendinginContorller = TextEditingController();
  final transmisiController = TextEditingController();
  final KapasitasBBController = TextEditingController();
  final KapasitasMinyakController = TextEditingController();
  final tipeAkiController = TextEditingController();
  final banDepanController = TextEditingController();
  final banBelakangController = TextEditingController();
  final isiKebutuhan_Motor = TextEditingController();
  final MasaKebutuhanController = TextEditingController();
  final ImgMotorController = TextEditingController();
  List Kebutuhan_Motor = [];


  void PilihGambarMotor() async {
    final pilihMotor =
        await _gambarMotor.pickImage(source: ImageSource.gallery);
    if (pilihMotor != null) {
      setState(() {
        ImgMotorController.text = pilihMotor.path;
      });
    }
  }

  String getStatusMotor(MotorStatus status) {
    switch (status) {
      case MotorStatus.aktif:
        return 'Aktif';
      case MotorStatus.rusak:
        return 'Rusak';
      case MotorStatus.hilang:
        return 'Hilang';
      default:
        return '';
    }
  }

  Future<String> unggahGambarMotor(File gambarMotor) async {
    try {
      if (!gambarMotor.existsSync()) {
        print('File tidak ditemukan!');
        return '';
      }
      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('Motor')
          .child(ImgMotorController.text.split('/').last);

      UploadTask uploadMotor = penyimpanan.putFile(gambarMotor);
      await uploadMotor;
      String fotoMotor = await penyimpanan.getDownloadURL();
      return fotoMotor;
    } catch (e) {
      print('$e');
      return '';
    }
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }

  void SimpanKebutuhan_Motor() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_Motor.add(KebutuhanModelMotor(
          isiKebutuhan_Motor.text,
          masaKebutuhan,
          randomId
        ));

        isiKebutuhan_Motor.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => myAlarmFunctionMotor(randomId),
          exact: true,
          wakeup: true,
        );

        print('Alarm berhasil diset');
        Navigator.of(context).pop();
      } catch (error) {
        print('Error saat mengatur alarm: $error');
        // Lakukan penanganan kesalahan jika parsing gagal
      }
    } else {
      print('Input Masa Kebutuhan tidak boleh kosong');
      // Tindakan jika input kosong
    }
  }

  void myAlarmFunctionMotor(int id) {
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Motor yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id,
    );
  }

  void tambahKebutuhan(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhan_Motor,
            onAdd: SimpanKebutuhan_Motor,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan Motor',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan_Motor.removeAt(index);
    });
  }


  void SimpanMotor() async{
    try{
      String lokasiGambarMotor = ImgMotorController.text;
      String status = getStatusMotor(selectedStatus);
      String fotoMotor = '';
      List<Map<String, dynamic>> ListKebutuhan_Motor = Kebutuhan_Motor.map((kebutuhan) {
        var timeKebutuhan = contTimeService(kebutuhan.masaKebutuhanMotor);
        return {
          'Nama Kebutuhan Motor': kebutuhan.namaKebutuhanMotor,
          'Masa Kebutuhan Motor': kebutuhan.masaKebutuhanMotor,
          'Waktu Kebutuhan Motor': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan Motor': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan.randomID
        };
      }).toList();

      if (lokasiGambarMotor.isNotEmpty) {
        File imgMotor = File(lokasiGambarMotor);
        fotoMotor = await unggahGambarMotor(imgMotor);
      }

      await tambahMotor(
        merekMotorController.text.trim(),
        idMotorController.text.trim(),
        int.parse(kapasitasMesinController.text.trim()),
        pendinginContorller.text.trim(),
        transmisiController.text.trim(),
        int.parse(KapasitasBBController.text.trim()),
        int.parse(KapasitasMinyakController.text.trim()),
        int.parse(tipeAkiController.text.trim()),
        banDepanController.text.trim(),
        banBelakangController.text.trim(),
        ListKebutuhan_Motor,
        fotoMotor,
        status,
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data Motor Berhasil Ditambahkan',
        btnOkOnPress: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ManajemenMotor()),
          );
        },
      ).show();
      print('Data Motor Berhasil Ditambahkan');

    } catch (e) {
      print("Error : $e");
    }
  }

  Future tambahMotor (String merek, String id, int kapsMesin, String pendingin,String transmisi, int kapsBB, int kapsMinyak,
      int aki, String banDpn, String banBlkng,List<Map<String, dynamic>> kebutuhan, String gambarMotor,
      String status) async{
    await FirebaseFirestore.instance.collection('Motor').add({
      'Merek Motor' : merek,
      'ID Motor' : id,
      'Kapasitas Mesin' : kapsMesin,
      'Sistem Pendingin' : pendingin,
      'Tipe Transmisi' : transmisi,
      'Kapasitas Bahan Bakar' : kapsBB,
      'Kapasitas Minyak' : kapsMinyak,
      'Tipe Aki' : aki,
      'Ban Depan' : banDpn,
      'Ban Belakang' : banBlkng,
      'Kebutuhan Motor' : kebutuhan,
      'Gambar Motor' : gambarMotor,
      'Jenis Aset' : 'Motor',
      'Lokasi' : 'Parkiran',
      'Status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Tambah Data Motor',
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
                    'Merek Motor',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: merekMotorController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'ID Motor',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: idMotorController),
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
                    RadioListTile<MotorStatus>(
                      title: Text('Aktif'),
                      value: MotorStatus.aktif,
                      groupValue: selectedStatus,
                      onChanged: (MotorStatus? value){
                        setState(() {
                          selectedStatus = value ?? MotorStatus.aktif;
                        });
                      },
                    ),
                    RadioListTile<MotorStatus>(
                      title: Text('Rusak'),
                      value: MotorStatus.rusak,
                      groupValue: selectedStatus,
                      onChanged: (MotorStatus? value){
                        setState(() {
                          selectedStatus = value ?? MotorStatus.rusak;
                        });
                      },
                    ),
                    RadioListTile<MotorStatus>(
                      title: Text('Hilang'),
                      value: MotorStatus.hilang,
                      groupValue: selectedStatus,
                      onChanged: (MotorStatus? value){
                        setState(() {
                          selectedStatus = value ?? MotorStatus.hilang;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Kapasitas Mesin (cc)',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: kapasitasMesinController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Sistem Pendingin',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: pendinginContorller),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Tipe Transmisi',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: transmisiController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Kapasitas Bahan Bakar (perliter)',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: KapasitasBBController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Kapasitas Minyak Pelumas (perliter)',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: KapasitasMinyakController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Kapasitas Aki (V)',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: tipeAkiController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Ukuran ban Depan',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: banDepanController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Ukuran ban Belakang',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: banBelakangController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Gambar Motor',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                FieldImage(
                    controller: ImgMotorController,
                    selectedImageName: ImgMotorController.text.isNotEmpty
                        ? ImgMotorController.text.split('/').last
                        : '',
                    onPressed: PilihGambarMotor),

                SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: Kebutuhan_Motor.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(Kebutuhan_Motor[index].namaKebutuhanMotor),
                      subtitle: Text('${Kebutuhan_Motor[index].masaKebutuhanMotor} Bulan'),
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
                  onTap: tambahKebutuhan,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Row(
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
                    onPressed: SimpanMotor,
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
