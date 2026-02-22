class FinanceCategories {
  static const income = <String>[
    'Quotas',
    'Donativos',
    'Rendas',
    'Aluguer Salão',
    'Festas/Eventos',
    'Outros',
  ];

  static const expense = <String>[
    'Géneros Alimentares',
    'Bebidas',
    'instalações/Manutenção',
    'Água',
    'Gás',
    'Eletricidade',
    'Comunicações',
    'Higiene/Limpeza',
    'Mat.Escritório',
    'Condomínio',
    'Evorapoc',
    'ZSGO',
    'Outras',
  ];

  static List<String> all = <String>{...income, ...expense}.toList();
}
