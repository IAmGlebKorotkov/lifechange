---
name: tsu-coursework-formatting
description: Detailed Russian-language guidance for composing, formatting, reviewing, and correcting курсовая работа, курсовой проект, ВКР, реферат, отчет, оглавление, заголовки, таблицы, рисунки, формулы, цитаты, библиографические ссылки, список литературы, appendices, and engineering narratives for commissioned or internal-client software development according to TSU Scientific Library guidelines. Use when the user asks how to write or structure a Russian academic paper, trace customer problems through requirements, architecture, implementation, and verification, check a DOCX, prepare title pages, fix references, or explain правила оформления курсовой.
---

# TSU Coursework Formatting

## Source And Scope

Use this skill to help write, format, audit, or revise Russian student academic work according to the TSU Scientific Library guide "Оформление работ: методические указания по оформлению курсовых и выпускных квалификационных работ". The local file is named `Методичка NB 2021.pdf`, but its extracted title page says `Томск - 2026`; mention that distinction if version/date matters.

Treat faculty, institute, department, and supervisor rules as higher-priority local constraints when they conflict with this general guide. When the user provides a DOCX, preserve their content and authorship; do not invent sources, results, signatures, approvals, or institutional data.

## Workflows

### Explain how to compose a coursework

Give the user a practical structure, not only formatting rules:

1. Start from the title page and official topic wording.
2. Build an outline with `ВВЕДЕНИЕ`, numbered chapters, `ЗАКЛЮЧЕНИЕ`, bibliography, and appendices if needed.
3. In the introduction, state relevance, current state of the problem, source/input data, purpose, tasks, object, subject, methods, and practical/theoretical significance if expected by the faculty.
4. Make the main part evidence-driven: review literature, compare approaches, justify the chosen direction, then present analysis, implementation/practice, and results.
5. End each chapter with short conclusions.
6. In the conclusion, return to the purpose and tasks from the introduction; do not introduce a new problem.
7. Check every borrowed idea, number, table, figure, formula, and quote for a citation.
8. Format the DOCX only after the structure and citations are stable.

### Format or review a document

When checking a coursework or ВКР:

1. Identify work type: курсовая работа, курсовой проект, ВКР, реферат, отчет.
2. Check structural order and page numbering.
3. Check page setup, font, spacing, paragraph indents, headings, TOC, tables, figures, formulas, lists, citations, bibliography, and appendices.
4. If working with DOCX, inspect actual styles/OOXML when possible instead of judging by plain text alone.
5. Report issues as actionable fixes: what is wrong, where, and how to change it.
6. For visual layout edits, render the DOCX/PDF when possible and verify title page, TOC, tables, and appendices.

### Work with bibliography

For bibliography and reference details, read `references/bibliography.md` when:

- formatting `СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ`;
- deciding whether the list should be titled `ЛИТЕРАТУРА`, `СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ`, or `СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ И ЛИТЕРАТУРЫ`;
- choosing alphabetical, systematic, or first-mention ordering;
- formatting books, journal articles, websites, electronic resources, laws, standards, dissertations, conference papers, or archive materials;
- comparing bibliography entries with footnote references.

### Write or review commissioned software development

Read `references/custom-development-patterns.md` when the work concerns a real organization, organizational unit, internal product owner, external client, employee group, or other documented stakeholder, or when the user explicitly asks to frame a project as заказная разработка.

Before using that narrative, classify the project from evidence as one of:

- commissioned development for an external or organizational customer;
- internal product development for a company or unit;
- user-oriented product development without a documented customer;
- an educational project.

Do not classify a project as commissioned merely because it has requirements, users, or a practical application. Require factual support for the customer or stakeholder, their activity, their need, and the origin of requirements.

For significant functionality, maintain traceability:

`customer problem -> need -> requirement -> design decision -> implementation -> verification -> result`.

If a link is unsupported, do not manufacture a meeting, constraint, requirement, acceptance criterion, or business effect. State what project fact is missing and request it. Use the reference to structure the text, assess evidence strength, distinguish requirements from author preferences, and connect architecture and testing to requirements.

## Page Setup

Use these default technical parameters unless the user gives stricter faculty rules:

- Paper: A4, one-sided.
- Margins: left `30 mm`, right `15 mm`, top `20 mm`, bottom `20 mm`.
- Paragraph first-line indent: `1.25 cm`.
- Font: Times New Roman.
- Main text size: `12` or `14 pt`; keep one size consistently unless a faculty template requires one.
- Line spacing: `1.5`.
- Page numbers: Arabic numerals, no extra signs, centered at the bottom, no final dot.
- Numbering is continuous from the title page through bibliography and appendices.
- The title page counts as page 1, but the visible number `1` is not printed on it.
- `ОГЛАВЛЕНИЕ` is normally page 2.
- For ВКР, assignment and annotation are placed after the title page but are not numbered and are not included in the TOC.
- Recommended coursework length: `20-30` pages; actual length depends on topic, discipline, supervisor, and source base.
- Avoid excessive nonbreaking spaces: the guide warns that too many nonbreaking spaces may create issues with Antiplagiat checks.

## Required Structure

Default sequence:

1. Title page.
2. Assignment, only for ВКР.
3. Annotation/abstract, only for ВКР unless requested.
4. `ОГЛАВЛЕНИЕ`.
5. List of conditional designations, symbols, abbreviations, and terms, if needed.
6. `ВВЕДЕНИЕ`.
7. Main part.
8. `ЗАКЛЮЧЕНИЕ`.
9. Bibliography.
10. Appendices, if needed.

For a standard coursework, the practical minimum is title page, TOC, introduction, main part, conclusion, bibliography, and appendices if the work uses supporting materials that would overload the main text.

## Title Page

For a coursework title page, include:

- Ministry line and university name: `Министерство науки и высшего образования Российской Федерации`, `НАЦИОНАЛЬНЫЙ ИССЛЕДОВАТЕЛЬСКИЙ ТОМСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ (НИ ТГУ)`.
- Educational structural unit.
- Work type: `КУРСОВАЯ РАБОТА` or `КУРСОВОЙ ПРОЕКТ`.
- Topic title.
- Student full name.
- Training direction code and name.
- Profile/program name.
- Supervisor block: academic degree/title if any, signature line, initials and surname, date.
- Author block: student group number, signature line, initials and surname, date.
- City and year: `Томск - 20__`.

Do not fabricate signatures, dates, degree titles, profile names, or approval data. Ask or leave placeholders if unknown.

## Table Of Contents

The TOC includes all structural elements and numbered headings with starting page numbers. After each heading, use dot leaders and the page number. Automatic Word TOC is acceptable, but it must be visually edited to match the methodical guide.

Check that:

- TOC headings exactly match headings in the body.
- Page numbers are current.
- Numbering hierarchy is visible: `1`, `1.1`, `1.1.1`.
- Structural elements such as `ВВЕДЕНИЕ`, `ЗАКЛЮЧЕНИЕ`, and bibliography appear without chapter numbers.
- Appendices appear if they are present in the work.

## Abbreviations And Terms

Create a separate list only when designations, symbols, abbreviations, or terms recur at least three times and need explanation. Arrange them in order of first mention in the text. If an abbreviation appears fewer than three times, decode it at first mention in the main text instead of creating a separate list.

## Introduction

The introduction should explain why the topic is worth studying and how the research will be carried out. For coursework, include the following unless the department uses a different template:

- Relevance: why the problem matters now.
- Current state of the problem: what is already known and what remains unclear.
- Object and subject of research.
- Purpose: one clear result-oriented formulation.
- Tasks: numbered or listed steps that lead to the purpose.
- Methods and source/material base.
- Practical significance or expected result when applicable.
- Brief structure of the work if expected.

Make the introduction and conclusion mirror each other: every task from the introduction should have an answer in the conclusion.

## Main Part

The main part contains the essence, method, and results of the work. It should include a literature review and chapters that reflect the research or project work.

Use this default chapter logic when no department-specific structure is given:

- Chapter 1: theoretical foundation of the problem without narrow attachment to the specific implementation. Compare domestic and foreign authors if relevant, define concepts, show competing viewpoints, and justify the author's position.
- Chapter 2: analysis of the specific problem, historical aspect, current state, normative or methodological base, trends, deficiencies, and possible ways to address them.
- Chapter 3: practical part if the topic requires it. Analyze a concrete subject, organization, product, system, or case; present implementation/results; propose improvements; assess expected effect.

Rules for the literature review:

- Select only material directly connected to the topic.
- Avoid broad general discussion that does not help solve the research problem.
- Show the history and current state of the question enough for the reader to evaluate the relevance and chosen approach.
- If the topic has almost no prior study, the introduction and literature review may be combined.

Each chapter should end with a short conclusion that summarizes what was established in that chapter and prepares the next step.

## Conclusion

The conclusion is the logical ending of the work and must connect back to the introduction. It should:

- briefly restate the relevance and purpose;
- give reasoned conclusions by the research topic;
- show how each stated task was solved;
- name problems and ways of solving them;
- describe expected practical effect or possible implementation when relevant;
- avoid new evidence, new sources, and new tasks that were not discussed in the work.

## Headings

Use Arabic numerals only. Do not write `Глава` or the paragraph sign `§` before headings.

Structural headings:

- Examples: `АННОТАЦИЯ`, `ОГЛАВЛЕНИЕ`, `ПЕРЕЧЕНЬ УСЛОВНЫХ ОБОЗНАЧЕНИЙ`, `ВВЕДЕНИЕ`, `ЗАКЛЮЧЕНИЕ`, bibliography heading, `ПРИЛОЖЕНИЕ`.
- Centered.
- Uppercase.
- Bold.
- No underline.
- No final dot.
- Start each on a new page.

Chapter and section headings:

- Numbered as `1`, `1.1`, `1.1.1`.
- Chapter number has no dot after it.
- Align by width.
- Start with a capital letter.
- Bold.
- No underline.
- No final dot.
- Begin with first-line indent `1.25 cm`.
- Do not hyphenate words in headings.
- If the heading has two sentences, separate them with a dot.
- Start every main chapter on a new page.
- Leave about two intervals between heading and following text.

## Tables

Use tables for clarity and comparison. Check every table against these rules:

- Place directly after first mention or on the next page.
- Make the table readable without turning the work, or with clockwise rotation only.
- Put `Таблица` and the title above the table, left-aligned, without paragraph indent, in one line with the number and a dash.
- Example pattern: `Таблица 1 - Краткое название таблицы`.
- If the title takes multiple lines, use single line spacing inside the title.
- Number tables either continuously through the work or by chapters; be consistent.
- If there is only one table, label it `Таблица 1`.
- Refer to every table in the text using the word `таблица` and its number.
- On continuation pages, write `Продолжение таблицы 1`; on the final part, write `Окончание таблицы 1`.
- Column headings start with capital letters. Subheadings start lowercase if they continue the heading, and uppercase if independent.
- Do not put dots at the end of table headings or subheadings.
- Use singular in headings where possible.
- Do not divide table heads diagonally.
- Center column headings; align row headings left.
- Do not add a separate `Номер по порядку` column.
- Align numbers by digit classes and decimal places within a column.
- If data is absent, put a dash.
- Repeating text may be replaced with quotation marks only when it is the same word; do not replace repeated numbers, signs, mathematical symbols, or chemical symbols with quotation marks.
- Cite borrowed tables.
- Smaller font and single line spacing are allowed inside tables.
- Put notes immediately after the table. One note starts `Примечание - ...`; several notes are numbered with Arabic numerals without dots.
- In appendices, number tables by appendix: `Таблица В.1`, `Таблица Г.2`.

## Figures

Figures include drawings, diagrams, charts, maps, screenshots, and photos.

- Place directly after first mention, on the next page, or in an appendix.
- Refer to every figure in the text with `рисунок` and its number.
- Center the figure on the page.
- Use black-and-white or color if the print/render stays readable.
- Number continuously or by chapters; be consistent.
- If numbering by chapter, use forms such as `Рисунок 4.1`.
- If there is only one figure, label it `Рисунок 1`.
- Put the caption below the figure, centered.
- Start the caption with a capital letter.
- Do not put a final dot after the caption.
- Use single spacing for multiline captions.
- Cite borrowed figures.
- Put notes immediately after the figure.
- In appendices, number figures by appendix: `Рисунок Д.1`.

## Formulas

Use these rules for formulas and equations:

- Put each formula or equation on a separate line.
- Leave at least one blank line above and below.
- If a formula does not fit on one line, break after `=`, `+`, `-`, multiplication, division, or another mathematical sign, and repeat the sign at the start of the next line.
- When breaking at multiplication, use `X`.
- Explain symbols directly below the formula in the same order as in the formula.
- Start the first explanation line with `где` without a colon.
- If explanations follow, put a comma after the formula.
- If there are no explanations, do not put that comma.
- Number formulas continuously or by chapter using Arabic numerals in parentheses at the far right of the formula line.
- If there is one formula, number it `(1)`.

## Lists

Use a hyphen before simple list items. If the text needs references to specific list items, use lowercase Russian letters followed by `)`, excluding `ё`, `з`, `й`, `о`, `ч`, `ъ`, `ы`, `ь`. For deeper detailing, use Arabic numerals followed by `)`.

## Citations

Citation rules:

- Cite authors from primary sources whenever possible.
- If the primary source is unavailable and a quote is taken from another publication, mark this in the reference with `Цит. по:` or `Приводится по:`.
- Use citations sparingly and only for important statements.
- Avoid two or more long quotations in a row.
- Do not merge two separate quotations into one.
- You may modernize spelling/punctuation only if it does not distort an author's individual spelling or punctuation.
- Mark omitted words or phrases with ellipsis.
- Do not shorten a quote in a way that changes the meaning.
- Exact quotes are enclosed in quotation marks unless they are verse lines preserved as verse, epigraphs, or paraphrases.
- Paraphrased ideas still require a citation.
- Every quote, paraphrase, fact, table, figure, formula, and borrowed idea needs a bibliographic link.

## Bibliographic Links In Text

The guide allows several link types under ГОСТ Р 7.0.5-2008:

- By completeness: full or short.
- By location: footnotes, end-of-text references in square brackets, or intratext parenthetical references.
- By number of uses: primary or repeated.
- By number of objects: simple or complex.

Use one system consistently unless the supervisor requires another.

Footnotes:

- Format as page-bottom notes.
- First-line indent `1.25 cm`.
- Single line spacing.
- Times New Roman.
- Font size two points smaller than main text, but not less than `10 pt`.
- Number either through the whole text or separately on each page, consistently.
- In footnotes, a shorter description is allowed if it still lets the reader find the source.

Square-bracket references:

- Put the full description in the bibliography.
- In text, refer to the bibliography number: `[13]`.
- For exact pages: `[20, с. 29]`.
- For several works: `[59, 67, 82]`.
- For a volume: `[18, т. 1, с. 75]`.
- Author-year style is also possible when appropriate: `[Бахтин, 2003, с. 18]`.

Repeated footnotes:

- If consecutive, use `Там же` and add a page if needed.
- For Latin-script sources, use `Ibid`.
- If not consecutive, use shortened author/title or `Указ. соч.`, `Цит. соч.`, or `Op. cit.` consistently.

Complex links:

- Separate multiple sources in one link with semicolon and spaces around it.
- Arrange them alphabetically, chronologically, or by language group, consistently.

## Bibliography

The bibliography comes after the main text and before appendices. It confirms the accuracy of cited facts, ideas, quotations, tables, figures, formulas, and source material.

Use `references/bibliography.md` for detailed rules and templates. Essential checks:

- Choose the correct title:
  - `ЛИТЕРАТУРА` if the list includes all studied documents, not only cited ones.
  - `СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ` if the list includes only works analyzed or used in the text.
  - `СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ И ЛИТЕРАТУРЫ` if the work uses both literature and sources.
- Format entries with first-line indent `1.25 cm`, line spacing `1.5`, left/right indent `0`, spacing before/after `0 pt`, alignment by width.
- Use ГОСТ-style punctuation consistently, especially ` - ` between description areas.
- Sort systematically, alphabetically, or by first mention; do not mix systems accidentally.
- For alphabetical sorting: Russian-language entries first, then foreign-language entries; for works by one author, sort by title or chronology.
- For systematic sorting: separate `Источники` and `Литература` when needed; keep numbering continuous through all sections.

## Appendices

Appendices are optional and contain supporting material such as large tables, figures, graphs, screenshots, forms, or auxiliary data.

- Place appendices after the bibliography.
- Arrange them in the order of first mention in the text.
- Start each appendix on a new page.
- Center the word `ПРИЛОЖЕНИЕ` with its letter.
- Give each appendix a heading that reflects its content.
- Number appendices with uppercase Russian letters starting from `А`.
- Do not use `Ё`, `З`, `Й`, `О`, `Ч`, `Ъ`, `Ы`, `Ь`.
- If Russian letters are exhausted, use Latin letters except `I` and `O`.
- If all letters are exhausted, use Arabic numerals.
- If there is one appendix, call it `Приложение А`.
- Number appendix tables and figures separately with the appendix letter: `Таблица А.1`, `Рисунок А.1`.

## Final Quality Checklist

Before returning a final answer or edited document, check:

- The work has the correct structural order.
- The title page contains required fields and no invented data.
- Page setup matches A4, margins, font, spacing, indent, and numbering rules.
- TOC headings and page numbers match the body.
- Headings use Arabic numbering and correct capitalization/alignment.
- Chapters start on new pages and end with short conclusions.
- Introduction tasks are answered in the conclusion.
- Tables and figures are mentioned before placement and have correct captions.
- Borrowed tables, figures, facts, and quotes have citations.
- Formulas are separated, explained, and numbered consistently.
- Lists use allowed marker formats.
- Bibliography title, ordering, and entry formatting match the content of the work.
- Appendices are mentioned in text and ordered by first mention.
- No obvious formatting artifacts remain from pasted web text.
