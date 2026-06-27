import 'package:flutter/material.dart';

import 'ui_primitives.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: const [
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy for Quiet Vault Browser',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2A2333),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Effective Date: June 27, 2026',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF826E78),
                    ),
                  ),
                  SizedBox(height: 18),
                  _PolicyBlock(
                    title: '1. Overview',
                    body:
                        'Quiet Vault Browser ("the App", "we", "us", or "our") respects your privacy. This Privacy Policy explains how Quiet Vault Browser handles information when you use the app.',
                  ),
                  _PolicyBlock(
                    title: '2. Information You Create in the App',
                    body:
                        'When you use the App, you may create or save saved links and URLs, link titles, notes you write, tags and collections, quick links, and recent browsing session records within the app. This information is stored locally on your device for app functionality.',
                  ),
                  _PolicyBlock(
                    title: '3. Local Storage',
                    body:
                        'The App stores core vault data locally on your device. We do not require you to create an account to use the core features of the App.',
                  ),
                  _PolicyBlock(
                    title: '4. Browsing Content',
                    body:
                        'The App includes a built-in web browsing view. When you visit websites through the App, those websites may independently collect information from you according to their own privacy policies. We are not responsible for the privacy practices of third-party websites.',
                  ),
                  _PolicyBlock(
                    title: '5. Advertising',
                    body:
                        'The App uses a rewarded advertising feature powered by third-party advertising services, including Google AdMob. When ads are loaded or shown, third-party advertising partners may collect certain data, which may include device identifiers, diagnostics, approximate location, advertising data, or other information as described in their own policies and SDK disclosures.',
                  ),
                  _PolicyBlock(
                    title: '6. Data Sharing',
                    body:
                        'We do not sell your local vault content. We do not intentionally share your saved links, notes, tags, or collections with third parties except as necessary for third-party SDK features that are integrated into the App, such as advertising.',
                  ),
                  _PolicyBlock(
                    title: '7. Data Retention',
                    body:
                        'Data you create inside the App remains on your device until you edit or delete it, or until the App is removed from your device. Some third-party SDK related data may be handled according to the policies of those providers.',
                  ),
                  _PolicyBlock(
                    title: '8. Children’s Privacy',
                    body:
                        'The App is not directed to children under the age required by applicable law in your jurisdiction. We do not knowingly collect personal information directly from children through account registration because the App does not require account creation for core use.',
                  ),
                  _PolicyBlock(
                    title: '9. Your Choices',
                    body:
                        'You may delete saved links, notes, tags, and collections inside the App, clear recent session data inside the App, stop using the App at any time, and manage device-level privacy and advertising settings where available.',
                  ),
                  _PolicyBlock(
                    title: '10. Third-Party Services',
                    body:
                        'The App may rely on third-party services such as Google AdMob and websites you choose to open in the built-in browser. These third parties may have their own terms and privacy policies.',
                  ),
                  _PolicyBlock(
                    title: '11. Security',
                    body:
                        'We take reasonable steps to support secure handling of app data, but no method of electronic storage or transmission is completely secure.',
                  ),
                  _PolicyBlock(
                    title: '12. International Users',
                    body:
                        'If you use the App outside your home country or region, local laws may apply to your use of the App and third-party services.',
                  ),
                  _PolicyBlock(
                    title: '13. Changes to This Privacy Policy',
                    body:
                        'We may update this Privacy Policy from time to time. Updated versions will be posted at the Privacy Policy URL, and the updated effective date will be revised above.',
                  ),
                  _PolicyBlock(
                    title: '14. Contact Us',
                    body:
                        'If you have questions about this Privacy Policy, contact: 2171858699@qq.com',
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

class _PolicyBlock extends StatelessWidget {
  const _PolicyBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2A2333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF6B6376),
            ),
          ),
        ],
      ),
    );
  }
}
