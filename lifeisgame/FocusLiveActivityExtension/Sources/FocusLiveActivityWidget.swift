//
//  FocusLiveActivityWidget.swift
//  FocusLiveActivityExtension
//
//  Created by Gleb Korotkov on 09.05.2026.
//

import ActivityKit
import SwiftUI
import UIKit
import WidgetKit

struct FocusLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            lockScreenView(context)
                .activityBackgroundTint(Color.focusActivityBackground)
                .activitySystemActionForegroundColor(Color.focusActivityPrimaryText)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Фокус", systemImage: "timer")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.focusActivityAccent)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    compactCountdown(
                        to: context.state.endDate,
                        foregroundColor: .focusActivityAccent
                    )
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                DynamicIslandExpandedRegion(.bottom) {
                    expandedTaskView(context)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(Color.focusActivityAccent)
            } compactTrailing: {
                compactCountdown(
                    to: context.state.endDate,
                    foregroundColor: .focusActivityAccent
                )
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(Color.focusActivityAccent)
            }
            .keylineTint(Color.focusActivityAccent)
        }
    }

    private func lockScreenView(_ context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "timer")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.focusActivityAccent)
                    .frame(width: 34, height: 34)
                    .background(Color.focusActivityAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(context.attributes.taskTypeTitle)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.focusActivitySecondaryText)
                    Text(context.attributes.taskTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(Color.focusActivityPrimaryText)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Осталось")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.focusActivitySecondaryText)
                    Text(timerInterval: timerRange(to: context.state.endDate), countsDown: true)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.focusActivityAccent)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(12)
            .background(Color.focusActivitySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Link(destination: completionURL(for: context.attributes.taskID)) {
                Label("Завершить задачу", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Color.focusActivityButton,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
    }

    private func expandedTaskView(_ context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "target")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.focusActivityAccent)
                .frame(width: 28, height: 28)
                .background(Color.focusActivityAccent.opacity(0.16), in: RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.taskTypeTitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.62))
                Text(context.attributes.taskTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Link(destination: completionURL(for: context.attributes.taskID)) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.focusActivityButton, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Завершить задачу")
        }
        .padding(.top, 2)
    }

    private func compactCountdown(to endDate: Date, foregroundColor: Color = .white) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            Text(shortRemainingTime(until: endDate, from: timeline.date))
                .foregroundStyle(foregroundColor)
                .monospacedDigit()
        }
    }

    private func shortRemainingTime(until endDate: Date, from currentDate: Date) -> String {
        let secondsRemaining = max(0, Int(endDate.timeIntervalSince(currentDate)))

        if secondsRemaining >= 3_600 {
            return "\(secondsRemaining / 3_600)ч"
        }

        if secondsRemaining >= 60 {
            return "\(secondsRemaining / 60)м"
        }

        return "\(secondsRemaining)с"
    }

    private func timerRange(to endDate: Date) -> ClosedRange<Date> {
        let now = Date()
        return now...max(now, endDate)
    }

    private func completionURL(for taskID: UUID) -> URL {
        var components = URLComponents()
        components.scheme = "lifeisgame"
        components.host = "focus"
        components.path = "/complete"
        components.queryItems = [
            URLQueryItem(name: "taskID", value: taskID.uuidString)
        ]
        return components.url ?? URL(fileURLWithPath: "/")
    }
}

private extension Color {
    static let focusActivityBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.075, green: 0.059, blue: 0.102, alpha: 1)
            : UIColor(red: 0.980, green: 0.973, blue: 1.000, alpha: 1)
    })

    static let focusActivitySurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.137, green: 0.110, blue: 0.184, alpha: 1)
            : UIColor.white
    })

    static let focusActivityPrimaryText = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 0.110, green: 0.110, blue: 0.118, alpha: 1)
    })

    static let focusActivitySecondaryText = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.62)
            : UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.62)
    })

    static let focusActivityAccent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.635, green: 0.514, blue: 1.000, alpha: 1)
            : UIColor(red: 0.373, green: 0.200, blue: 0.882, alpha: 1)
    })

    static let focusActivityButton = Color(
        red: 0.373,
        green: 0.200,
        blue: 0.882
    )
}
