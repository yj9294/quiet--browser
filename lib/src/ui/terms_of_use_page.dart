import 'package:flutter/material.dart';

import 'ui_primitives.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Use')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: const [
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms of Use for Quiet Vault Browser',
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
                  _TermsBlock(
                    title: '1. Use of the App',
                    body:
                        'Quiet Vault Browser is provided for personal, lawful use. You may use the App to browse websites, save links, organize collections, and manage local notes for your own purposes.',
                  ),
                  _TermsBlock(
                    title: '2. Eligibility',
                    body:
                        'You must use the App in compliance with applicable laws and regulations in your jurisdiction.',
                  ),
                  _TermsBlock(
                    title: '3. User Responsibility',
                    body:
                        'You are responsible for the websites you choose to access, the content you save in the App, ensuring your use of the App complies with applicable law, and maintaining access to your own device and backups if needed.',
                  ),
                  _TermsBlock(
                    title: '4. Prohibited Conduct',
                    body:
                        'You agree not to use the App to violate any law or regulation, infringe the rights of others, store or distribute unlawful, abusive, fraudulent, or harmful content, interfere with or misuse third-party websites or services, or attempt to reverse engineer, disrupt, or abuse the App except where permitted by law.',
                  ),
                  _TermsBlock(
                    title: '5. Third-Party Content and Services',
                    body:
                        'The App may display or open third-party websites and may include third-party SDKs or services such as advertising providers. We do not control third-party content, and we are not responsible for third-party websites, services, or policies.',
                  ),
                  _TermsBlock(
                    title: '6. Advertising',
                    body:
                        'The App may present rewarded advertisements in certain usage flows. Advertising availability, timing, and delivery may vary and are not guaranteed.',
                  ),
                  _TermsBlock(
                    title: '7. Local Data',
                    body:
                        'The App is designed to store core vault content locally on your device. You are responsible for managing, reviewing, and deleting your own saved content.',
                  ),
                  _TermsBlock(
                    title: '8. No Warranty',
                    body:
                        'The App is provided on an "as is" and "as available" basis to the maximum extent permitted by law. We do not guarantee uninterrupted availability, error-free operation, or compatibility with every device, operating system version, or website.',
                  ),
                  _TermsBlock(
                    title: '9. Limitation of Liability',
                    body:
                        'To the maximum extent permitted by law, we are not liable for indirect, incidental, special, consequential, or exemplary damages arising from your use of the App, third-party websites, or third-party services.',
                  ),
                  _TermsBlock(
                    title: '10. Termination',
                    body:
                        'We may update, suspend, or discontinue features of the App at any time. You may stop using the App at any time by uninstalling it.',
                  ),
                  _TermsBlock(
                    title: '11. Changes to These Terms',
                    body:
                        'We may revise these Terms from time to time. Updated Terms will be posted at the Terms URL with a revised effective date.',
                  ),
                  _TermsBlock(
                    title: '12. Governing Law',
                    body:
                        'These Terms are governed by the laws applicable in the region where the developer operates, unless otherwise required by applicable consumer protection law.',
                  ),
                  _TermsBlock(
                    title: '13. Contact',
                    body:
                        'If you have questions about these Terms, contact: 2171858699@qq.com',
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

class _TermsBlock extends StatelessWidget {
  const _TermsBlock({required this.title, required this.body});

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
