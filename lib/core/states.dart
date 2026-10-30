/// States and union territories. [code] matches `state` in the scraper's
/// sources.json; "IN" means all-India (central bodies).
class IndianState {
  final String code;
  final String name;
  const IndianState(this.code, this.name);

  static const central = 'IN';

  static const all = [
    IndianState('AP', 'Andhra Pradesh'),
    IndianState('AR', 'Arunachal Pradesh'),
    IndianState('AS', 'Assam'),
    IndianState('BR', 'Bihar'),
    IndianState('CG', 'Chhattisgarh'),
    IndianState('GA', 'Goa'),
    IndianState('GJ', 'Gujarat'),
    IndianState('HR', 'Haryana'),
    IndianState('HP', 'Himachal Pradesh'),
    IndianState('JH', 'Jharkhand'),
    IndianState('KA', 'Karnataka'),
    IndianState('KL', 'Kerala'),
    IndianState('MP', 'Madhya Pradesh'),
    IndianState('MH', 'Maharashtra'),
    IndianState('MN', 'Manipur'),
    IndianState('ML', 'Meghalaya'),
    IndianState('MZ', 'Mizoram'),
    IndianState('NL', 'Nagaland'),
    IndianState('OD', 'Odisha'),
    IndianState('PB', 'Punjab'),
    IndianState('RJ', 'Rajasthan'),
    IndianState('SK', 'Sikkim'),
    IndianState('TN', 'Tamil Nadu'),
    IndianState('TG', 'Telangana'),
    IndianState('TR', 'Tripura'),
    IndianState('UP', 'Uttar Pradesh'),
    IndianState('UK', 'Uttarakhand'),
    IndianState('WB', 'West Bengal'),
    IndianState('DL', 'Delhi'),
    IndianState('JK', 'Jammu and Kashmir'),
    IndianState('LA', 'Ladakh'),
    IndianState('PY', 'Puducherry'),
    IndianState('CH', 'Chandigarh'),
    IndianState('AN', 'Andaman and Nicobar Islands'),
    IndianState('LD', 'Lakshadweep'),
    IndianState('DD', 'Dadra and Nagar Haveli and Daman and Diu'),
  ];

  static IndianState? byCode(String? code) {
    for (final s in all) {
      if (s.code == code) return s;
    }
    return null;
  }
}
