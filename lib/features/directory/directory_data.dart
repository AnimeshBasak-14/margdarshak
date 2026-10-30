import 'package:flutter/material.dart';

/// "Which website do I go to?" Curated official portals by need, so people
/// who can no longer search the web still land on the right door and not on
/// a look-alike. Only central government / statutory body sites go here;
/// state-specific sites come from the scraper's source list.
class Portal {
  final String name;
  final String what; // one plain sentence: what you do here
  final String url;
  final String? tip; // e.g. a helpline

  const Portal(this.name, this.what, this.url, {this.tip});

  String get host => Uri.parse(url).host.replaceFirst('www.', '');
}

class PortalGroup {
  final String id;
  final String title;
  final IconData icon;
  final List<Portal> portals;

  const PortalGroup(this.id, this.title, this.icon, this.portals);
}

const portalGroups = [
  PortalGroup('jobs', 'Jobs and exams', Icons.work_outline_rounded, [
    Portal('UPSC', 'Civil services and central recruitment exams',
        'https://upsc.gov.in/'),
    Portal('SSC', 'CGL, CHSL, MTS and other central exams', 'https://ssc.gov.in/'),
    Portal('National Career Service', 'Job listings and career help',
        'https://www.ncs.gov.in/'),
    Portal('Employment News', 'Weekly government job advertisements',
        'https://employmentnews.gov.in/'),
  ]),
  PortalGroup('schemes', 'Schemes and benefits', Icons.volunteer_activism_outlined, [
    Portal('myScheme', 'Find schemes you qualify for by answering a few questions',
        'https://www.myscheme.gov.in/'),
    Portal('UMANG', 'Many central and state services in one place',
        'https://web.umang.gov.in/'),
    Portal('National Scholarship Portal', 'Apply for scholarships',
        'https://scholarships.gov.in/'),
    Portal('PM-KISAN', 'Income support for farmers', 'https://pmkisan.gov.in/'),
    Portal('DBT Bharat', 'Check benefits paid straight to your bank',
        'https://dbtbharat.gov.in/'),
  ]),
  PortalGroup('law', 'Law and courts', Icons.balance_rounded, [
    Portal('eCourts Services', 'Check your court case status',
        'https://services.ecourts.gov.in/'),
    Portal('India Code', 'Read any central law, free', 'https://www.indiacode.nic.in/'),
    Portal('NALSA', 'Free legal aid if you cannot afford a lawyer',
        'https://nalsa.gov.in/'),
    Portal('Tele-Law', 'Talk to a lawyer by phone or video, free for eligible people',
        'https://www.tele-law.in/'),
    Portal('Supreme Court of India', 'Judgments, cause lists and filing',
        'https://www.sci.gov.in/'),
    Portal('RTI Online', 'File a Right to Information request',
        'https://rtionline.gov.in/'),
  ]),
  PortalGroup('crime', 'Crime and safety', Icons.local_police_outlined, [
    Portal('National Cyber Crime Portal', 'Report online fraud and cyber crime',
        'https://cybercrime.gov.in/',
        tip: 'Money lost to fraud? Call 1930 right away.'),
    Portal('NCRB', 'Official crime statistics and reports', 'https://ncrb.gov.in/'),
    Portal('National Commission for Women', 'Complaints about harassment and violence',
        'https://ncw.gov.in/'),
    Portal('Consumer Helpline', 'Complain about a product or service',
        'https://consumerhelpline.gov.in/'),
  ]),
  PortalGroup('insurance', 'Insurance', Icons.shield_outlined, [
    Portal('Bima Bharosa (IRDAI)', 'Complain about an insurer and track it',
        'https://bimabharosa.irdai.gov.in/'),
    Portal('IRDAI', 'The insurance regulator: rules, licensed insurers',
        'https://irdai.gov.in/'),
    Portal('Jan Suraksha', 'Low-cost accident and life cover (PMSBY, PMJJBY)',
        'https://jansuraksha.gov.in/'),
    Portal('Insurance Ombudsman', 'Free dispute resolution for policyholders',
        'https://www.cioins.co.in/'),
    Portal('EPFO', 'Provident fund balance, claims and pension',
        'https://www.epfindia.gov.in/'),
  ]),
  PortalGroup('health', 'Health', Icons.favorite_border_rounded, [
    Portal('Ayushman Bharat (PM-JAY)', 'Check eligibility for free hospital cover',
        'https://pmjay.gov.in/'),
    Portal('ABHA Health ID', 'Create your digital health ID and records',
        'https://abha.abdm.gov.in/'),
    Portal('eSanjeevani', 'Free doctor consultation by video',
        'https://esanjeevani.mohfw.gov.in/'),
    Portal('Jan Aushadhi', 'Find low-cost generic medicine shops',
        'https://janaushadhi.gov.in/'),
    Portal('Ministry of Health', 'Health news, programmes and guidelines',
        'https://mohfw.gov.in/'),
  ]),
  PortalGroup('id', 'ID, tax and travel', Icons.badge_outlined, [
    Portal('UIDAI (Aadhaar)', 'Update or download Aadhaar', 'https://uidai.gov.in/'),
    Portal('DigiLocker', 'Keep official documents on your phone',
        'https://www.digilocker.gov.in/'),
    Portal('Passport Seva', 'Apply for or renew a passport',
        'https://www.passportindia.gov.in/'),
    Portal('Parivahan', 'Driving licence and vehicle services',
        'https://parivahan.gov.in/'),
    Portal('Income Tax', 'File returns and check refunds',
        'https://www.incometax.gov.in/'),
  ]),
];
