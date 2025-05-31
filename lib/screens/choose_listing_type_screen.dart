import 'package:flutter/material.dart';
import 'package:hanapp/screens/components/custom_button.dart';

class ChooseListingTypeScreen extends StatelessWidget {
  const ChooseListingTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Choose what you need',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF141CC9), // Dark blue from theme
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select which type of listing you want to create.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        // Navigate to the new ASAP listing details screen
                        Navigator.of(context).pushNamed('/enter_asap_listing_details');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141CC9), // Dark blue
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ASAP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'For on-demand services only. We will contact the nearest client within minutes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        // Navigate to the existing Public Listing screen
                        Navigator.of(context).pushNamed('/enter_listing_details');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141CC9), // Dark blue
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Public Listing',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Anyone can apply publicly, Anytime and Anywhere',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}