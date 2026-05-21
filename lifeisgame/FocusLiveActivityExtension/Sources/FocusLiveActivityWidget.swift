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
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            lockScreenView(context)
                .activityBackgroundTint(.background)
                .activitySystemActionForegroundColor(.main)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Фокус", systemImage: "timer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.main)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Осталось")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.focusSecondaryText)
                        Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundStyle(.main)
                            .multilineTextAlignment(.trailing)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.taskTypeTitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.focusSecondaryText)
                        Text(context.attributes.taskTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.focusPrimaryText)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(.main)
            } compactTrailing: {
                Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.focusPrimaryText)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(.main)
            }
        }
    }

    private func lockScreenView(_ context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "timer.circle.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.main)

            VStack(alignment: .leading, spacing: 5) {
                Text(context.attributes.taskTypeTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.focusSecondaryText)
                Text(context.attributes.taskTitle)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(2)
                    .foregroundStyle(.main)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text("Осталось")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.focusSecondaryText)
                Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(.main)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 4)
    }

    private func timerRange(to endDate: Date) -> ClosedRange<Date> {
        let now = Date()
        return now...max(now, endDate)
    }
}
