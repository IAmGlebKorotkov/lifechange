from __future__ import annotations

import re
import sys
from collections import Counter
from pathlib import Path

from docx import Document


def main() -> None:
    path = Path(sys.argv[1])
    document = Document(path)
    paragraphs = [paragraph.text.strip() for paragraph in document.paragraphs]

    print("HEADINGS")
    for index, text in enumerate(paragraphs):
        if text and (
            text
            in {
                "ВВЕДЕНИЕ",
                "ЗАКЛЮЧЕНИЕ",
                "СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ",
            }
            or re.match(r"^[123](?:\.\d+){0,2}\s", text)
        ):
            print(index, repr(text))

    citations: list[int] = []
    for text in paragraphs:
        for match in re.finditer(r"\[(\d+(?:\s*[,;]\s*\d+)*)\]", text):
            citations.extend(int(number) for number in re.findall(r"\d+", match.group(1)))

    counts = Counter(citations)
    print("paragraphs", len(paragraphs))
    print("citations_unique", sorted(counts))
    print("citations_count", sum(counts.values()))
    print("citations_frequency", dict(sorted(counts.items())))

    print("CITATION_PARAGRAPHS")
    for index, text in enumerate(paragraphs):
        if re.search(r"\[\d", text):
            print(index, text)

    bibliography_start = next(
        (
            index
            for index, text in enumerate(paragraphs)
            if text == "СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ"
        ),
        None,
    )
    if bibliography_start is not None:
        print("BIBLIOGRAPHY")
        for index, text in enumerate(paragraphs[bibliography_start + 1 :], bibliography_start + 1):
            if re.match(r"^\d+\.\s", text):
                print(index, text)

    for label, start, end in (
        ("TOC", 40, 71),
        ("INTRODUCTION", 71, 84),
        ("CONCLUSION", 287, 299),
    ):
        print(label)
        for index in range(start, min(end, len(paragraphs))):
            print(index, paragraphs[index])


if __name__ == "__main__":
    main()
