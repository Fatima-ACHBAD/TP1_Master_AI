import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({Key? key}) : super(key: key);

  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  File? _image;
  List? _output;
  TextEditingController titleController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController minPersonController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  //TextEditingController imageUrlController = TextEditingController();
  // Catégorie prévue par l'IA
  TextEditingController predictedCategoryController = TextEditingController();

  Future<void> _takePhoto() async {
    // Prendre une image depuis la galerie
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        detectImage(_image!);
      });
    }
  }
  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        predictedCategoryController.text = 'Autres';
      });
    });
  }

  detectImage(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _output = prediction!;
    });

    // Mettez à jour la catégorie prévue par l'IA
    if (_output != null && _output!.isNotEmpty) {
      predictedCategoryController.text = _output![0]['label'].toString().substring(2);
      //print(predictedCategoryController.text);
    } else {
      predictedCategoryController.text = 'Autres';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Ajouter une activité'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              // GestureDetector(
              //   onTap: _takePhoto,
              //   child: _image == null
              //       ? const Text('Cliquez pour ajouter une image')
              //       : Image.file(
              //     _image!,
              //     width: 300,
              //     height: 300,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              GestureDetector(
                // Ajoutez un effet visuel lorsque l'utilisateur appuie sur l'image
                onTap: _takePhoto,
                child: _image == null
                    ? Container(
                  // Utilisez un conteneur pour ajouter des styles et des effets
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Couleur de fond gris clair
                    borderRadius: BorderRadius.circular(15.0), // Coins arrondis
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey[500], // Couleur de l'icône gris foncé
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Cliquez pour ajouter une image',
                          style: TextStyle(
                            color: Colors.grey[500], // Couleur du texte gris foncé
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ClipRRect(
                  // Utilisez ClipRRect pour rendre l'image avec des coins arrondis
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.file(
                    _image!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(height: 10),
              _output != null
                  ? Text(
                'Catégorie: ${_output![0]['label'].toString().substring(2)}',
                style: TextStyle(fontSize: 18),
              ):
              // ElevatedButton(
              //   onPressed: () {
              //     _takePhoto();
              //   },
              //   child: const Text('Sélectionner une image'),
              // )
              ElevatedButton(
                onPressed: _takePhoto,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Couleur de fond du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Coins arrondis
                  ),
                  elevation: 3.0, // Effet d'élévation pour un look tridimensionnel
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sélectionner une image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              ,
              _buildTextField('Titre', titleController),
              _buildTextField('Lieu', locationController),
              _buildTextField('Nombre de personnes', minPersonController),
              _buildTextField('Prix', priceController),
              const SizedBox(height: 20),
              //here
              _output != null
                  ? Text(
                'Confiance : ${_output![0]['confidence']}',
                style: const TextStyle(fontSize: 28),
              )
                  : const Text(''),
              ElevatedButton(
                onPressed: () {
                  // Appel de la fonction pour ajouter l'activité dans Firestore
                  addActivity();
                },
                child: const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        controller: label != 'Catégorie' ? controller : null,
        readOnly: label == 'Catégorie', // Rendre le champ "Catégorie" en lecture seule
      ),
    );
  }

  void addActivity() async {
    String title = titleController.text;
    String location = locationController.text;
    int minPerson = int.parse(minPersonController.text);
    String price = priceController.text;
    FirebaseAuth auth = FirebaseAuth.instance;
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images')
        .child('activity_image_${DateTime.now().millisecondsSinceEpoch}.png');
    //To get url
    UploadTask uploadTask = storageReference.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    if (title.isNotEmpty && location.isNotEmpty && price.isNotEmpty) {
      await FirebaseFirestore.instance.collection('activities').add({
        'Titre': title,
        'Catégorie': predictedCategoryController.text,
        'Lieu': location,
        'Nbpersomin': minPerson,
        'Prix': price,
        'Image': downloadURL,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité ajoutée'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs.'),
        ),
      );
    }
  }
}
