#!/bin/sh
if command -v swiftlint >/dev/null 2>&1; then
    swiftlint lint --config "${SRCROOT}/swiftlintconfiguration.yml" --cache-path "${DERIVED_FILE_DIR}/SwiftLintCache" --quiet
else
    echo "warning: SwiftLint not installed. Install from https://github.com/realm/SwiftLint"
fi

