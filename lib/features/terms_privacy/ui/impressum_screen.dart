// File: lib/features/impressum/ui/impressum_screen.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/web_detail_wrapper.dart'; // If you want consistent styling
import 'package:url_launcher/url_launcher.dart'; // For mailto links

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});

  // --- FILL IN YOUR DETAILS HERE ---
  final String yourFullName = "Tobias Latta"; // Replace with your full name
  final String streetAndNumber =
      "Im Lindenhof 1"; // Replace with your street and number
  final String postalCodeAndCity =
      "10365 Berlin"; // Replace with your postal code and city
  final String country = "Germany"; // Your country
  final String emailAddress =
      "tobi@tackle4loss.com"; // Replace with your contact email
  final String? phoneNumber =
      null; // Optional: Replace with your phone number, e.g., "+49 123 4567890"
  // If you don't want to provide one, keep it null or an empty string
  // but check if it's strictly required for your case.

  // For a purely private, non-commercial hobby project, you might not have these:
  final String? responsibleForContentName =
      "Tobias Latta"; // Name of person responsible for content (§ 18 Abs. 2 MStV)
  final String? responsibleForContentAddress =
      "Tobias Latta, Im Lindenhof 1, 10365 Berlin"; // Their address if different

  // If it's a registered non-profit entity (e.V. - eingetragener Verein), you'd add:
  // final String? vereinName = "Tackle4Loss e.V.";
  // final String? vereinsregisterNummer = "VR 12345 Amtsgericht [Your City]";
  // final String? vertretungsberechtigterVorstand = "Vorname Nachname (Vorsitzender), ...";

  // --- END OF DETAILS TO FILL ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value, {
    bool isEmail = false,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Don't show row if value is empty
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child:
                isEmail
                    ? InkWell(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap:
                          () => launchUrl(Uri(scheme: 'mailto', path: value)),
                    )
                    : Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: Text('Impressum / Imprint'), // Bilingual title
        automaticallyImplyLeading: true,
      ),
      body: WebDetailWrapper(
        // Optional: for consistent max-width styling on web
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Impressum (Angaben gemäß § 5 TMG)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              _buildSectionTitle(context, 'Anbieter / Provider'),
              _buildDetailRow(context, 'Name', yourFullName),
              _buildDetailRow(context, 'Straße & Nr.', streetAndNumber),
              _buildDetailRow(context, 'PLZ & Ort', postalCodeAndCity),
              _buildDetailRow(context, 'Land', country),
              const SizedBox(height: 16),

              _buildSectionTitle(context, 'Kontakt / Contact'),
              _buildDetailRow(context, 'E-Mail', emailAddress, isEmail: true),
              if (phoneNumber != null && phoneNumber!.isNotEmpty)
                _buildDetailRow(context, 'Telefon', phoneNumber),
              const SizedBox(height: 16),

              // If you are a registered non-profit (e.V.), uncomment and fill these:
              // _buildSectionTitle(context, 'Vereinsinformationen / Association Information'),
              // _buildDetailRow(context, 'Vereinsname', vereinName),
              // _buildDetailRow(context, 'Registergericht & -nummer', vereinsregisterNummer),
              // _buildDetailRow(context, 'Vertretungsberechtigter Vorstand', vertretungsberechtigterVorstand),
              // const SizedBox(height: 16),
              if (responsibleForContentName != null &&
                  responsibleForContentName!.isNotEmpty) ...[
                _buildSectionTitle(
                  context,
                  'Verantwortlich für den Inhalt nach § 18 Abs. 2 MStV / Responsible for Content',
                ),
                _buildDetailRow(context, 'Name', responsibleForContentName),
                if (responsibleForContentAddress != null &&
                    responsibleForContentAddress!.isNotEmpty &&
                    responsibleForContentAddress !=
                        "$streetAndNumber, $postalCodeAndCity, $country")
                  _buildDetailRow(
                    context,
                    'Anschrift',
                    responsibleForContentAddress,
                  ),
                const SizedBox(height: 16),
              ],

              _buildSectionTitle(context, 'Haftungsausschluss / Disclaimer'),
              Text(
                'Haftung für Inhalte: Die Inhalte unserer Seiten wurden mit größter Sorgfalt erstellt. Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte können wir jedoch keine Gewähr übernehmen. Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte auf diesen Seiten nach den allgemeinen Gesetzen verantwortlich. Nach §§ 8 bis 10 TMG sind wir als Diensteanbieter jedoch nicht verpflichtet, übermittelte oder gespeicherte fremde Informationen zu überwachen oder nach Umständen zu forschen, die auf eine rechtswidrige Tätigkeit hinweisen.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Haftung für Links: Unser Angebot enthält Links zu externen Websites Dritter, auf deren Inhalte wir keinen Einfluss haben. Deshalb können wir für diese fremden Inhalte auch keine Gewähr übernehmen. Für die Inhalte der verlinkten Seiten ist stets der jeweilige Anbieter oder Betreiber der Seiten verantwortlich.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Urheberrecht: Die durch die Seitenbetreiber erstellten Inhalte und Werke auf diesen Seiten unterliegen dem deutschen Urheberrecht. Die Vervielfältigung, Bearbeitung, Verbreitung und jede Art der Verwertung außerhalb der Grenzen des Urheberrechtes bedürfen der schriftlichen Zustimmung des jeweiligen Autors bzw. Erstellers.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              Text(
                'Online-Streitbeilegung (OS-Plattform)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              InkWell(
                child: Text(
                  'Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit, die Sie hier finden: https://ec.europa.eu/consumers/odr/.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap:
                    () => launchUrl(
                      Uri.parse('https://ec.europa.eu/consumers/odr/'),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Wir sind zur Teilnahme an einem Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle weder verpflichtet noch bereit.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
