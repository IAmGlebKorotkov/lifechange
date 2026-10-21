//
//  CalendarTaskListView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//
//  Пропорциональный таймлайн дня 00:00–23:59: позиция и высота карточки
//  задачи определяются временем начала и длительностью.
//

import UIKit

private enum TimelineMetrics {
    static let defaultHourHeight: CGFloat = 64
    static let minimumHourHeight: CGFloat = 32
    static let maximumHourHeight: CGFloat = 128
    static let topPadding: CGFloat = 14
    static let bottomPadding: CGFloat = 28
    static let timeColumnWidth: CGFloat = 48
    static let gridLeading: CGFloat = 66
    static let cardLeading: CGFloat = 72
    static let trailingPadding: CGFloat = 16
    static let minCardHeight: CGFloat = 26
    static let columnSpacing: CGFloat = 4

    static func contentHeight(hourHeight: CGFloat) -> CGFloat {
        topPadding + 24 * hourHeight + bottomPadding
    }
}

private struct CalendarTaskRow {
    let task: TaskItem
    let mainTaskName: String?
    let typeTitle: String

    var canEdit: Bool {
        task.source == .app
    }
}

private struct TimelineGap {
    let startDate: Date
    let endDate: Date

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

private struct TaskLayoutItem {
    let row: CalendarTaskRow
    let startY: CGFloat
    let height: CGFloat
    var column = 0
    var columnCount = 1

    var endY: CGFloat { startY + height }
}

final class CalendarTaskListView: UIView {

    var onAddItemSelected: ((AddTaskKind) -> Void)?
    var onAddEventInGapTapped: ((Date) -> Void)?
    var onTaskToggled: ((UUID) -> Void)?
    var onTaskSelected: ((TaskItem) -> Void)?
    var onTaskDeleteRequested: ((UUID) -> Void)?

    private var tasksSnapshot: [TaskItem] = []
    private var selectedDate = Date()
    private var isToday = true
    private var lastAutoScrolledDay: Date?
    private var nowTimer: Timer?
    private var timelineHourHeight = TimelineMetrics.defaultHourHeight
    private var pinchStartHourHeight = TimelineMetrics.defaultHourHeight
    private var pinchAnchorHour: CGFloat = 0
    private var pinchAnchorViewportY: CGFloat = 0

    private var timelineRows: [CalendarTaskRow] = []
    private var layoutItems: [TaskLayoutItem] = []
    private var gaps: [TimelineGap] = []

    private var cardViews: [TimelineTaskCardView] = []
    private var gapViews: [GapOverlayView] = []
    private var hourLabels: [UILabel] = []
    private var hourLines: [UIView] = []

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView = UIView()

    private let nowLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .main
        view.layer.cornerRadius = 1
        return view
    }()

    private let nowDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .main
        view.layer.cornerRadius = 5
        return view
    }()

    private let nowTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .main
        label.textAlignment = .center
        label.layer.cornerRadius = 7
        label.layer.masksToBounds = true
        return label
    }()

    private let addMenuView = CalendarAddMenuView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        setupHourGrid()
        setupNowMarker()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        nowTimer?.invalidate()
    }


    func configure(with tasks: [TaskItem], selectedDate: Date) {
        self.selectedDate = selectedDate
        isToday = Calendar.current.isDateInToday(selectedDate)
        tasksSnapshot = tasks
        rebuildTimeline()
        scheduleNowTimerIfNeeded()
        autoScrollIfNeeded()
    }


    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        addSubview(addMenuView)

        scrollView.accessibilityLabel = "Полотно задач"
        scrollView.accessibilityHint = "Сведите или разведите два пальца, чтобы сжать или растянуть время"
        setupVerticalPinch()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            addMenuView.topAnchor.constraint(equalTo: topAnchor),
            addMenuView.leadingAnchor.constraint(equalTo: leadingAnchor),
            addMenuView.trailingAnchor.constraint(equalTo: trailingAnchor),
            addMenuView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addMenuView.onSelection = { [weak self] kind in
            self?.onAddItemSelected?(kind)
        }
    }

    private func setupVerticalPinch() {
        scrollView.pinchGestureRecognizer?.isEnabled = false
        scrollView.panGestureRecognizer.maximumNumberOfTouches = 1

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleVerticalPinch(_:)))
        scrollView.addGestureRecognizer(pinch)
    }

    private func setupHourGrid() {
        for hour in 0..<25 {
            let line = UIView()
            line.backgroundColor = UIColor(rgb: 0x3C3C43, alpha: 0.08)
            contentView.addSubview(line)
            hourLines.append(line)

            guard hour < 24 else { continue }
            let label = UILabel()
            label.text = String(format: "%02d:00", hour)
            label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.4)
            label.textAlignment = .right
            contentView.addSubview(label)
            hourLabels.append(label)
        }
    }

    private func setupNowMarker() {
        contentView.addSubview(nowLineView)
        contentView.addSubview(nowDotView)
        contentView.addSubview(nowTimeLabel)
    }


    private func rebuildTimeline() {
        cardViews.forEach { $0.removeFromSuperview() }
        gapViews.forEach { $0.removeFromSuperview() }
        cardViews = []
        gapViews = []

        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart.addingTimeInterval(86_400)

        timelineRows = tasksSnapshot
            .flatMap(makeRows)
            .filter { effectiveEnd($0.task) > dayStart && $0.task.startDate < dayEnd }
            .sorted { $0.task.startDate < $1.task.startDate }

        recalculateLayoutItems(dayStart: dayStart, dayEnd: dayEnd)

        gaps = computeGaps(rows: timelineRows, dayStart: dayStart, dayEnd: dayEnd)

        for item in layoutItems {
            let card = TimelineTaskCardView(
                row: item.row,
                schedule: scheduleString(item.row.task),
                isHighPriority: item.row.task.importance >= 8,
                style: categoryStyle(for: item.row.typeTitle)
            )
            card.onEdit = { [weak self] in
                self?.onTaskSelected?(item.row.task)
            }
            card.onToggle = { [weak self] in
                self?.onTaskToggled?(item.row.task.id)
            }
            card.onDelete = { [weak self] in
                self?.onTaskDeleteRequested?(item.row.task.id)
            }
            contentView.addSubview(card)
            cardViews.append(card)
        }

        for gap in gaps {
            let view = GapOverlayView(
                durationText: "Пропуск \(gapDurationString(gap.duration))",
                rangeText: "\(timeString(gap.startDate)) – \(timeString(gap.endDate))"
            )
            view.onAddEvent = { [weak self] in
                self?.onAddEventInGapTapped?(gap.startDate)
            }
            contentView.insertSubview(view, aboveSubview: hourLines.last ?? contentView)
            gapViews.append(view)
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTimelineContent()
    }

    private func layoutTimelineContent() {
        let width = scrollView.bounds.width
        guard width > 0 else { return }

        let contentHeight = TimelineMetrics.contentHeight(hourHeight: timelineHourHeight)
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: contentHeight)
        scrollView.contentSize = contentView.bounds.size

        for (hour, line) in hourLines.enumerated() {
            let y = TimelineMetrics.topPadding + CGFloat(hour) * timelineHourHeight
            line.frame = CGRect(
                x: TimelineMetrics.gridLeading,
                y: y,
                width: width - TimelineMetrics.gridLeading - TimelineMetrics.trailingPadding,
                height: 0.5
            )
        }

        for (hour, label) in hourLabels.enumerated() {
            let y = TimelineMetrics.topPadding + CGFloat(hour) * timelineHourHeight
            label.frame = CGRect(
                x: 12,
                y: y - 7,
                width: TimelineMetrics.timeColumnWidth,
                height: 14
            )
        }

        let availableWidth = width - TimelineMetrics.cardLeading - TimelineMetrics.trailingPadding

        for (view, item) in zip(cardViews, layoutItems) {
            let columnWidth = (availableWidth - CGFloat(item.columnCount - 1) * TimelineMetrics.columnSpacing)
                / CGFloat(item.columnCount)
            view.frame = CGRect(
                x: TimelineMetrics.cardLeading + CGFloat(item.column) * (columnWidth + TimelineMetrics.columnSpacing),
                y: item.startY,
                width: columnWidth,
                height: item.height
            )
        }

        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        for (view, gap) in zip(gapViews, gaps) {
            let startY = yPosition(for: gap.startDate, dayStart: dayStart)
            let endY = yPosition(for: gap.endDate, dayStart: dayStart)
            view.frame = CGRect(
                x: TimelineMetrics.cardLeading,
                y: startY + 4,
                width: availableWidth,
                height: max(endY - startY - 8, 0)
            )
        }

        layoutNowMarker()
    }

    private func layoutNowMarker() {
        let visible = isToday
        nowLineView.isHidden = !visible
        nowDotView.isHidden = !visible
        nowTimeLabel.isHidden = !visible
        guard visible else { return }

        let width = contentView.bounds.width
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let y = yPosition(for: Date(), dayStart: dayStart)

        nowTimeLabel.text = timeString(Date())
        nowTimeLabel.frame = CGRect(x: 10, y: y - 9, width: TimelineMetrics.timeColumnWidth + 2, height: 18)
        nowDotView.frame = CGRect(x: TimelineMetrics.gridLeading - 1, y: y - 5, width: 10, height: 10)
        nowLineView.frame = CGRect(
            x: TimelineMetrics.gridLeading + 8,
            y: y - 1,
            width: width - TimelineMetrics.gridLeading - 8 - TimelineMetrics.trailingPadding,
            height: 2
        )

        contentView.bringSubviewToFront(nowLineView)
        contentView.bringSubviewToFront(nowDotView)
        contentView.bringSubviewToFront(nowTimeLabel)
        startNowPulse()
    }

    private func startNowPulse() {
        guard nowDotView.layer.animation(forKey: "pulse") == nil else { return }
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.4
        pulse.duration = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        nowDotView.layer.add(pulse, forKey: "pulse")
    }

    private func scheduleNowTimerIfNeeded() {
        nowTimer?.invalidate()
        guard isToday else { return }
        nowTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.layoutNowMarker()
        }
    }

    private func autoScrollIfNeeded() {
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        guard lastAutoScrolledDay != dayStart else { return }
        lastAutoScrolledDay = dayStart

        layoutIfNeeded()

        let targetY: CGFloat
        if isToday {
            targetY = yPosition(for: Date(), dayStart: dayStart) - 170
        } else if let first = layoutItems.first {
            targetY = first.startY - 60
        } else {
            targetY = 8 * timelineHourHeight
        }

        let maxOffset = max(0, scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(CGPoint(x: 0, y: min(max(0, targetY), maxOffset)), animated: false)
    }


    private func yPosition(for date: Date, dayStart: Date) -> CGFloat {
        let seconds = date.timeIntervalSince(dayStart)
        let clamped = max(0, min(seconds, 86_400))
        return TimelineMetrics.topPadding + CGFloat(clamped / 3600) * timelineHourHeight
    }

    private func applyTimelineHourHeight(
        _ hourHeight: CGFloat,
        anchorHour: CGFloat,
        viewportY: CGFloat
    ) {
        let clampedHeight = min(
            TimelineMetrics.maximumHourHeight,
            max(TimelineMetrics.minimumHourHeight, hourHeight)
        )
        guard abs(clampedHeight - timelineHourHeight) > 0.01 else { return }

        timelineHourHeight = clampedHeight
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)
            ?? dayStart.addingTimeInterval(86_400)
        recalculateLayoutItems(dayStart: dayStart, dayEnd: dayEnd)
        layoutTimelineContent()

        let anchoredContentY = TimelineMetrics.topPadding + anchorHour * timelineHourHeight
        let desiredOffsetY = anchoredContentY - viewportY
        let maxOffsetY = max(
            0,
            scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
        )
        scrollView.contentOffset = CGPoint(
            x: 0,
            y: min(max(0, desiredOffsetY), maxOffsetY)
        )
    }

    @objc private func handleVerticalPinch(_ recognizer: UIPinchGestureRecognizer) {
        let viewportY = recognizer.location(in: self).y

        switch recognizer.state {
        case .began:
            pinchStartHourHeight = timelineHourHeight
            pinchAnchorViewportY = viewportY
            let contentY = scrollView.contentOffset.y + viewportY
            pinchAnchorHour = max(
                0,
                min(24, (contentY - TimelineMetrics.topPadding) / timelineHourHeight)
            )
        case .changed:
            pinchAnchorViewportY = viewportY
            applyTimelineHourHeight(
                pinchStartHourHeight * recognizer.scale,
                anchorHour: pinchAnchorHour,
                viewportY: pinchAnchorViewportY
            )
        default:
            break
        }
    }
}


// MARK: - Формирование строк, время и форматирование

private extension CalendarTaskListView {

    func recalculateLayoutItems(dayStart: Date, dayEnd: Date) {
        let scaledMinimumCardHeight = max(
            14,
            TimelineMetrics.minCardHeight * timelineHourHeight / TimelineMetrics.defaultHourHeight
        )

        layoutItems = timelineRows.map { row in
            let start = max(row.task.startDate, dayStart)
            let end = min(max(effectiveEnd(row.task), start.addingTimeInterval(15 * 60)), dayEnd)
            let startY = yPosition(for: start, dayStart: dayStart)
            let endY = yPosition(for: end, dayStart: dayStart)
            return TaskLayoutItem(
                row: row,
                startY: startY,
                height: max(endY - startY, scaledMinimumCardHeight)
            )
        }
        assignColumns(&layoutItems)
    }

    func computeGaps(rows: [CalendarTaskRow], dayStart: Date, dayEnd: Date) -> [TimelineGap] {
        var result: [TimelineGap] = []
        var cursor = dayStart

        for row in rows {
            let taskStart = max(row.task.startDate, dayStart)
            if taskStart.timeIntervalSince(cursor) >= 25 * 60 {
                result.append(TimelineGap(startDate: cursor, endDate: taskStart))
            }
            let taskEnd = min(max(effectiveEnd(row.task), taskStart), dayEnd)
            cursor = max(cursor, taskEnd)
        }

        if dayEnd.timeIntervalSince(cursor) >= 25 * 60 {
            result.append(TimelineGap(startDate: cursor, endDate: dayEnd))
        }
        return result
    }

    func assignColumns(_ items: inout [TaskLayoutItem]) {
        var active: [(endY: CGFloat, column: Int)] = []
        var clusterStart = 0
        var clusterColumns = 1

        for index in items.indices {
            let item = items[index]
            active.removeAll { $0.endY <= item.startY + 0.5 }

            if active.isEmpty {
                for j in clusterStart..<index {
                    items[j].columnCount = clusterColumns
                }
                clusterStart = index
                clusterColumns = 1
            }

            let used = Set(active.map(\.column))
            var column = 0
            while used.contains(column) { column += 1 }

            items[index].column = column
            active.append((endY: item.endY, column: column))
            clusterColumns = max(clusterColumns, column + 1)
        }

        for j in clusterStart..<items.count {
            items[j].columnCount = clusterColumns
        }
    }

    func makeRows(for task: TaskItem) -> [CalendarTaskRow] {
        if task.isHardTask && !task.subtasks.isEmpty {
            return task.subtasks.map {
                CalendarTaskRow(task: $0, mainTaskName: task.name, typeTitle: "Подзадача")
            }
        }

        let typeTitle = task.source == .calendar ? "Событие" : (task.isHardTask ? "Сложная задача" : "Задача")
        return [CalendarTaskRow(task: task, mainTaskName: nil, typeTitle: typeTitle)]
    }

    /// Конец блока задачи на таймлайне: для однодневных — дедлайн,
    /// для многодневных — старт + планируемая длительность.
    private func effectiveEnd(_ task: TaskItem) -> Date {
        if Calendar.current.isDate(task.startDate, inSameDayAs: task.deadlineDate) {
            return task.deadlineDate
        }
        return task.startDate.addingTimeInterval(max(15 * 60, task.estimatedDuration))
    }

    private func effectiveDuration(_ task: TaskItem) -> TimeInterval {
        if task.estimatedDuration > 0 { return task.estimatedDuration }
        return max(0, task.deadlineDate.timeIntervalSince(task.startDate))
    }

    private func scheduleString(_ task: TaskItem) -> String {
        let duration = durationString(effectiveDuration(task))

        if Calendar.current.isDate(task.startDate, inSameDayAs: task.deadlineDate) {
            return "\(timeString(task.startDate)) – \(timeString(task.deadlineDate)) · \(duration)"
        }
        return "\(timeString(task.startDate)) · до \(shortDateString(task.deadlineDate)) · \(duration)"
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func shortDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    private func durationString(_ duration: TimeInterval) -> String {
        let mins = max(0, Int(duration / 60))
        if mins < 60 { return "\(mins) мин" }
        let hours = mins / 60
        let minutes = mins % 60
        return minutes == 0 ? "\(hours) ч" : "\(hours) ч \(minutes) мин"
    }

    private func gapDurationString(_ duration: TimeInterval) -> String {
        let minutesTotal = max(0, Int(duration / 60))
        let hours = minutesTotal / 60
        let minutes = minutesTotal % 60

        if hours == 0 {
            return "\(minutes) \(plural(minutes, one: "минута", few: "минуты", many: "минут"))"
        }

        let hourText = "\(hours) \(plural(hours, one: "час", few: "часа", many: "часов"))"
        guard minutes > 0 else { return hourText }
        let minuteText = "\(minutes) \(plural(minutes, one: "минута", few: "минуты", many: "минут"))"
        return "\(hourText) \(minuteText)"
    }

    private func plural(_ value: Int, one: String, few: String, many: String) -> String {
        let mod10 = value % 10
        let mod100 = value % 100
        if mod10 == 1 && mod100 != 11 { return one }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return few }
        return many
    }

    private func categoryStyle(for typeTitle: String) -> TimelineCategoryStyle {
        switch typeTitle.lowercased() {
        case "событие":
            return TimelineCategoryStyle(
                sfSymbol: "calendar",
                tileColor: UIColor(rgb: 0xDCEBFF),
                tintColor: .appInfo
            )
        case "подзадача":
            return TimelineCategoryStyle(
                sfSymbol: "list.bullet",
                tileColor: UIColor(rgb: 0xD8F5E3),
                tintColor: UIColor(rgb: 0x0A7D4D)
            )
        case "сложная задача":
            return TimelineCategoryStyle(
                sfSymbol: "square.stack.3d.up.fill",
                tileColor: UIColor(rgb: 0xEAE2FF),
                tintColor: .appSleepPurple
            )
        default:
            return TimelineCategoryStyle(
                sfSymbol: "doc.text",
                tileColor: .lightMain,
                tintColor: .main
            )
        }
    }
}


// MARK: - Стиль категории

private struct TimelineCategoryStyle {
    let sfSymbol: String
    let tileColor: UIColor
    let tintColor: UIColor
}


// MARK: - Карточка задачи на таймлайне

private final class TimelineTaskCardView: UIControl {

    var onEdit: (() -> Void)?
    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?

    private let row: CalendarTaskRow
    private let style: TimelineCategoryStyle

    private let accentBar = UIView()
    private let iconTile = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priorityDot = UIView()
    private let completeButton = UIButton(type: .custom)

    init(row: CalendarTaskRow, schedule: String, isHighPriority: Bool, style: TimelineCategoryStyle) {
        self.row = row
        self.style = style
        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = 12
        applyCardShadow(strength: 0.6)

        accentBar.backgroundColor = row.task.isCompleted ? .appSuccess : style.tintColor
        accentBar.layer.cornerRadius = 1.5
        accentBar.isUserInteractionEnabled = false
        addSubview(accentBar)

        iconTile.backgroundColor = style.tileColor
        iconTile.layer.cornerRadius = 8
        iconTile.isUserInteractionEnabled = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iconView.image = UIImage(systemName: style.sfSymbol, withConfiguration: cfg)
        iconView.tintColor = style.tintColor
        iconView.contentMode = .center
        iconTile.addSubview(iconView)
        addSubview(iconTile)

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.isUserInteractionEnabled = false
        setTitleText()
        addSubview(titleLabel)

        var subtitleParts: [String] = []
        if let mainName = row.mainTaskName, !mainName.isEmpty {
            subtitleParts.append("из «\(mainName)»")
        }
        subtitleParts.append(schedule)
        subtitleLabel.text = subtitleParts.joined(separator: " · ")
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.5)
        subtitleLabel.isUserInteractionEnabled = false
        addSubview(subtitleLabel)

        priorityDot.backgroundColor = .appWarning
        priorityDot.layer.cornerRadius = 3
        priorityDot.isHidden = !isHighPriority
        priorityDot.isUserInteractionEnabled = false
        addSubview(priorityDot)

        let checkCfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        completeButton.setImage(UIImage(systemName: "circle", withConfiguration: checkCfg), for: .normal)
        completeButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkCfg), for: .selected)
        completeButton.isSelected = row.task.isCompleted
        completeButton.tintColor = row.task.isCompleted ? .appSuccess : UIColor(rgb: 0x3C3C43, alpha: 0.25)
        completeButton.isHidden = !row.canEdit
        completeButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        completeButton.enablePressScale()
        addSubview(completeButton)

        alpha = row.task.isCompleted ? 0.62 : 1

        if row.canEdit {
            addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
            addInteraction(UIContextMenuInteraction(delegate: self))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setTitleText() {
        if row.task.isCompleted {
            titleLabel.attributedText = NSAttributedString(
                string: row.task.name,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        } else {
            titleLabel.text = row.task.name
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let h = bounds.height
        let compact = h < 44
        let showsIcon = h >= 64
        let showsSubtitle = h >= 44

        accentBar.frame = CGRect(x: 5, y: 5, width: 3, height: max(h - 10, 8))

        let checkSize: CGFloat = 26
        let checkVisible = !completeButton.isHidden
        completeButton.frame = CGRect(
            x: bounds.width - checkSize - 6,
            y: compact ? (h - checkSize) / 2 : 7,
            width: checkSize,
            height: checkSize
        )

        let tileSize: CGFloat = 26
        iconTile.isHidden = !showsIcon
        if showsIcon {
            iconTile.frame = CGRect(x: 14, y: 10, width: tileSize, height: tileSize)
            iconView.frame = iconTile.bounds
        }

        let textX: CGFloat = showsIcon ? 14 + tileSize + 8 : 14
        let textRight = bounds.width - (checkVisible ? checkSize + 10 : 10)
        let textWidth = max(textRight - textX, 20)

        titleLabel.font = .systemFont(ofSize: compact ? 12 : 14, weight: .semibold)
        subtitleLabel.isHidden = !showsSubtitle

        if compact {
            titleLabel.frame = CGRect(x: textX, y: 0, width: textWidth - 12, height: h)
        } else if showsSubtitle {
            titleLabel.frame = CGRect(x: textX, y: 8, width: textWidth - 12, height: 18)
            subtitleLabel.frame = CGRect(x: textX, y: 26, width: textWidth, height: 14)
        }

        let titleTextWidth = min(
            titleLabel.intrinsicContentSize.width,
            titleLabel.frame.width
        )
        priorityDot.frame = CGRect(
            x: titleLabel.frame.minX + titleTextWidth + 5,
            y: titleLabel.frame.midY - 3,
            width: 6,
            height: 6
        )
    }

    @objc private func cardTapped() {
        onEdit?()
    }

    @objc private func toggleTapped() {
        onToggle?()
    }

    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }

            let edit = UIAction(
                title: "Изменить",
                image: UIImage(systemName: "pencil")
            ) { _ in
                self.onEdit?()
            }

            let isCompleted = self.row.task.isCompleted
            let complete = UIAction(
                title: isCompleted ? "Вернуть в работу" : "Выполнить",
                image: UIImage(systemName: isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle")
            ) { _ in
                self.onToggle?()
            }

            let delete = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.onDelete?()
            }

            return UIMenu(title: self.row.task.name, children: [edit, complete, delete])
        }
    }
}


// MARK: - Пропуск на таймлайне

private final class GapOverlayView: UIView {

    var onAddEvent: (() -> Void)?

    private let durationChip = UIButton(type: .system)
    private let addButton = UIButton(type: .system)
    private let contentStack = UIStackView()

    init(durationText: String, rangeText: String) {
        super.init(frame: .zero)

        var chipConfig = UIButton.Configuration.filled()
        chipConfig.baseBackgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.92)
        chipConfig.baseForegroundColor = .secondaryLabel
        chipConfig.cornerStyle = .capsule
        chipConfig.image = UIImage(systemName: "clock")
        chipConfig.imagePadding = 5
        chipConfig.attributedTitle = AttributedString(
            durationText,
            attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 12, weight: .semibold)])
        )
        chipConfig.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 11, bottom: 6, trailing: 11)
        durationChip.configuration = chipConfig
        durationChip.isUserInteractionEnabled = false

        var addConfig = UIButton.Configuration.filled()
        addConfig.baseBackgroundColor = .main
        addConfig.baseForegroundColor = .white
        addConfig.cornerStyle = .capsule
        addConfig.image = UIImage(systemName: "plus")
        addConfig.imagePadding = 5
        addConfig.attributedTitle = AttributedString(
            "Событие · \(rangeText)",
            attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 12, weight: .semibold)])
        )
        addConfig.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 11, bottom: 6, trailing: 11)
        addButton.configuration = addConfig
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.enablePressScale()

        contentStack.axis = .vertical
        contentStack.spacing = 7
        contentStack.alignment = .center
        contentStack.addArrangedSubview(durationChip)
        contentStack.addArrangedSubview(addButton)
        addSubview(contentStack)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let h = bounds.height
        let tall = h >= 96
        contentStack.axis = tall ? .vertical : .horizontal
        contentStack.spacing = tall ? 7 : 8

        durationChip.isHidden = h < 40 || (!tall && bounds.width < 300)
        addButton.isHidden = h < 40

        let size = contentStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let centerY = min(h / 2, 34 + size.height / 2)
        contentStack.frame = CGRect(
            x: (bounds.width - size.width) / 2,
            y: centerY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    @objc private func addTapped() {
        onAddEvent?()
    }
}
