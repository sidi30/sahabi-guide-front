import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/rituals/presentation/providers/rituals_module_provider.dart';
import 'features/rituals/presentation/providers/rituals_state_manager.dart';
import 'features/rituals/presentation/pages/ritual_timeline_page.dart';
import 'features/rituals/presentation/pages/interactive_doua_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RitualsModuleProvider(
      child: MaterialApp(
        title: 'SahabiGuide - Test Rituels',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TestHomePage(),
      ),
    );
  }
}

class TestHomePage extends StatefulWidget {
  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RitualsModuleInitializer.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SahabiGuide - Test Module Rituels'),
        backgroundColor: const Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status info
            Consumer<RitualsStateManager>(
              builder: (context, stateManager, child) {
                if (stateManager.isLoading) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Chargement des données...'),
                        ],
                      ),
                    ),
                  );
                }

                if (stateManager.error != null) {
                  return Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Erreur',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(stateManager.error!),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              stateManager.loadRituals();
                              stateManager.loadDuas();
                            },
                            child: Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'État du module',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Rituels chargés: ${stateManager.rituals.length}'),
                        Text('Douas chargées: ${stateManager.duas.length}'),
                        Text('Progression: ${(stateManager.overallProgress * 100).toInt()}%'),
                        Text('Langue sélectionnée: ${stateManager.selectedLanguage}'),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Navigation buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RitualTimelinePage(),
                  ),
                );
              },
              icon: Icon(Icons.timeline),
              label: Text('Timeline des Rituels'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InteractiveDouaPage(),
                  ),
                );
              },
              icon: Icon(Icons.favorite),
              label: Text('Mes Douas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A9D8F),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            SizedBox(height: 20),

            // Language selector
            Consumer<RitualsStateManager>(
              builder: (context, stateManager, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Langue audio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                value: stateManager.selectedLanguage,
                                items: [
                                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                                  DropdownMenuItem(value: 'ha', child: Text('Haoussa')),
                                  DropdownMenuItem(value: 'za', child: Text('Zarma')),
                                  DropdownMenuItem(value: 'ar', child: Text('Arabe')),
                                ],
                                onChanged: (language) {
                                  if (language != null) {
                                    stateManager.setLanguage(language);
                                  }
                                },
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

            SizedBox(height: 20),

            // Test actions
            Consumer<RitualsStateManager>(
              builder: (context, stateManager, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions de test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => stateManager.loadRituals(),
                                child: Text('Recharger Rituels'),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => stateManager.loadDuas(),
                                child: Text('Recharger Douas'),
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
      ),
    );
  }
}
