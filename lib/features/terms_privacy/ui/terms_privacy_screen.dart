import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/web_detail_wrapper.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(text, style: Theme.of(context).textTheme.headlineMedium),
    );
  }

  Widget _buildSubtitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(title: Text('Terms & Privacy')),
      body: WebDetailWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Privacy Policy Section
                _buildSectionTitle(context, 'Privacy Policy'),
                Text(
                  'Last updated: 25 May 2025',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                _buildSubtitle(context, '1. Introduction'),
                _buildParagraph(
                  context,
                  'Tackle4Loss ("we", "our", "us") provides a real-time American-Football news application currently in open beta. Your privacy matters to us. This Privacy Policy explains what limited information we collect, how we use it, and the choices you have.',
                ),

                _buildSubtitle(context, '2. Information We Do Not Collect'),
                _buildParagraph(
                  context,
                  'We do not collect any personally identifiable information ("PII") such as your name, email address, or phone number. We do not require user accounts or log-ins to use the web app.',
                ),

                _buildSubtitle(context, '3. Technical Data Processed'),
                _buildParagraph(
                  context,
                  'When you visit our site, our hosting providers (Firebase Hosting for the website and Supabase for backend services) automatically log standard technical details—IP address, browser type, and timestamps—to operate the service and detect abuse. We do not link this data to individual identities.',
                ),

                _buildSubtitle(context, '4. Cookies & Local Storage'),
                _buildParagraph(
                  context,
                  'Tackle4Loss currently uses no tracking cookies. The app may store non-personal settings (e.g., your chosen team) in your browser\'s local storage so the site remembers preferences between visits. This data never leaves your device unless you explicitly opt-in to sync features (not available in this beta).',
                ),

                _buildSubtitle(context, '5. Third-Party Services'),
                _buildParagraph(
                  context,
                  'We rely on the following third-party services:\n\n• Firebase Hosting – serves static assets over TLS and logs basic request data.\n• Supabase – provides a secure API for football news content; row-level security rules restrict data access.\n• Discord – hosts our community; if you join, you will be subject to Discord\'s separate privacy policy.',
                ),

                _buildSubtitle(context, '6. Your Rights'),
                _buildParagraph(
                  context,
                  'Because we do not store personal data, most data-protection rights (access, rectification, deletion) are not applicable. If you believe we hold personal data about you or you have privacy questions, contact us at privacy@tackle4loss.com.',
                ),

                _buildSubtitle(context, '7. Changes to This Policy'),
                _buildParagraph(
                  context,
                  'We may update this Privacy Policy as the beta evolves. Material changes will be announced on our site. The "Last updated" date at the top indicates the latest version.',
                ),

                // Terms of Service Section
                _buildSectionTitle(context, 'Terms of Service'),
                Text(
                  'Effective date: 25 May 2025',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                _buildSubtitle(context, '1. Acceptance of Terms'),
                _buildParagraph(
                  context,
                  'By accessing or using Tackle4Loss ("Service"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree, do not use the Service.',
                ),

                _buildSubtitle(context, '2. Beta Disclaimer'),
                _buildParagraph(
                  context,
                  'The Service is in an open beta phase. Features may change, break, or be removed without notice. You use the Service at your own risk.',
                ),

                _buildSubtitle(context, '3. Eligibility'),
                _buildParagraph(
                  context,
                  'You must be at least 13 years old (or the minimum digital-consent age in your jurisdiction) to use the Service.',
                ),

                _buildSubtitle(context, '4. Acceptable Use'),
                _buildParagraph(
                  context,
                  '• No scraping, reverse-engineering, or automated bulk requests.\n• No posting or transmitting malicious code.\n• No infringing or unlawful content in community channels.',
                ),

                _buildSubtitle(context, '5. Intellectual Property'),
                _buildParagraph(
                  context,
                  'All trademarks, logos, and content displayed are the property of their respective owners. Use of team names or logos does not imply affiliation with or endorsement by the NFL.',
                ),

                _buildSubtitle(context, '6. Termination'),
                _buildParagraph(
                  context,
                  'We may suspend or terminate access to the Service at any time, with or without notice, for conduct that violates these Terms or is harmful to other users or us.',
                ),

                _buildSubtitle(context, '7. Disclaimer of Warranties'),
                _buildParagraph(
                  context,
                  'The Service is provided "as is" without warranties of any kind, express or implied. We do not guarantee accuracy, availability, or fitness for a particular purpose.',
                ),

                _buildSubtitle(context, '8. Limitation of Liability'),
                _buildParagraph(
                  context,
                  'To the maximum extent permitted by law, Tackle4Loss shall not be liable for any indirect, incidental, or consequential damages arising from the use or inability to use the Service.',
                ),

                _buildSubtitle(context, '9. Changes to Terms'),
                _buildParagraph(
                  context,
                  'We may update these Terms at any time. Continued use after changes constitutes acceptance. The effective date above shows the latest revision.',
                ),

                _buildSubtitle(context, '10. Governing Law'),
                _buildParagraph(
                  context,
                  'These Terms are governed by the laws of the State of New York (USA), without regard to conflict-of-law provisions.',
                ),

                const SizedBox(height: 32),
                _buildParagraph(
                  context,
                  'Questions? Contact team@tackle4loss.com',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
