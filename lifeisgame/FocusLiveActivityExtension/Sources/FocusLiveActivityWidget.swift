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
                DynamicIslandExpandedRegion(.center) {
                    expandedTimerView(context)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    expandedTaskView(context)
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
        VStack(alignment: .leading, spacing: 16) {
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
                        .foregroundStyle(.focusPrimaryText)
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

            Link(destination: completionURL(for: context.attributes.taskID)) {
                Label("Завершить задачу", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.main)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.main.opacity(0.12), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.main.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 18)
    }

    private func expandedTimerView(_ context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        VStack(spacing: 4) {
            Label("Фокус", systemImage: "timer")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.78))
                .labelStyle(.titleAndIcon)

            Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                .font(.system(size: 25, weight: .bold, design: .monospaced))
                .foregroundStyle(.main)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }

    private func expandedTaskView(_ context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "target")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.main)
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.10), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(context.attributes.taskTypeTitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.62))
                Text(context.attributes.taskTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 8)
    }

    private func timerRange(to endDate: Date) -> ClosedRange<Date> {
        let now = Date()
        return now...max(now, endDate)
    }

    private func completionURL(for taskID: UUID) -> URL {
        URL(string: "lifeisgame://focus/complete?taskID=\(taskID.uuidString)")!
    }
}
