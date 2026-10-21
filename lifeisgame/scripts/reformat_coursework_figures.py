from __future__ import annotations

import shutil
import tempfile
import zipfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.enum.section import WD_ORIENT, WD_SECTION
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_TAB_ALIGNMENT, WD_TAB_LEADER
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt


SOURCE = Path(
    "/Users/glebkorotkov/github/lifechange/lifeisgame/работа над курсовой/"
    "Курсовая работа Глеба Короткова — выбор технологий и архитектура.docx"
)
OUTPUT = Path(
    "/Users/glebkorotkov/github/lifechange/lifeisgame/работа над курсовой/"
    "Курсовая работа Глеба Короткова – исправления UI и оформления.docx"
)

FONT_NAME = "Times New Roman"
FONT_PATH = "/System/Library/Fonts/Supplemental/Times New Roman.ttf"


def set_run_font(run, size=14, bold=None):
    run.font.name = FONT_NAME
    run._element.rPr.rFonts.set(qn("w:eastAsia"), FONT_NAME)
    run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold


def set_para_text(paragraph, text: str, *, bold=False, size=14):
    paragraph.clear()
    run = paragraph.add_run(text)
    set_run_font(run, size=size, bold=bold)


def append_sentence(paragraph, sentence: str):
    base = paragraph.text.rstrip()
    if sentence in base:
        return
    set_para_text(paragraph, f"{base} {sentence}".strip())


def paragraph_by_start(doc: Document, start: str):
    for paragraph in doc.paragraphs:
        if paragraph.text.strip().startswith(start):
            return paragraph
    raise RuntimeError(f"Paragraph not found: {start}")


def paragraph_by_exact(doc: Document, text: str):
    for paragraph in doc.paragraphs:
        if paragraph.text.strip() == text:
            return paragraph
    raise RuntimeError(f"Paragraph not found: {text}")


def paragraph_by_contains(doc: Document, fragment: str):
    for paragraph in doc.paragraphs:
        if fragment in paragraph.text:
            return paragraph
    raise RuntimeError(f"Paragraph containing fragment not found: {fragment}")


def remove_element(element):
    parent = element.getparent()
    if parent is not None:
        parent.remove(element)


def compact_title_page(doc: Document):
    """Keep the 14 pt title page on one sheet without changing its type scale."""
    title_end = next(
        paragraph
        for paragraph in doc.paragraphs
        if paragraph.text.strip().startswith("Томск") and "2026" in paragraph.text
    )
    previous = title_end._p.getprevious()
    removed = 0
    while previous is not None and removed < 5:
        candidate = previous
        previous = previous.getprevious()
        if candidate.tag == qn("w:p") and not "".join(candidate.itertext()).strip():
            remove_element(candidate)
            removed += 1
    following = title_end._p.getnext()
    if following is not None and following.tag == qn("w:p") and following.xpath(".//w:br[@w:type='page']"):
        remove_element(following)


def remove_picture_before_caption(doc: Document, caption_text: str):
    caption = paragraph_by_exact(doc, caption_text)
    previous = caption._p.getprevious()
    while previous is not None:
        if previous.xpath(".//w:drawing") or previous.xpath(".//w:pict"):
            remove_element(previous)
            break
        previous = previous.getprevious()
    remove_element(caption._p)


def remove_picture_between(doc: Document, before_start: str, after_start: str):
    before = paragraph_by_start(doc, before_start)
    after = paragraph_by_start(doc, after_start)
    node = before._p.getnext()
    while node is not None and node is not after._p:
        nxt = node.getnext()
        if node.xpath(".//w:drawing") or node.xpath(".//w:pict"):
            remove_element(node)
        node = nxt


def style_body_paragraph(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    paragraph.paragraph_format.first_line_indent = Cm(1.25)
    paragraph.paragraph_format.line_spacing = 1.5
    paragraph.paragraph_format.space_after = Pt(0)
    for run in paragraph.runs:
        set_run_font(run, size=14)


def style_figure_paragraph(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    paragraph.paragraph_format.first_line_indent = Cm(0)
    paragraph.paragraph_format.space_before = Pt(6)
    paragraph.paragraph_format.space_after = Pt(0)
    paragraph.paragraph_format.keep_with_next = True


def style_caption(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    paragraph.paragraph_format.first_line_indent = Cm(0)
    paragraph.paragraph_format.line_spacing = 1.0
    paragraph.paragraph_format.space_before = Pt(3)
    paragraph.paragraph_format.space_after = Pt(6)
    paragraph.paragraph_format.keep_together = True
    for run in paragraph.runs:
        set_run_font(run, size=14)


def iter_text_paragraphs(doc: Document):
    for paragraph in doc.paragraphs:
        yield paragraph
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for paragraph in cell.paragraphs:
                    yield paragraph
    for section in doc.sections:
        for container in (
            section.header,
            section.first_page_header,
            section.even_page_header,
            section.footer,
            section.first_page_footer,
            section.even_page_footer,
        ):
            for paragraph in container.paragraphs:
                yield paragraph
            for table in container.tables:
                for row in table.rows:
                    for cell in row.cells:
                        for paragraph in cell.paragraphs:
                            yield paragraph


def add_picture_to_paragraph(paragraph, image_path: Path, max_width_cm: float, max_height_cm: float):
    with Image.open(image_path) as image:
        width_px, height_px = image.size
    ratio = width_px / height_px
    width_cm = max_width_cm
    height_cm = width_cm / ratio
    if height_cm > max_height_cm:
        height_cm = max_height_cm
        width_cm = height_cm * ratio
    run = paragraph.add_run()
    run.add_picture(str(image_path), width=Cm(width_cm), height=Cm(height_cm))
    style_figure_paragraph(paragraph)


def insert_figure_before_table(doc: Document, table, image_path: Path, caption: str,
                               max_width_cm=15.0, max_height_cm=17.5):
    picture = doc.add_paragraph()
    add_picture_to_paragraph(picture, image_path, max_width_cm, max_height_cm)
    caption_p = doc.add_paragraph()
    set_para_text(caption_p, caption)
    style_caption(caption_p)
    table._tbl.addprevious(picture._p)
    table._tbl.addprevious(caption_p._p)
    remove_element(table._tbl)


def insert_figure_before_paragraph(doc: Document, anchor, image_path: Path, caption: str,
                                   max_width_cm=15.0, max_height_cm=17.5):
    picture = doc.add_paragraph()
    add_picture_to_paragraph(picture, image_path, max_width_cm, max_height_cm)
    caption_p = doc.add_paragraph()
    set_para_text(caption_p, caption)
    style_caption(caption_p)
    anchor._p.addprevious(picture._p)
    anchor._p.addprevious(caption_p._p)


def insert_figure_after_paragraph(doc: Document, anchor, image_path: Path, caption: str,
                                  max_width_cm=15.0, max_height_cm=17.5):
    picture = doc.add_paragraph()
    add_picture_to_paragraph(picture, image_path, max_width_cm, max_height_cm)
    caption_p = doc.add_paragraph()
    set_para_text(caption_p, caption)
    style_caption(caption_p)
    anchor._p.addnext(caption_p._p)
    anchor._p.addnext(picture._p)


def make_composite(paths: list[Path], labels: list[str], output: Path, columns: int,
                   cell_width: int, image_height: int, font_size: int = 42):
    font = ImageFont.truetype(FONT_PATH, font_size)
    rows = (len(paths) + columns - 1) // columns
    label_height = font_size * 2 + 28
    margin = 36
    canvas = Image.new(
        "RGB",
        (columns * cell_width + (columns + 1) * margin,
         rows * (image_height + label_height) + (rows + 1) * margin),
        "white",
    )
    draw = ImageDraw.Draw(canvas)
    for index, (path, label) in enumerate(zip(paths, labels)):
        row, column = divmod(index, columns)
        x = margin + column * (cell_width + margin)
        y = margin + row * (image_height + label_height + margin)
        with Image.open(path) as source:
            image = source.convert("RGB")
            scale = min(cell_width / image.width, image_height / image.height)
            resized = image.resize(
                (max(1, int(image.width * scale)), max(1, int(image.height * scale))),
                Image.Resampling.LANCZOS,
            )
        image_x = x + (cell_width - resized.width) // 2
        image_y = y + (image_height - resized.height) // 2
        canvas.paste(resized, (image_x, image_y))
        bbox = draw.multiline_textbbox((0, 0), label, font=font, align="center", spacing=5)
        text_width = bbox[2] - bbox[0]
        draw.multiline_text(
            (x + (cell_width - text_width) / 2, y + image_height + 10),
            label,
            fill="black",
            font=font,
            align="center",
            spacing=5,
        )
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, quality=95)


def configure_section(section, landscape=False):
    if landscape:
        section.orientation = WD_ORIENT.LANDSCAPE
        section.page_width = Cm(29.7)
        section.page_height = Cm(21.0)
    else:
        section.orientation = WD_ORIENT.PORTRAIT
        section.page_width = Cm(21.0)
        section.page_height = Cm(29.7)
    section.left_margin = Cm(3.0)
    section.right_margin = Cm(1.5)
    section.top_margin = Cm(2.0)
    section.bottom_margin = Cm(2.0)
    section.header_distance = Cm(1.0)
    section.footer_distance = Cm(1.0)


def add_page_number(footer):
    paragraph = footer.paragraphs[0] if footer.paragraphs else footer.add_paragraph()
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    paragraph.clear()
    run = paragraph.add_run()
    set_run_font(run, size=14)
    begin = OxmlElement("w:fldChar")
    begin.set(qn("w:fldCharType"), "begin")
    instr = OxmlElement("w:instrText")
    instr.set(qn("xml:space"), "preserve")
    instr.text = " PAGE "
    separate = OxmlElement("w:fldChar")
    separate.set(qn("w:fldCharType"), "separate")
    text = OxmlElement("w:t")
    text.text = "1"
    end = OxmlElement("w:fldChar")
    end.set(qn("w:fldCharType"), "end")
    run._r.extend([begin, instr, separate, text, end])


def add_appendix_heading(doc: Document, letter: str, title: str):
    label = doc.add_paragraph()
    set_para_text(label, f"ПРИЛОЖЕНИЕ {letter}", bold=True)
    label.alignment = WD_ALIGN_PARAGRAPH.CENTER
    label.paragraph_format.first_line_indent = Cm(0)
    label.paragraph_format.space_after = Pt(6)
    label.paragraph_format.keep_with_next = True
    title_p = doc.add_paragraph()
    set_para_text(title_p, title, bold=True)
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_p.paragraph_format.first_line_indent = Cm(0)
    title_p.paragraph_format.space_after = Pt(12)
    title_p.paragraph_format.keep_with_next = True


def add_appendix_figure(doc: Document, image_path: Path, caption: str,
                        *, max_width_cm=25.0, max_height_cm=14.2, page_break=False):
    if page_break:
        spacer = doc.add_paragraph()
        spacer.paragraph_format.page_break_before = True
    picture = doc.add_paragraph()
    add_picture_to_paragraph(picture, image_path, max_width_cm, max_height_cm)
    caption_p = doc.add_paragraph()
    set_para_text(caption_p, caption)
    style_caption(caption_p)


def replace_toc(doc: Document):
    entries = [
        ("ВВЕДЕНИЕ", 3, 0),
        ("1 Анализ предметной области", 5, 0),
        ("1.1 Особенности планирования задач с учётом состояния пользователя", 5, 1),
        ("1.2 Анализ приложений-аналогов", 7, 1),
        ("1.3 Нефункциональные требования", 9, 1),
        ("1.4 Функциональные возможности приложения", 12, 1),
        ("1.5 Модель предметной области", 19, 1),
        ("2 Проектирование", 21, 0),
        ("2.1 Выбор платформы и средств разработки", 21, 1),
        ("2.2 Архитектурный подход", 23, 1),
        ("2.3 Хранение данных и системные интеграции", 25, 1),
        ("2.4 Проектирование пользовательского интерфейса", 27, 1),
        ("3 Реализация и проверка приложения", 29, 0),
        ("3.1 Учётная запись, профиль и сессия", 29, 1),
        ("3.2 Календарь и управление элементами", 33, 1),
        ("3.3 Автоматическое планирование и граница 23:00", 35, 1),
        ("3.4 Уведомления и дневник", 39, 1),
        ("3.5 Фокус-сессия и Live Activity", 42, 1),
        ("3.6 Анализ дня, статистика и достижения", 43, 1),
        ("3.7 Пользовательское исследование восприятия интерфейса", 49, 1),
        ("ЗАКЛЮЧЕНИЕ", 54, 0),
        ("СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ И ЛИТЕРАТУРЫ", 55, 0),
        ("ПРИЛОЖЕНИЕ А", 61, 0),
        ("ПРИЛОЖЕНИЕ Б", 64, 0),
    ]
    body = doc.element.body
    toc = next((child for child in body.iterchildren() if child.tag == qn("w:sdt")), None)
    if toc is None:
        raise RuntimeError("TOC content control not found")
    for title, page, level in entries:
        paragraph = doc.add_paragraph()
        if level:
            paragraph.paragraph_format.left_indent = Cm(0.75)
        paragraph.paragraph_format.first_line_indent = Cm(0)
        paragraph.paragraph_format.line_spacing = 1.0
        paragraph.paragraph_format.space_before = Pt(0)
        paragraph.paragraph_format.space_after = Pt(0)
        paragraph.paragraph_format.tab_stops.add_tab_stop(
            Cm(16.0), alignment=WD_TAB_ALIGNMENT.RIGHT, leader=WD_TAB_LEADER.DOTS
        )
        run = paragraph.add_run(f"{title}\t{page}")
        set_run_font(run, size=14)
        toc.addprevious(paragraph._p)
    body.remove(toc)


def main():
    build_dir = Path(tempfile.mkdtemp(prefix="luma-coursework-"))
    media_dir = build_dir / "media"
    media_dir.mkdir(parents=True)
    with zipfile.ZipFile(SOURCE) as archive:
        for name in archive.namelist():
            if name.startswith("word/media/") and not name.endswith("/"):
                target = media_dir / Path(name).name
                with archive.open(name) as src, target.open("wb") as dst:
                    shutil.copyfileobj(src, dst)

    def media(number: int) -> Path:
        for suffix in ("png", "jpg", "jpeg"):
            candidate = media_dir / f"image{number}.{suffix}"
            if candidate.exists():
                return candidate
        raise RuntimeError(f"Missing image {number}")

    composites = build_dir / "composites"
    ui_components = composites / "ui-components.png"
    authentication = composites / "authentication.png"
    calendar = composites / "calendar.png"
    split_task = composites / "split-task.png"
    statistics_screens = composites / "statistics-screens.png"

    make_composite(
        [media(12), media(13), media(14), media(15)],
        ["а) MetricSliderCard", "б) CustomButton", "в) CustomTabBar", "г) CustomTextField"],
        ui_components, columns=2, cell_width=900, image_height=330, font_size=42,
    )
    make_composite(
        [media(16), media(17), media(18)],
        ["а) вход через Face ID", "б) авторизация", "в) регистрация"],
        authentication, columns=3, cell_width=520, image_height=1040, font_size=38,
    )
    make_composite(
        [media(22), media(23)],
        ["а) календарь", "б) задачи в процессе"],
        calendar, columns=2, cell_width=620, image_height=1120, font_size=42,
    )
    make_composite(
        [media(26), media(27)],
        ["а) предложение разделить задачу", "б) сформированный план"],
        split_task, columns=2, cell_width=620, image_height=1120, font_size=38,
    )
    make_composite(
        [media(38), media(39), media(40)],
        ["а) эмоции", "б) задачи", "в) сон"],
        statistics_screens, columns=3, cell_width=520, image_height=1040, font_size=38,
    )

    doc = Document(SOURCE)
    original_tables = list(doc.tables)
    if len(original_tables) < 17:
        raise RuntimeError(f"Expected at least 17 tables, got {len(original_tables)}")

    p = paragraph_by_start(doc, "UIKit выбран основным UI")
    set_para_text(
        p,
        "UIKit выбран основным UI–фреймворком благодаря императивной модели построения интерфейса. "
        "Она предоставляет явное управление жизненным циклом UIViewController, иерархией UIView, "
        "ограничениями Auto Layout, обработкой событий и моментом обновления отдельных элементов. "
        "Такой уровень контроля необходим для форм с многоэтапной проверкой, календаря с нестандартной "
        "компоновкой, повторно используемых компонентов и координаторной навигации. Поэтому UIKit "
        "обеспечивает предсказуемое поведение сложных экранов и соответствует выбранной архитектуре MVVM-C.",
    )

    p = paragraph_by_start(doc, "SwiftUI применён точечно")
    set_para_text(
        p,
        "SwiftUI выбран для двух изолированных интерфейсов, отображение которых определяется текущим "
        "состоянием: экрана достижений и Live Activity. На экране достижений состав карточек и доступные "
        "действия зависят от состояний locked, unlocked и opened; декларативное связывание данных с "
        "представлением уменьшает объём кода ручной синхронизации. Интерфейс Live Activity является "
        "расширением WidgetKit и формируется средствами SwiftUI в соответствии с моделью ActivityKit "
        "[33; 34; 41]. Экран достижений встраивается в существующую UIKit-навигацию через "
        "UIHostingController, поэтому применение SwiftUI не требует изменения координаторов и остальных "
        "экранов. Таким образом, разделение фреймворков основано на характере интерфейсов и требованиях "
        "системных API.",
    )

    # Replace editorial placeholders and introduce every illustration before it appears.
    p = paragraph_by_start(doc, "Для приложения выбран MVVM-C")
    set_para_text(
        p,
        "Для приложения выбран MVVM-C с сервисным и репозиторным слоями. Подход разделяет "
        "отображение, состояние экрана, навигацию, прикладные операции и хранение данных. "
        "Общая схема взаимодействия компонентов представлена на рисунке 2.1.",
    )

    p = paragraph_by_start(doc, "Требования к автономной работе")
    append_sentence(p, "Модель локального хранилища представлена на рисунке 2.2.")
    remove_picture_between(doc, "Требования к автономной работе", "Выбор Core Data связан")
    core_data_anchor = paragraph_by_start(doc, "Выбор Core Data связан")
    insert_figure_before_paragraph(
        doc, core_data_anchor, media(11),
        "Рисунок 2.2 – Модель локального хранилища Core Data",
        max_width_cm=15.0, max_height_cm=17.0,
    )

    p = paragraph_by_start(doc, "Повторяющиеся элементы вынесены")
    append_sentence(p, "Примеры повторно используемых элементов интерфейса приведены на рисунке 2.3.")
    insert_figure_before_table(
        doc, original_tables[1], ui_components,
        "Рисунок 2.3 – Повторно используемые элементы пользовательского интерфейса",
        max_width_cm=15.0, max_height_cm=12.5,
    )

    p = paragraph_by_start(doc, "Техническое задание предусматривает регистрацию")
    append_sentence(p, "Основные экраны данного сценария показаны на рисунке 3.1.")
    insert_figure_before_table(
        doc, original_tables[2], authentication,
        "Рисунок 3.1 – Экраны входа через Face ID, авторизации и регистрации",
        max_width_cm=15.0, max_height_cm=17.5,
    )
    p = paragraph_by_start(doc, "Формы регистрации и входа реализованы")
    append_sentence(p, "Сценарий включения биометрического входа представлен на рисунке 3.2.")
    insert_figure_before_table(
        doc, original_tables[3], media(19),
        "Рисунок 3.2 – Включение входа через Face ID",
        max_width_cm=15.0, max_height_cm=17.5,
    )
    remove_element(original_tables[4]._tbl)
    p = paragraph_by_start(doc, "Состояние входа хранит SessionManager")
    append_sentence(
        p,
        "Последовательность авторизации с помощью Face ID представлена на рисунке А.1 приложения А.",
    )
    p = paragraph_by_start(doc, "Листинг показывает распределение ответственности")
    set_para_text(
        p,
        "Распределение ответственности построено следующим образом: ViewModel обрабатывает действие "
        "экрана, AuthService задаёт сценарий входа и преобразует ошибку, а UserRepository выполняет "
        "поиск пользователя и проверку хеша.",
    )

    remove_element(original_tables[5]._tbl)
    p = paragraph_by_start(doc, "Техническое задание задаёт пять основных разделов")
    append_sentence(
        p,
        "Последовательность взаимодействия с системным календарём приведена на рисунке А.2 приложения А.",
    )
    p = paragraph_by_start(doc, "В качестве ключевого свидетельства")
    set_para_text(
        p,
        "Экран календаря, на котором отображаются выбранная дата, дневной прогресс, фильтр и состояние "
        "задач, приведён на рисунке 3.3.",
    )
    insert_figure_before_table(
        doc, original_tables[6], calendar,
        "Рисунок 3.3 – Календарь и отображение задач в процессе",
        max_width_cm=14.0, max_height_cm=18.0,
    )

    p = paragraph_by_start(doc, "Техническое задание определяет три создаваемых вида")
    append_sentence(
        p,
        "Алгоритм распределения обычной задачи представлен на рисунке 3.4.",
    )
    insert_figure_before_table(
        doc, original_tables[7], media(24),
        "Рисунок 3.4 – Алгоритм распределения обычной задачи",
        max_width_cm=15.0, max_height_cm=19.0,
    )
    p = paragraph_by_start(doc, "Этот фрагмент показывает базовый механизм")
    set_para_text(
        p,
        "Алгоритм на рисунке 3.4 отражает базовый механизм исключения пересечений: "
        "курсор последовательно перемещается к концу занятого интервала, а кандидаты создаются только "
        "в образовавшихся разрывах. Коэффициенты авторской эвристики поясняются в тексте, чтобы не "
        "перегружать диаграмму деталями реализации.",
    )
    p = paragraph_by_start(doc, "Алгоритм на рисунке 3.4")
    append_sentence(p, "Механизм переноса части задачи после 23:00 показан на рисунке 3.5.")
    insert_figure_before_table(
        doc, original_tables[8], media(25),
        "Рисунок 3.5 – Механизм переноса части задачи после 23:00",
        max_width_cm=15.0, max_height_cm=19.0,
    )
    p = paragraph_by_start(doc, "После создания обычной задачи AddTaskCoordinator")
    append_sentence(p, "Результат выбора пользователя показан на рисунке 3.6.")
    insert_figure_before_table(
        doc, original_tables[9], split_task,
        "Рисунок 3.6 – Перенос части задачи после 23:00",
        max_width_cm=14.0, max_height_cm=18.0,
    )

    p = paragraph_by_contains(doc, "Экран истории получает доставленные уведомления")
    append_sentence(p, "Пример экрана истории уведомлений приведён на рисунке 3.7.")
    insert_figure_after_paragraph(
        doc, p, media(37),
        "Рисунок 3.7 – История уведомлений",
        max_width_cm=8.0, max_height_cm=16.5,
    )

    insert_figure_before_table(
        doc, original_tables[10], media(28),
        "Рисунок 3.8 – Подготовка показателей сна и эмоционального состояния",
        max_width_cm=15.0, max_height_cm=18.5,
    )
    for index in range(11, 15):
        remove_element(original_tables[index]._tbl)
    p = paragraph_by_start(doc, "Функция анализа дня предназначена")
    append_sentence(
        p,
        "Подготовка показателей сна и эмоционального состояния показана на рисунке 3.8. "
        "Последующие этапы расчёта представлены на рисунках Б.1–Б.4 приложения Б.",
    )
    p = paragraph_by_start(doc, "На экране анализа пользователь видит")
    set_para_text(
        p,
        p.text.replace("рисунке 3.3", "рисунке 3.9"),
    )
    p = paragraph_by_start(doc, "Последовательность загрузки сведений")
    set_para_text(
        p,
        p.text.replace("рисунке Б.1 приложения Б", "рисунке А.3 приложения А"),
    )
    p = paragraph_by_start(doc, "Подробные представления позволяют")
    append_sentence(p, "Экраны статистики эмоций, задач и сна приведены на рисунке 3.10.")
    insert_figure_before_paragraph(
        doc, paragraph_by_exact(doc, "3.7 Пользовательское исследование восприятия интерфейса"), statistics_screens,
        "Рисунок 3.10 – Статистика эмоций, задач и сна",
        max_width_cm=15.0, max_height_cm=17.5,
    )
    p = paragraph_by_start(doc, "На составном рисунке следует показать")
    set_para_text(
        p,
        "Согласованность состояния проверяется по совпадению названия, типа задачи и оставшегося времени "
        "между приложением и системным интерфейсом; действие «Завершить задачу» остаётся доступным в "
        "Live Activity.",
    )

    # Renumber the figures that remain in the main text.
    replacements = {
        "Рисунок 3.3 - Анализ дня и рекомендации": "Рисунок 3.9 – Анализ дня и рекомендации",
        "Рисунок 3.4 - Оценка понимания назначения приложения": "Рисунок 3.11 – Оценка понимания назначения приложения",
        "Рисунок 3.5 - Оценка удобства форм, календаря, выбора дат и задач": "Рисунок 3.12 – Оценка удобства форм, календаря, выбора дат и задач",
        "Рисунок 3.6 - Общая оценка интерфейса приложения": "Рисунок 3.13 – Общая оценка интерфейса приложения",
    }
    for old, new in replacements.items():
        set_para_text(paragraph_by_exact(doc, old), new)
    p = paragraph_by_start(doc, "Наиболее высокую среднюю оценку")
    set_para_text(
        p,
        p.text.replace("целесообразно сохранить в основном тексте как рисунок 3.4", "представлено на рисунке 3.11"),
    )
    p = paragraph_by_start(doc, "Более сдержанные оценки получены")
    set_para_text(
        p,
        p.text.replace("в основном тексте следует оставить рисунок 3.5", "распределение приведено на рисунке 3.12"),
    )
    p = paragraph_by_start(doc, "Средняя общая оценка интерфейса")
    set_para_text(
        p,
        p.text.replace("В основном тексте достаточно привести распределение общей оценки интерфейса на рисунке 3.6", "Распределение общей оценки интерфейса приведено на рисунке 3.13"),
    )

    # Normalize caption punctuation throughout the body.
    for paragraph in doc.paragraphs:
        text = paragraph.text.strip()
        if text.startswith("Рисунок ") or text.startswith("Таблица "):
            normalized = text.replace(" - ", " – ")
            if normalized != text:
                set_para_text(paragraph, normalized)
            style_caption(paragraph)

    # Delete the previous appendices and rebuild them in the order of first mention.
    appendix_start = paragraph_by_exact(doc, "ПРИЛОЖЕНИЕ А")._p
    body = doc.element.body
    node = appendix_start
    while node is not None and node.tag != qn("w:sectPr"):
        nxt = node.getnext()
        body.remove(node)
        node = nxt

    # Main document section follows the GOST/TSU page geometry.
    for section in doc.sections:
        configure_section(section, landscape=False)
    doc.sections[0].different_first_page_header_footer = True
    add_page_number(doc.sections[0].footer)
    if doc.sections[0].first_page_footer.paragraphs:
        doc.sections[0].first_page_footer.paragraphs[0].clear()

    section = doc.add_section(WD_SECTION.NEW_PAGE)
    configure_section(section, landscape=True)
    section.footer.is_linked_to_previous = True
    section.different_first_page_header_footer = False
    add_appendix_heading(doc, "А", "Диаграммы последовательности ключевых сценариев")
    sequence_figures = [
        (20, "Рисунок А.1 – Авторизация с помощью Face ID"),
        (21, "Рисунок А.2 – Интеграция с системным календарём iOS"),
        (41, "Рисунок А.3 – Формирование статистики и обновление достижений"),
    ]
    for idx, (number, caption) in enumerate(sequence_figures):
        add_appendix_figure(
            doc, media(number), caption,
            max_width_cm=25.0, max_height_cm=11.5 if idx == 0 else 14.0, page_break=idx > 0,
        )

    section = doc.add_section(WD_SECTION.NEW_PAGE)
    configure_section(section, landscape=True)
    section.footer.is_linked_to_previous = True
    section.different_first_page_header_footer = False
    add_appendix_heading(doc, "Б", "Расчёт показателей анализа дня")
    algorithm_figures = [
        (29, "Рисунок Б.1 – Расчёт оценки ресурса пользователя"),
        (30, "Рисунок Б.2 – Подготовка задач и расчёт показателей трудоёмкости"),
        (31, "Рисунок Б.3 – Расчёт фактической нагрузки, баланса и достоверности"),
        (32, "Рисунок Б.4 – Формирование рекомендаций и результата анализа дня"),
    ]
    for idx, (number, caption) in enumerate(algorithm_figures):
        add_appendix_figure(
            doc, media(number), caption,
            max_width_cm=25.0, max_height_cm=14.0, page_break=idx > 0,
        )

    compact_title_page(doc)
    replace_toc(doc)

    # Headings are normalized, while the existing Normal style is preserved so
    # that the carefully positioned title page is not reflowed.
    for style_name in ("Heading 1", "Heading 2", "Heading 3"):
        if style_name in doc.styles:
            style = doc.styles[style_name]
            style.font.name = FONT_NAME
            style._element.rPr.rFonts.set(qn("w:eastAsia"), FONT_NAME)
            style.font.size = Pt(14)
            style.font.bold = True
            style.paragraph_format.keep_with_next = True
            style.paragraph_format.line_spacing = 1.5

    # Ensure captions and appendix labels use the same settings. Existing body
    # paragraph formatting is preserved from the reviewed source document.
    for paragraph in doc.paragraphs:
        text = paragraph.text.strip()
        if not text:
            continue
        if text.startswith("Рисунок ") or text.startswith("Таблица "):
            style_caption(paragraph)
        elif text.startswith("ПРИЛОЖЕНИЕ "):
            paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
            paragraph.paragraph_format.first_line_indent = Cm(0)

    # The coursework uses one typographic scale: Times New Roman, 14 pt.
    # Replace em dashes with en dashes in all editable document text.
    for style in doc.styles:
        if getattr(style, "font", None) is not None:
            style.font.name = FONT_NAME
            style._element.get_or_add_rPr().get_or_add_rFonts().set(qn("w:eastAsia"), FONT_NAME)
            style.font.size = Pt(14)
    for paragraph in iter_text_paragraphs(doc):
        for run in paragraph.runs:
            if "—" in run.text:
                run.text = run.text.replace("—", "–")
            set_run_font(run, size=14)

    settings = doc.settings._element
    update_fields = settings.find(qn("w:updateFields"))
    if update_fields is None:
        update_fields = OxmlElement("w:updateFields")
        settings.append(update_fields)
    update_fields.set(qn("w:val"), "true")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    doc.save(OUTPUT)
    print(OUTPUT)


if __name__ == "__main__":
    main()
