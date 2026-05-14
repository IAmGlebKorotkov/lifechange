//
//  LocalNotificationService.swift
//  lifeisgame
//
//  Created by Codex on 14.05.2026.
//

import Foundation
import UserNotifications

final class LocalNotificationService {

    static let shared = LocalNotificationService()

    private let center = UNUserNotificationCenter.current()
    private let calendar = Calendar.current
    private let notificationsEnabledKey = "notificationsEnabled"
    private let diaryScheduleDays = 7

    private init() {}

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: notificationsEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: notificationsEnabledKey) }
    }

    func setNotificationsEnabled(
        _ enabled: Bool,
        diaryRepository: DiaryRepositoryProtocol,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard enabled else {
            isEnabled = false
            cancelAllScheduledNotifications()
            DispatchQueue.main.async {
                completion?(false)
            }
            return
        }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isEnabled = granted
                if granted {
                    self.refreshDiaryReminders(repository: diaryRepository)
                }
                completion?(granted)
            }
        }
    }

    func scheduleTaskReminders(for tasks: [TaskItem]) {
        guard isEnabled else { return }

        ensureAuthorization { [weak self] isGranted in
            guard let self, isGranted else { return }

            let notificationTasks = tasks.flatMap { task -> [TaskItem] in
                if task.isHardTask && !task.subtasks.isEmpty {
                    return task.subtasks
                }
                return [task]
            }

            for task in notificationTasks {
                self.scheduleTaskReminder(for: task, minutesBefore: 30)
                self.scheduleTaskReminder(for: task, minutesBefore: 5)
            }
        }
    }

    func refreshDiaryReminders(repository: DiaryRepositoryProtocol) {
        guard isEnabled else { return }

        ensureAuthorization { [weak self] isGranted in
            guard let self, isGranted else { return }
            DispatchQueue.main.async {
                guard let userID = SessionManager.shared.currentUserID else { return }

                let dates = self.scheduledDiaryDates(from: Date())
                self.center.removePendingNotificationRequests(
                    withIdentifiers: dates.flatMap { self.diaryReminderIdentifiers(for: $0) }
                )

                for date in dates {
                    let hasEmotionEntry = (try? repository.hasEmotionEntry(forUserID: userID, on: date)) ?? false
                    let hasSleepEntry = (try? repository.hasSleepEntry(forUserID: userID, on: date)) ?? false

                    if !hasEmotionEntry {
                        self.scheduleDiaryReminder(
                            identifier: self.diaryIdentifier(kind: "emotion", hour: 18, date: date),
                            title: "Дневник эмоций",
                            body: "Заполните эмоции за сегодня",
                            hour: 18,
                            minute: 0,
                            date: date
                        )
                        self.scheduleDiaryReminder(
                            identifier: self.diaryIdentifier(kind: "emotion", hour: 20, date: date),
                            title: "Дневник эмоций",
                            body: "Эмоции за сегодня еще не заполнены",
                            hour: 20,
                            minute: 0,
                            date: date
                        )
                    }

                    if !hasSleepEntry {
                        self.scheduleDiaryReminder(
                            identifier: self.diaryIdentifier(kind: "sleep", hour: 8, date: date),
                            title: "Дневник сна",
                            body: "Заполните дневник сна",
                            hour: 8,
                            minute: 0,
                            date: date
                        )
                        self.scheduleDiaryReminder(
                            identifier: self.diaryIdentifier(kind: "sleep", hour: 12, date: date),
                            title: "Дневник сна",
                            body: "Дневник сна еще не заполнен",
                            hour: 12,
                            minute: 0,
                            date: date
                        )
                    }
                }
            }
        }
    }

    func cancelEmotionDiaryReminders(on date: Date) {
        center.removePendingNotificationRequests(withIdentifiers: [
            diaryIdentifier(kind: "emotion", hour: 18, date: date),
            diaryIdentifier(kind: "emotion", hour: 20, date: date)
        ])
    }

    func cancelSleepDiaryReminders(on date: Date) {
        center.removePendingNotificationRequests(withIdentifiers: [
            diaryIdentifier(kind: "sleep", hour: 8, date: date),
            diaryIdentifier(kind: "sleep", hour: 12, date: date)
        ])
    }

    func cancelAllScheduledNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    private func scheduleTaskReminder(for task: TaskItem, minutesBefore: Int) {
        let fireDate = task.startDate.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        let now = Date()
        guard task.startDate > now else { return }

        let triggerDate: Date
        if fireDate > now {
            triggerDate = fireDate
        } else if minutesBefore == 5 {
            triggerDate = now.addingTimeInterval(3)
        } else {
            return
        }

        let identifier = "task.\(task.id.uuidString).\(minutesBefore)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = minutesBefore == 30 ? "Задача через 30 минут" : "Задача через 5 минут"
        content.body = "\(task.name) начнется в \(timeString(task.startDate))"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate),
            repeats: false
        )
        center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }

    private func scheduleDiaryReminder(
        identifier: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        date: Date
    ) {
        guard let fireDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date),
              fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate),
            repeats: false
        )
        center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }

    private func ensureAuthorization(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { [weak self] settings in
            guard let self else {
                completion(false)
                return
            }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    self.isEnabled = granted
                    completion(granted)
                }
            case .denied:
                self.isEnabled = false
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    private func scheduledDiaryDates(from date: Date) -> [Date] {
        (0..<diaryScheduleDays).compactMap {
            calendar.date(byAdding: .day, value: $0, to: calendar.startOfDay(for: date))
        }
    }

    private func diaryReminderIdentifiers(for date: Date) -> [String] {
        [
            diaryIdentifier(kind: "emotion", hour: 18, date: date),
            diaryIdentifier(kind: "emotion", hour: 20, date: date),
            diaryIdentifier(kind: "sleep", hour: 8, date: date),
            diaryIdentifier(kind: "sleep", hour: 12, date: date)
        ]
    }

    private func diaryIdentifier(kind: String, hour: Int, date: Date) -> String {
        "diary.\(kind).\(hour).\(dayIdentifier(for: date))"
    }

    private func dayIdentifier(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
