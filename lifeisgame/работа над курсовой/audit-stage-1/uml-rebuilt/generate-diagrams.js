const fs = require('fs');
const path = require('path');

const OUT = __dirname;
const WIDTH = 3000;
const HEIGHT = 1800;

const diagrams = [
  {
    file: '01-registration-authentication',
    title: 'Регистрация и вход',
    coverage: 'FR-01.01–FR-01.04; FR-02.01–FR-02.02',
    actors: [
      { id: 'user', x: 270, y: 870, label: ['Пользователь'] },
      { id: 'face', x: 2730, y: 1170, label: ['Служба Face ID', 'iOS'] },
    ],
    useCases: [
      { id: 'register', x: 1500, y: 450, lines: ['Зарегистрироваться'] },
      { id: 'password', x: 1500, y: 850, lines: ['Войти по электронной почте', 'и паролю'] },
      { id: 'faceLogin', x: 1500, y: 1250, lines: ['Войти через Face ID'] },
    ],
    associations: [['user', 'register'], ['user', 'password'], ['user', 'faceLogin'], ['face', 'faceLogin']],
  },
  {
    file: '02-user-profile',
    title: 'Профиль пользователя',
    coverage: 'FR-02.04–FR-02.08; FR-09.01',
    actors: [
      { id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] },
      { id: 'face', x: 2730, y: 380, label: ['Служба Face ID', 'iOS'] },
      { id: 'photos', x: 2730, y: 900, label: ['Служба выбора', 'изображений iOS'] },
      { id: 'notify', x: 2730, y: 1420, label: ['Служба уведомлений', 'iOS'] },
    ],
    useCases: [
      { id: 'view', x: 1500, y: 360, lines: ['Просмотреть профиль'] },
      { id: 'faceSettings', x: 1500, y: 640, lines: ['Настроить вход', 'через Face ID'] },
      { id: 'photo', x: 1500, y: 920, lines: ['Выбрать изображение', 'профиля'] },
      { id: 'notificationSettings', x: 1500, y: 1200, lines: ['Настроить уведомления'] },
      { id: 'logout', x: 1500, y: 1480, lines: ['Выйти из учётной записи'] },
    ],
    associations: [
      ['user', 'view'], ['user', 'faceSettings'], ['user', 'photo'], ['user', 'notificationSettings'], ['user', 'logout'],
      ['face', 'faceSettings'], ['photos', 'photo'], ['notify', 'notificationSettings'],
    ],
  },
  {
    file: '03-calendar-tasks',
    title: 'Календарь и управление задачами',
    coverage: 'FR-03.02–FR-03.08; FR-04.01–FR-04.03',
    actors: [
      { id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] },
      { id: 'calendar', x: 2730, y: 500, label: ['Служба календаря', 'iOS'] },
    ],
    useCases: [
      { id: 'dayPlan', x: 1500, y: 500, lines: ['Просмотреть план', 'выбранного дня'] },
      { id: 'filter', x: 1500, y: 900, lines: ['Отфильтровать элементы', 'календаря'] },
      { id: 'manage', x: 1500, y: 1300, lines: ['Управлять собственной', 'задачей'] },
    ],
    associations: [['user', 'dayPlan'], ['user', 'filter'], ['user', 'manage'], ['calendar', 'dayPlan']],
  },
  {
    file: '04-task-creation-planning',
    title: 'Создание задач, событий и автоматическое планирование',
    coverage: 'FR-05.01–FR-05.10; FR-06.01–FR-06.07; FR-07.01–FR-07.09; FR-08.01–FR-08.04',
    actors: [
      { id: 'user', x: 250, y: 900, label: ['Авторизованный', 'пользователь'] },
      { id: 'calendar', x: 2750, y: 760, label: ['Служба календаря', 'iOS'] },
    ],
    useCases: [
      { id: 'event', x: 1150, y: 390, rx: 430, lines: ['Создать событие', 'с фиксированным временем'] },
      { id: 'simple', x: 1150, y: 760, rx: 430, lines: ['Создать обычную задачу'] },
      { id: 'complex', x: 1150, y: 1250, rx: 430, lines: ['Создать сложную задачу'] },
      { id: 'plan', x: 2020, y: 760, rx: 300, lines: ['Автоматически', 'сформировать план'] },
      { id: 'subtask', x: 2020, y: 1400, rx: 300, lines: ['Добавить подзадачу'] },
    ],
    associations: [['user', 'event'], ['user', 'simple'], ['user', 'complex'], ['calendar', 'plan']],
    dependencies: [
      { from: 'simple', to: 'plan', kind: 'include', labelX: 1650, labelY: 720 },
      { from: 'complex', to: 'plan', kind: 'include', labelX: 1650, labelY: 1000 },
      { from: 'complex', to: 'subtask', kind: 'include', labelX: 1650, labelY: 1300 },
    ],
  },
  {
    file: '05-statistics',
    title: 'Общая и подробная статистика',
    coverage: 'FR-13.01–FR-13.11',
    actors: [{ id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] }],
    useCases: [
      { id: 'summary', x: 1450, y: 360, lines: ['Просмотреть сводку', 'за семь дней'] },
      { id: 'emotions', x: 1450, y: 650, lines: ['Просмотреть статистику', 'эмоций'] },
      { id: 'sleep', x: 1450, y: 940, lines: ['Просмотреть статистику сна'] },
      { id: 'tasks', x: 1450, y: 1230, lines: ['Просмотреть статистику задач'] },
      { id: 'dayTasks', x: 1900, y: 1510, rx: 470, lines: ['Просмотреть задачи', 'выбранного дня'] },
    ],
    associations: [['user', 'summary'], ['user', 'emotions'], ['user', 'sleep'], ['user', 'tasks']],
    dependencies: [
      { from: 'dayTasks', to: 'tasks', kind: 'extend', labelX: 2040, labelY: 1325, condition: '[выбран день и пользователь открывает детализацию]' },
    ],
  },
  {
    file: '06-notifications',
    title: 'Настройка и получение уведомлений',
    coverage: 'FR-09.01–FR-09.11',
    actors: [
      { id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] },
      { id: 'notify', x: 2730, y: 700, label: ['Служба уведомлений', 'iOS'] },
    ],
    useCases: [
      { id: 'settings', x: 1500, y: 480, lines: ['Настроить уведомления'] },
      { id: 'receive', x: 1500, y: 900, lines: ['Получить напоминание'] },
      { id: 'history', x: 1500, y: 1320, lines: ['Просмотреть историю', 'уведомлений'] },
    ],
    associations: [['user', 'settings'], ['user', 'receive'], ['user', 'history'], ['notify', 'settings'], ['notify', 'receive']],
  },
  {
    file: '07-emotion-sleep-diary',
    title: 'Дневник эмоций и сна',
    coverage: 'FR-10.01–FR-10.11',
    actors: [{ id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] }],
    useCases: [
      { id: 'emotion', x: 1500, y: 650, lines: ['Заполнить дневник эмоций'] },
      { id: 'sleep', x: 1500, y: 1150, lines: ['Заполнить дневник сна'] },
    ],
    associations: [['user', 'emotion'], ['user', 'sleep']],
  },
  {
    file: '08-focus-live-activity',
    title: 'Фокус-сессия и Live Activity',
    coverage: 'FR-11.01–FR-11.13',
    actors: [
      { id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] },
      { id: 'activityKit', x: 2730, y: 1100, label: ['Служба ActivityKit', 'iOS'] },
    ],
    useCases: [
      { id: 'focus', x: 1500, y: 500, lines: ['Провести фокус-сессию'] },
      { id: 'viewActivity', x: 1500, y: 930, lines: ['Просмотреть ход сессии', 'в Live Activity'] },
      { id: 'finishActivity', x: 1500, y: 1360, lines: ['Завершить задачу', 'из Live Activity'] },
    ],
    associations: [
      ['user', 'focus'], ['user', 'viewActivity'], ['user', 'finishActivity'],
      ['activityKit', 'viewActivity'], ['activityKit', 'finishActivity'],
    ],
  },
  {
    file: '09-user-state-analysis',
    title: 'Анализ состояния пользователя',
    coverage: 'FR-12.01–FR-12.11',
    actors: [
      { id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] },
      { id: 'calendar', x: 2730, y: 900, label: ['Служба календаря', 'iOS'] },
    ],
    useCases: [
      { id: 'analysis', x: 1500, y: 900, rx: 650, ry: 150, lines: ['Просмотреть анализ дня', 'и рекомендации'] },
    ],
    associations: [['user', 'analysis'], ['calendar', 'analysis']],
  },
  {
    file: '10-achievements',
    title: 'Достижения, опыт и уровни',
    coverage: 'FR-14.01–FR-14.10',
    actors: [{ id: 'user', x: 270, y: 900, label: ['Авторизованный', 'пользователь'] }],
    useCases: [
      { id: 'view', x: 1500, y: 650, lines: ['Просмотреть достижения', 'и прогресс'] },
      { id: 'open', x: 1500, y: 1150, lines: ['Открыть разблокированное', 'достижение'] },
    ],
    associations: [['user', 'view'], ['user', 'open']],
  },
];

function esc(value) {
  return String(value).replace(/[&<>"']/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&apos;' }[ch]));
}

function linePoint(a, b, radiusX = 80, radiusY = 170) {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const len = Math.hypot(dx, dy) || 1;
  return { x: a.x + dx / len * radiusX, y: a.y + dy / len * radiusY };
}

function ellipseBoundary(from, ellipse) {
  const dx = from.x - ellipse.x;
  const dy = from.y - ellipse.y;
  const rx = ellipse.rx || 560;
  const ry = ellipse.ry || 112;
  const scale = 1 / Math.sqrt((dx * dx) / (rx * rx) + (dy * dy) / (ry * ry));
  return { x: ellipse.x + dx * scale, y: ellipse.y + dy * scale };
}

function multilineText(x, y, lines, cssClass, lineHeight = 64) {
  const start = y - ((lines.length - 1) * lineHeight) / 2;
  return `<text x="${x}" y="${start}" class="${cssClass}" text-anchor="middle">${lines.map((line, i) => `<tspan x="${x}" dy="${i === 0 ? 0 : lineHeight}">${esc(line)}</tspan>`).join('')}</text>`;
}

function actorSvg(actor) {
  const { x, y } = actor;
  const labelY = y + 250;
  return `<g id="actor-${esc(actor.id)}" class="actor">
    <circle cx="${x}" cy="${y - 150}" r="55"/>
    <line x1="${x}" y1="${y - 95}" x2="${x}" y2="${y + 55}"/>
    <line x1="${x - 90}" y1="${y - 45}" x2="${x + 90}" y2="${y - 45}"/>
    <line x1="${x}" y1="${y + 55}" x2="${x - 85}" y2="${y + 175}"/>
    <line x1="${x}" y1="${y + 55}" x2="${x + 85}" y2="${y + 175}"/>
    ${multilineText(x, labelY, actor.label, 'actor-label', 58)}
  </g>`;
}

function useCaseSvg(uc) {
  const rx = uc.rx || 560;
  const ry = uc.ry || 112;
  return `<g id="uc-${esc(uc.id)}" class="use-case">
    <ellipse cx="${uc.x}" cy="${uc.y}" rx="${rx}" ry="${ry}"/>
    ${multilineText(uc.x, uc.y + 18, uc.lines, 'use-case-label', 62)}
  </g>`;
}

function associationSvg(actor, uc) {
  const actorPoint = linePoint(actor, uc, 95, 40);
  const ucPoint = ellipseBoundary(actor, uc);
  return `<line class="association" x1="${actorPoint.x.toFixed(1)}" y1="${actorPoint.y.toFixed(1)}" x2="${ucPoint.x.toFixed(1)}" y2="${ucPoint.y.toFixed(1)}"/>`;
}

function dependencySvg(dep, byId) {
  const from = byId[dep.from];
  const to = byId[dep.to];
  const start = ellipseBoundary(to, from);
  const end = ellipseBoundary(from, to);
  const relation = dep.kind === 'extend' ? '«extend»' : '«include»';
  const condition = dep.condition ? `<text x="${dep.labelX}" y="${dep.labelY + 48}" class="condition" text-anchor="middle">${esc(dep.condition)}</text>` : '';
  return `<g class="dependency">
    <line x1="${start.x.toFixed(1)}" y1="${start.y.toFixed(1)}" x2="${end.x.toFixed(1)}" y2="${end.y.toFixed(1)}" marker-end="url(#open-arrow)"/>
    <text x="${dep.labelX}" y="${dep.labelY}" class="dependency-label" text-anchor="middle">${relation}</text>
    ${condition}
  </g>`;
}

function renderSvg(diagram) {
  const byId = Object.fromEntries([...diagram.actors, ...diagram.useCases].map(item => [item.id, item]));
  const associations = diagram.associations.map(([actorId, ucId]) => associationSvg(byId[actorId], byId[ucId])).join('\n');
  const dependencies = (diagram.dependencies || []).map(dep => dependencySvg(dep, byId)).join('\n');
  const actors = diagram.actors.map(actorSvg).join('\n');
  const useCases = diagram.useCases.map(useCaseSvg).join('\n');
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${WIDTH}" height="${HEIGHT}" viewBox="0 0 ${WIDTH} ${HEIGHT}" role="img" aria-labelledby="title desc">
  <title id="title">${esc(diagram.title)}</title>
  <desc id="desc">Диаграмма вариантов использования Luma. Покрытие: ${esc(diagram.coverage)}.</desc>
  <metadata>Проект: Luma; вид UML: диаграмма вариантов использования; покрытие: ${esc(diagram.coverage)}.</metadata>
  <defs>
    <marker id="open-arrow" viewBox="0 0 18 18" refX="17" refY="9" markerWidth="18" markerHeight="18" orient="auto-start-reverse" markerUnits="userSpaceOnUse">
      <path d="M1,1 L17,9 L1,17" fill="white" stroke="black" stroke-width="2.5" stroke-linejoin="round"/>
    </marker>
    <style>
      .title { font: 700 66px Arial, Helvetica, sans-serif; fill: #000; }
      .system-boundary { fill: #fff; stroke: #000; stroke-width: 6; }
      .system-label-bg { fill: #fff; }
      .system-label { font: 700 58px Arial, Helvetica, sans-serif; fill: #000; }
      .actor circle, .actor line { fill: #fff; stroke: #000; stroke-width: 6; }
      .actor-label { font: 52px Arial, Helvetica, sans-serif; fill: #000; }
      .use-case ellipse { fill: #fff; stroke: #000; stroke-width: 6; }
      .use-case-label { font: 50px Arial, Helvetica, sans-serif; fill: #000; }
      .association { stroke: #000; stroke-width: 6; fill: none; }
      .dependency line { stroke: #000; stroke-width: 6; stroke-dasharray: 22 16; fill: none; }
      .dependency-label { font: 46px Arial, Helvetica, sans-serif; fill: #000; paint-order: stroke; stroke: #fff; stroke-width: 18; stroke-linejoin: round; }
      .condition { font: 34px Arial, Helvetica, sans-serif; fill: #000; paint-order: stroke; stroke: #fff; stroke-width: 14; stroke-linejoin: round; }
    </style>
  </defs>
  <rect x="0" y="0" width="${WIDTH}" height="${HEIGHT}" fill="#fff"/>
  <text x="1500" y="95" class="title" text-anchor="middle">${esc(diagram.title)}</text>
  <rect x="580" y="190" width="1840" height="1500" class="system-boundary"/>
  <rect x="650" y="158" width="230" height="75" class="system-label-bg"/>
  <text x="765" y="214" class="system-label" text-anchor="middle">Luma</text>
  <g id="relations">${associations}${dependencies}</g>
  <g id="elements">${useCases}${actors}</g>
</svg>`;
}

fs.mkdirSync(OUT, { recursive: true });
for (const diagram of diagrams) {
  fs.writeFileSync(path.join(OUT, `${diagram.file}.svg`), renderSvg(diagram), 'utf8');
}

const cards = diagrams.map((diagram, index) => `
  <figure>
    <img src="${diagram.file}.png" alt="${esc(diagram.title)}">
    <figcaption><strong>${String(index + 1).padStart(2, '0')}. ${esc(diagram.title)}</strong><span>${esc(diagram.coverage)}</span></figcaption>
  </figure>`).join('');

const contactSheet = `<!doctype html>
<html lang="ru"><head><meta charset="utf-8"><title>UML Luma — контактный лист</title>
<style>
  * { box-sizing: border-box; }
  html, body { margin: 0; background: white; color: black; font-family: Arial, Helvetica, sans-serif; }
  body { width: 3600px; padding: 80px; }
  h1 { margin: 0 0 54px; text-align: center; font-size: 76px; }
  main { display: grid; grid-template-columns: 1fr 1fr; gap: 54px; }
  figure { margin: 0; border: 4px solid black; padding: 20px; background: white; break-inside: avoid; }
  img { display: block; width: 100%; height: auto; background: white; }
  figcaption { display: flex; justify-content: space-between; gap: 24px; align-items: baseline; border-top: 3px solid black; padding: 20px 12px 4px; font-size: 32px; }
  figcaption span { font-size: 26px; text-align: right; }
</style></head><body><h1>Luma — диаграммы вариантов использования</h1><main>${cards}</main></body></html>`;
fs.writeFileSync(path.join(OUT, 'contact-sheet.html'), contactSheet, 'utf8');

const reportRows = [
  ['01-registration-authentication', 'FR-01.01–FR-01.04; FR-02.01–FR-02.02', 'Добавлена граница Luma; универсальная роль «Пользователь»; Face ID связан только со входом через Face ID; резервный вход оставлен альтернативой сценария.'],
  ['02-user-profile', 'FR-02.04–FR-02.08; частично FR-09.01', 'Удалён дубликат Face ID; добавлена настройка уведомлений; выбор изображения назван по ТЗ; три службы iOS вынесены за границу.'],
  ['03-calendar-tasks', 'FR-03.02–FR-03.08; FR-04.01–FR-04.03', 'Убрано неточное «подключение» календаря; служба календаря показана внешним источником только для просмотра плана; ассоциации разведены.'],
  ['04-task-creation-planning', 'FR-05; FR-06; FR-07; FR-08', 'Сохранены три корректных include; «Создать подзадачу» заменено на «Добавить подзадачу»; календарь связан только с автопланом; усилен контраст.'],
  ['05-statistics', 'FR-13.01–FR-13.11', 'Детализация выбранного дня показана как условный extend к статистике задач; четыре основных просмотра остаются целями пользователя.'],
  ['06-notifications', 'FR-09.01–FR-09.11', 'Служба уведомлений связана только с настройкой и доставкой; история остаётся внутренней целью Luma; расписания не превращены в отдельные овалы.'],
  ['07-emotion-sleep-diary', 'FR-10.01–FR-10.11', 'Актор вынесен за границу Luma; два высокоуровневых прецедента сохранены без искусственных include и без HealthKit.'],
  ['08-focus-live-activity', 'FR-11.01–FR-11.13', 'Актор исправлен на «Служба ActivityKit iOS»; удалена связь службы с фокус-сессией; оставлены связи только с двумя Live Activity-целями.'],
  ['09-user-state-analysis', 'FR-12.01–FR-12.11', 'Овал уточнён до анализа дня и рекомендаций; календарь остаётся внешним источником; внутренние хранилища не представлены акторами.'],
  ['10-achievements', 'FR-14.01–FR-14.10', 'Актор вынесен за границу; два самостоятельных пользовательских прецедента сохранены без необоснованного include.'],
];

const report = `# Перестроенные UML-диаграммы вариантов использования Luma

Все диаграммы имеют непрозрачный белый фон, чёрный текст и линии, прямоугольную границу системы с подписью **Luma**, акторов снаружи и прецеденты внутри. Ассоциации актор–прецедент выполнены сплошными линиями без стрелок; зависимости \`«include»\` и \`«extend»\` — пунктирными линиями с открытым наконечником у включаемого или базового прецедента.

| Файл (SVG и PNG) | Покрываемые FR | Основные исправления |
|---|---|---|
${reportRows.map(([file, fr, fixes]) => `| \`${file}\` | ${fr} | ${fixes} |`).join('\n')}

## Состав комплекта

- 10 редактируемых SVG-исходников размером ${WIDTH}×${HEIGHT} px.
- 10 PNG размером ${WIDTH}×${HEIGHT} px.
- \`contact-sheet.html\` и \`contact-sheet.png\` на белом фоне.
- \`generate-diagrams.js\` и \`render-diagrams.js\` для воспроизводимой сборки.

Детальные поля, проверки, интервалы, формулы и альтернативные потоки сознательно не превращены в дополнительные овалы: они относятся к текстовым сценариям из раздела 6 аудита.
`;
fs.writeFileSync(path.join(OUT, 'README.md'), report, 'utf8');

console.log(`Created ${diagrams.length} SVG files, contact-sheet.html and README.md in ${OUT}`);
