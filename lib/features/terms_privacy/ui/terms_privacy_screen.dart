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
      appBar: const GlobalAppBar(
        title: Text('Terms & Privacy'),
        automaticallyImplyLeading: true,
      ),
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
                  'Last updated: 29 May 2025',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                _buildSubtitle(context, '1. Introduction'),
                _buildParagraph(
                  context,
                  'Welcome to Tackle4Loss ("we", "our", "us"). We provide a real-time American Football news application. This Privacy Policy explains the limited information we process and how we use it. Your privacy is important to us.',
                ),

                _buildSubtitle(
                  context,
                  '2. Information We Collect and How We Use It',
                ),
                _buildParagraph(
                  context,
                  '\n• Personally Identifiable Information (PII): We do not directly collect PII such as your name, email address, or phone number for the general use of our application.'
                  '\n• Favorite Team & Preferences: If you choose to select a favorite team, this preference is stored locally on your device using your browser`s local storage or app`s private storage to personalize your experience. This information is not typically transmitted to our servers unless necessary for features you opt into (like push notifications).'
                  '\n• Push Notifications (FCM Tokens): If you enable push notifications and select a favorite team, we collect a device-specific token (Firebase Cloud Messaging token) provided by your device`s operating system. This token is securely stored and associated with your selected team preference solely for the purpose of sending you relevant news updates for that team. We do not link this token to any other PII. You can disable push notifications and manage your team preference at any time through your device or app settings.'
                  '\n• Technical Log Data: When you visit our website or use our application, our hosting providers (e.g., Firebase Hosting) and backend service providers (e.g., Supabase) may automatically log standard technical information. This can include your IP address, browser type, operating system, access times, and referring website addresses. This data is used for operational purposes, such as maintaining service security, diagnosing technical problems, and analyzing aggregated usage trends to improve our service. This technical data is not used to personally identify you.',
                ),

                _buildSubtitle(context, '3. Cookies and Local Storage'),
                _buildParagraph(
                  context,
                  'Tackle4Loss uses local storage on your device (browser or app) to save your preferences, such as your selected language and favorite team. We currently do not use tracking cookies for advertising or cross-site tracking. Any cookies used are strictly for essential site functionality.',
                ),

                _buildSubtitle(context, '4. Third-Party Services'),
                _buildParagraph(
                  context,
                  'We may utilize third-party services to provide and improve Tackle4Loss:'
                  '\n• Firebase: For hosting and push notifications. (Firebase Cloud Messaging) and analytics. (if implemented will be anonymized)'
                  '\n• Supabase: Used for our backend infrastructure, database, and edge functions that deliver news content.'
                  'These services have their own privacy policies, and we encourage you to review them. We are not responsible for the privacy practices of these third parties.',
                ),

                _buildSubtitle(context, '6. Data Security'),
                _buildParagraph(
                  context,
                  'We implement reasonable technical and administrative measures to protect the limited information we handle. However, no system is completely secure, and we cannot guarantee the absolute security of your information.',
                ),

                _buildSubtitle(context, '6.Your Rights and Choices'),
                _buildParagraph(
                  context,
                  '\n• Push Notifications: You can enable or disable push notifications at any time through your device`s settings or within the app (if such a setting is provided).'
                  '\n• Favorite Team: You can change or clear your favorite team selection within the app`s settings.'
                  '\n• Local Storage:  You can typically clear local storage data through your browser or app settings.'
                  '\n• Accessing Information: As we do not maintain user accounts or store extensive PII, direct requests for data access, rectification, or deletion are generally not applicable. If you have specific concerns about data you believe we might possess related to your device token for push notifications, please contact us.',
                ),

                _buildSubtitle(context, '7. Children`s Privacy'),
                _buildParagraph(
                  context,
                  'Tackle4Loss is not directed at children under the age of 13 (or the relevant minimum age in your jurisdiction). We do not knowingly collect personal information from children. If we become aware that a child has provided us with information without parental consent, we will take steps to delete such information.',
                ),

                _buildSubtitle(context, '8. Changes to This Privacy Policy'),
                _buildParagraph(
                  context,
                  'We may update this Privacy Policy from time to time as our services evolve. We will notify you of any material changes by posting the new Privacy Policy on our site or through the app and updating the "Last updated" date. Your continued use of the Service after such changes constitutes your acceptance of the new Privacy Policy.',
                ),

                _buildSubtitle(context, '9. Contact Us'),
                _buildParagraph(
                  context,
                  'If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at: privacy@tackle4loss.com',
                ),

                // Terms of Service Section
                _buildSectionTitle(context, 'Terms of Service'),
                Text(
                  'Effective date: 29 May 2025.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                _buildSubtitle(context, ''),
                _buildParagraph(
                  context,
                  'Please read these Terms of Service ("Terms") carefully before using the Tackle4Loss application and website (the "Service") operated by Tackle4Loss ("us", "we", or "our").',
                ),

                _buildSubtitle(context, '1. Acceptance of Terms'),
                _buildParagraph(
                  context,
                  'By accessing or using the Service, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service.',
                ),

                _buildSubtitle(context, '2. Beta Service'),
                _buildParagraph(
                  context,
                  'You acknowledge that the Service is currently provided as a public beta version and is undergoing testing. You understand and agree that the Service may contain bugs, errors, and other problems, and may not be complete or fully functional. We reserve the right to modify, suspend, or discontinue any part or all of the Service with or without notice at any time. You use the Service at your own risk.',
                ),

                _buildSubtitle(context, '3. Content and Intellectual Property'),
                _buildParagraph(
                  context,
                  '\n• Our Content: The news articles, summaries, analyses, and other textual content provided on Tackle4Loss (unless otherwise stated) are original works created by Tackle4Loss based on publicly available information and factual events. This original textual content is the property of Tackle4Loss.'
                  '\n• Images: Images displayed on the Service are sourced through methods intended to respect copyright, such as publicly available image searches with usage rights filters (e.g., Creative Commons) or licensed stock imagery. While we strive to use images with appropriate permissions, Tackle4Loss does not claim ownership of these images. All image copyrights remain with their respective owners. If you are an image copyright holder and believe your work is being used inappropriately, please contact us at copyright@tackle4loss.com.'
                  '\n• Third-Party Trademarks: All NFL team names, logos, and other trademarks are the property of the National Football League and its respective teams. Their use on Tackle4Loss is for informational and editorial purposes only and does not imply endorsement by or affiliation with the NFL or its teams.'
                  '\n• Attribution: When our content is based on information from specific external sources, we aim to provide appropriate attribution or links to those sources where feasible and relevant.',
                ),

                _buildSubtitle(context, '4. User Conduct'),
                _buildParagraph(
                  context,
                  'You agree not to use the Service:'
                  '\n• In any way that violates any applicable federal, state, local, or international law or regulation.'
                  '\n• To engage in any activity that interferes with or disrupts the Service (or the servers and networks which are connected to the Service).'
                  '\n• To attempt to gain unauthorized access to any portion of the Service or any other systems or networks connected to the Service.',
                ),

                _buildSubtitle(context, '5. Disclaimers'),
                _buildParagraph(
                  context,
                  '\n• No Warranty: The Service is provided on an "AS IS" and "AS AVAILABLE" basis. We make no warranties, expressed or implied, regarding the operation or availability of the Service, or the information, content, materials, or products included on the Service. To the fullest extent permissible by applicable law, we disclaim all warranties, express or implied, including, but not limited to, implied warranties of merchantability and fitness for a particular purpose.'
                  '\n• Accuracy of Information: While we strive to provide accurate and timely information, Tackle4Loss does not warrant that information on the Service is accurate, complete, reliable, current, or error-free. News content is based on information available at the time of writing and may change.'
                  '\n• No Professional Advice: The content provided on Tackle4Loss is for informational purposes only and should not be construed as professional advice (e.g., financial, legal, or betting advice).',
                ),

                _buildSubtitle(context, '6. Limitation of Liability'),
                _buildParagraph(
                  context,
                  'To the fullest extent permitted by applicable law, in no event shall Tackle4Loss, its affiliates, employees, or licensors be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the Service; (ii.g., any conduct or content of any third party on the Service; (iii) any content obtained from the Service; and (iv) unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not we have been informed of the possibility of such damage, and even if a remedy set forth herein is found to have failed of its essential purpose.',
                ),

                _buildSubtitle(context, '7. Termination'),
                _buildParagraph(
                  context,
                  'We may terminate or suspend your access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
                ),

                _buildSubtitle(context, '8. Governing Law'),
                _buildParagraph(
                  context,
                  'These Terms shall be governed by and construed in accordance with the laws of the Federal Republic of Germany. If you are a consumer, this choice of law shall not, however, deprive you of the protection afforded to you by provisions that cannot be derogated from by agreement by virtue of the law of the country where you have your habitual residence. The place of jurisdiction for all disputes arising from or in connection with these Terms shall be Berlin, provided you are a merchant, a legal entity under public law, or a special fund under public law. If you are a consumer, legal actions may be brought in either Germany or the EU country in which you reside.',
                ),

                _buildSubtitle(context, '9. Changes to Terms'),
                _buildParagraph(
                  context,
                  'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days` notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.',
                ),

                _buildSubtitle(context, '10. Contact Us'),
                _buildParagraph(
                  context,
                  'If you have any questions about these Terms, please contact us at: team@tackle4loss.com.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
