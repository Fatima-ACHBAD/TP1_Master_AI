import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tp1_master_ai/screens/ActivityDetailPage.dart';
import 'package:tp1_master_ai/screens/AddActivityForm.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String _selectedCategory = "Toutes";
  List<String> _categories = ["Toutes"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application'),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ajout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Colors.blue),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (_tabController.index == 0) _buildCategoryDropdown(), // Afficher le filtre seulement dans l'onglet "Activités"
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Contenu de l'onglet Activités
              FutureBuilder(
                future: getActivities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else {
                    List<Map<String, dynamic>> activities =
                    snapshot.data as List<Map<String, dynamic>>;
                    return ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> activity = activities[index];
                        //récupérer l'url d'image
                        String image = activity['Image'] ?? '';
                        if (_selectedCategory == "Toutes" ||
                            activity['Catégorie'] == _selectedCategory) {
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.all(8),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActivityDetailPage(
                                      activity: activity,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity['Titre'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                            '${activity['Lieu']} - ${activity['Prix']}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  }
                },
              ),
              // Contenu de l'onglet Ajout
              AddActivityPage(),
              // Contenu de l'onglet Profil
              Text('Contenu de Profil'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButton<String>(
      value: _selectedCategory,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
      },
      items: _categories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: _getDropdownItemStyle(value),
          ),
        );
      }).toList(),
    );
  }

  TextStyle _getDropdownItemStyle(String category) {
    if (category == _selectedCategory) {
      return TextStyle(color: Colors.blue);
    } else {
      return TextStyle(color: Colors.grey);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  Future<List<Map<String, dynamic>>> getActivities() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('activities').get();

    _categories =
        querySnapshot.docs.map((doc) => doc['Catégorie'] as String).toSet().toList();
    _categories.insert(0, "Toutes");

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
