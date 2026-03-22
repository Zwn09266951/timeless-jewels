const timelessJewelTranslations: Record<string, string> = {
  'Glorious Vanity': '光彩夺目',
  'Lethal Pride': '致命的骄傲',
  'Brutal Restraint': '残酷的约束',
  'Militant Faith': '好战的信仰',
  'Elegant Hubris': '优雅的狂妄'
};

const conquerorTranslations: Record<string, string> = {
  Xibaqua: '赛巴昆',
  Zerphi: '泽佛依',
  Ahuana: '阿华纳',
  Doryani: '多里亚尼',
  Kaom: '冈姆',
  Rakiata: '拉其塔',
  Kiloava: '基洛瓦',
  Akoya: '阿寇亚',
  Deshret: '迪薛特',
  Balbala: '贝尔巴拉',
  Asenath: '安赛娜丝',
  Nasima: '纳西玛',
  Venarius: '维那留斯',
  Maxarius: '玛萨里欧斯',
  Dominus: '多米纳斯',
  Avarius: '阿瓦留斯',
  Cadiro: '卡迪罗',
  Victario: '维多里奥',
  Chitus: '切特斯',
  Caspiro: '卡斯皮罗'
};

export const selectPlaceholder = '请选择';

const buildLocalizedLabel = (translated: string | undefined, raw: string): string => {
  if (!translated || translated === raw) {
    return raw;
  }

  return `${translated} / ${raw}`;
};

export const translateTimelessJewel = (name: string): string =>
  buildLocalizedLabel(timelessJewelTranslations[name], name);

export const translateConqueror = (name: string): string => buildLocalizedLabel(conquerorTranslations[name], name);
