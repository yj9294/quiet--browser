import 'package:flutter/material.dart';

import 'ui_primitives.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: const [
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiet Vault Browser Support',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2A2333),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Thank you for using Quiet Vault Browser.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF6B6376),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Quiet Vault Browser is a local-first browser and private link vault designed to help you save, organize, and revisit web pages on your device.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF6B6376),
                    ),
                  ),
                  SizedBox(height: 18),
                  _SupportBlock(
                    title: 'Support Email',
                    body: '2171858699@qq.com',
                  ),
                  _SupportBlock(
                    title: 'What We Can Help With',
                    body:
                        'App installation and launch issues\nSaving links and local storage questions\nQuick links and collections management\nRewarded ad related issues\nGeneral feedback and bug reports',
                  ),
                  _SupportBlock(
                    title: 'Response Time',
                    body: 'We aim to respond within 3-5 business days.',
                  ),
                  _SupportBlock(
                    title: 'Before Contacting Support',
                    body:
                        'Please include:\nApp name: Quiet Vault Browser\nApp version\nDevice model\niOS or Android version\nA short description of the issue',
                  ),
                  _SupportBlock(
                    title: 'Privacy',
                    body:
                        'For information about how the app handles data, please review our Privacy Policy.',
                  ),
                  _SupportBlock(
                    title: 'Terms',
                    body:
                        'For rules regarding use of the app, please review our Terms of Use.',
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

class _SupportBlock extends StatelessWidget {
  const _SupportBlock({required this.title, required this.body});

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
