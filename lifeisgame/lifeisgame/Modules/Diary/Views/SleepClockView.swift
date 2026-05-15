//
//  SleepClockView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class SleepClockView: UIControl {


    var sleepDate: Date = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date() {
        didSet { setNeedsDisplay() }
    }
    var wakeDate: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date() {
        didSet { setNeedsDisplay() }
    }

    var onSleepDateChanged: ((Date) -> Void)?
    var onWakeDateChanged:  ((Date) -> Void)?


    private enum Handle { case sleep, wake }
    private var activeHandle: Handle?

    private var clockR: CGFloat    { min(bounds.width, bounds.height) / 2 - handleR - 14 }
    private let arcWidth: CGFloat  = 20
    private let handleR:  CGFloat  = 12


    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }


    override func draw(_ rect: CGRect) {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = clockR

        let bg = UIBezierPath(arcCenter: c, radius: r, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        bg.lineWidth = arcWidth
        UIColor.systemGray5.setStroke()
        bg.stroke()

        let sa = angle(for: sleepDate)
        let wa = angle(for: wakeDate)
        let ea = wa > sa ? wa : wa + 2 * .pi
        let arc = UIBezierPath(arcCenter: c, radius: r, startAngle: sa, endAngle: ea, clockwise: true)
        arc.lineWidth  = arcWidth
        arc.lineCapStyle = .round
        UIColor.main.setStroke()
        arc.stroke()

        for h in 0..<24 {
            let a       = hourAngle(h)
            let major   = h % 3 == 0
            let tickInner = r + arcWidth / 2 + 4
            let tickOuter = tickInner + (major ? 7 : 4)

            let tick = UIBezierPath()
            tick.move(to: point(c, tickInner, a))
            tick.addLine(to: point(c, tickOuter, a))
            tick.lineWidth = major ? 1.5 : 0.8
            UIColor.systemGray3.setStroke()
            tick.stroke()

            if major {
                let labelR = r - arcWidth / 2 - 16
                let pt     = point(c, labelR, a)
                let text   = "\(h)" as NSString
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let sz = text.size(withAttributes: attrs)
                text.draw(at: CGPoint(x: pt.x - sz.width / 2, y: pt.y - sz.height / 2), withAttributes: attrs)
            }
        }

        let durAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let dur = durationText() as NSString
        let sub = "сна"         as NSString
        let durSz = dur.size(withAttributes: durAttrs)
        let subSz = sub.size(withAttributes: subAttrs)
        let totalH = durSz.height + 2 + subSz.height
        dur.draw(at: CGPoint(x: c.x - durSz.width / 2, y: c.y - totalH / 2), withAttributes: durAttrs)
        sub.draw(at: CGPoint(x: c.x - subSz.width / 2, y: c.y - totalH / 2 + durSz.height + 2), withAttributes: subAttrs)

        drawHandle(center: c, r: r, a: sa)
        drawHandle(center: c, r: r, a: wa)
    }

    private func drawHandle(center: CGPoint, r: CGFloat, a: CGFloat) {
        let pt = point(center, r, a)
        UIColor.main.setFill()
        UIBezierPath(arcCenter: pt, radius: handleR, startAngle: 0, endAngle: 2 * .pi, clockwise: true).fill()
        UIColor.white.setFill()
        UIBezierPath(arcCenter: pt, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true).fill()
    }


    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let loc = touch.location(in: self)
        let sp  = point(CGPoint(x: bounds.midX, y: bounds.midY), clockR, angle(for: sleepDate))
        let wp  = point(CGPoint(x: bounds.midX, y: bounds.midY), clockR, angle(for: wakeDate))
        let sd  = hypot(loc.x - sp.x, loc.y - sp.y)
        let wd  = hypot(loc.x - wp.x, loc.y - wp.y)
        guard min(sd, wd) <= 28 else { return false }
        activeHandle = sd < wd ? .sleep : .wake
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let handle = activeHandle else { return false }
        let loc    = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let a      = atan2(loc.y - center.y, loc.x - center.x)
        let newDate = date(for: a)
        switch handle {
        case .sleep:
            sleepDate = newDate
            onSleepDateChanged?(newDate)
        case .wake:
            wakeDate = newDate
            onWakeDateChanged?(newDate)
        }
        sendActions(for: .valueChanged)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        activeHandle = nil
    }


    private func angle(for date: Date) -> CGFloat {
        let cal = Calendar.current
        let h = CGFloat(cal.component(.hour,   from: date))
        let m = CGFloat(cal.component(.minute, from: date))
        return (h + m / 60) / 24 * 2 * .pi - .pi / 2
    }

    private func hourAngle(_ h: Int) -> CGFloat {
        CGFloat(h) / 24 * 2 * .pi - .pi / 2
    }

    private func date(for angle: CGFloat) -> Date {
        var a = angle + .pi / 2
        while a < 0          { a += 2 * .pi }
        a = a.truncatingRemainder(dividingBy: 2 * .pi)
        let totalH = a / (2 * .pi) * 24
        let h = Int(totalH)
        let m = Int((totalH - CGFloat(h)) * 60)
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) ?? Date()
    }

    private func point(_ center: CGPoint, _ r: CGFloat, _ a: CGFloat) -> CGPoint {
        CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
    }

    private func durationText() -> String {
        let cal = Calendar.current
        var sm  = cal.component(.hour, from: sleepDate) * 60 + cal.component(.minute, from: sleepDate)
        var wm  = cal.component(.hour, from: wakeDate)  * 60 + cal.component(.minute, from: wakeDate)
        if wm <= sm { wm += 24 * 60 }
        let d = wm - sm
        return "\(d / 60)ч \(d % 60)м"
    }
}
