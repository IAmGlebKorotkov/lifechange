//
//  FocusLiveActivityWidget.swift
//  FocusLiveActivityExtension
//
//  Created by Gleb Korotkov on 16.05.2026.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct FocusLiveActivityWidget: Widget {

    private let accent = Color(red: 95 / 255, green: 51 / 255, blue: 225 / 255)
    private let background = Color(red: 250 / 255, green: 248 / 255, blue: 255 / 255)
    private let primaryText = Color(red: 28 / 255, green: 24 / 255, blue: 38 / 255)
    private let secondaryText = Color(red: 103 / 255, green: 96 / 255, blue: 118 / 255)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            lockScreenView(context)
                .activityBackgroundTint(background)
                .activitySystemActionForegroundColor(accent)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Фокус", systemImage: "timer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accent)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Осталось")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.trailing)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.taskTypeTitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(context.attributes.taskTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(accent)
            } compactTrailing: {
                Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(accent)
            }
        }
    }

    private func lockScreenView(_ context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "timer.circle.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 5) {
                Text(context.attributes.taskTypeTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(secondaryText)
                Text(context.attributes.taskTitle)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(2)
                    .foregroundStyle(primaryText)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text("Осталось")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(secondaryText)
                Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(accent)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }

    private func timerRange(to endDate: Date) -> ClosedRange<Date> {
        let now = Date()
        return now...max(now, endDate)
    }
}
