class FinanceCategories {
  static const income = <String>[
    'Aluguer Salão',
    'Donativos',
    'Festas/Eventos',
    'Quotas',
    'Rendas',
    'Outros',
  ];

  static const expense = <String>[
    'Água',
    'Aquisição de Equipamentos',
    'Bebidas',
    'Comunicações',
    'Condomínio',
    'Eletricidade',
    'Evorapoc',
    'Gás',
    'Géneros Alimentares',
    'Higiene/Limpeza',
    'instalações/Manutenção',
    'Mat.Escritório',
    'ZSGO',
    'Outras',
  ];

  static List<String> all = <String>{...income, ...expense}.toList();
}
