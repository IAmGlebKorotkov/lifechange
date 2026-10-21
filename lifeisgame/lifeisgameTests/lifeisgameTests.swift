//
//  lifeisgameTests.swift
//  lifeisgameTests
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import XCTest
import UIKit
@testable import lifeisgame

final class LifeisgameTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    @MainActor
    func testIntensityColorsChangeContinuouslyWithSliderValue() throws {
        let intensityView = DiaryIntensityView()
        let slider = try XCTUnwrap(intensityView.descendants(ofType: UISlider.self).first)
        let badge = try XCTUnwrap(
            intensityView.descendants(ofType: UILabel.self).first(where: { $0.text == "5 / 10" })
        )

        slider.value = 5
        slider.sendActions(for: .valueChanged)
        let initialTrackColor = try rgbaComponents(of: slider.minimumTrackTintColor)
        let initialBadgeColor = try rgbaComponents(of: badge.backgroundColor)

        slider.value = 5.2
        slider.sendActions(for: .valueChanged)

        XCTAssertNotEqual(initialTrackColor, try rgbaComponents(of: slider.minimumTrackTintColor))
        XCTAssertNotEqual(initialBadgeColor, try rgbaComponents(of: badge.backgroundColor))
    }

    @MainActor
    func testEmotionStatsContentIsClippedToItsViewport() throws {
        let statsView = EmotionStatsView()
        let scrollView = try XCTUnwrap(statsView.descendants(ofType: UIScrollView.self).first)

        XCTAssertTrue(
            scrollView.clipsToBounds,
            "Scrolled statistics must not draw over the pinned screen chrome"
        )
    }

    @MainActor
    func testDiaryHeaderCollapsesWhenEmotionDiaryScrolls() throws {
        let viewController = DiaryViewController(
            viewModel: DiaryViewModel(diaryService: DiaryService())
        )

        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        viewController.view.layoutIfNeeded()

        let title = try XCTUnwrap(
            viewController.view
                .descendants(ofType: UILabel.self)
                .first(where: { $0.text == "Дневник" })
        )
        let picker = try XCTUnwrap(
            viewController.view.descendants(ofType: DiaryPickerView.self).first
        )
        let emotionView = try XCTUnwrap(
            viewController.view.descendants(ofType: EmotionDiaryView.self).first
        )
        let scrollView = try XCTUnwrap(
            emotionView.descendants(ofType: UIScrollView.self).first
        )

        scrollView.contentOffset = CGPoint(x: 0, y: 80)
        scrollView.delegate?.scrollViewDidScroll?(scrollView)

        XCTAssertEqual(title.alpha, 0, accuracy: 0.01)
        XCTAssertLessThan(picker.transform.ty, 0)
    }

    @MainActor
    func testEmotionAndSleepDiaryScrollViewsTrackAndClipTheirContent() throws {
        let emotionView = EmotionDiaryView()
        let sleepView = SleepDiaryView()
        let emotionScrollView = try XCTUnwrap(
            emotionView.descendants(ofType: UIScrollView.self).first
        )
        let sleepScrollView = try XCTUnwrap(
            sleepView.descendants(ofType: UIScrollView.self).first
        )
        var emotionOffset: CGFloat?
        var sleepOffset: CGFloat?
        emotionView.onVerticalScroll = { emotionOffset = $0 }
        sleepView.onVerticalScroll = { sleepOffset = $0 }

        emotionScrollView.contentOffset = CGPoint(x: 0, y: 40)
        emotionScrollView.delegate?.scrollViewDidScroll?(emotionScrollView)
        sleepScrollView.contentOffset = CGPoint(x: 0, y: 60)
        sleepScrollView.delegate?.scrollViewDidScroll?(sleepScrollView)

        XCTAssertTrue(emotionScrollView.clipsToBounds)
        XCTAssertTrue(sleepScrollView.clipsToBounds)
        XCTAssertNotNil(emotionScrollView.delegate)
        XCTAssertNotNil(sleepScrollView.delegate)
        XCTAssertEqual(emotionOffset, 40)
        XCTAssertEqual(sleepOffset, 60)
    }

    @MainActor
    func testProfileLevelCardShowsProgressAndCollectedCaption() throws {
        let item = AchievementItem(
            id: UUID(),
            code: "test_opened",
            kind: .tasks,
            icon: "checkmark",
            title: "Тест",
            goal: "Тестовая цель",
            currentValue: 1,
            targetValue: 1,
            state: .opened,
            cellHeight: 160,
            unlockedAt: Date(),
            openedAt: Date()
        )
        let card = ProfileLevelCardView()
        card.configure(with: AchievementLevelProgress(items: [item]))
        card.frame = CGRect(x: 0, y: 0, width: 350, height: 140)
        card.layoutIfNeeded()

        let track = try XCTUnwrap(
            card.descendants(ofType: UIView.self)
                .first(where: { abs($0.bounds.height - 8) < 0.5 && $0.bounds.width > 100 })
        )
        let fill = try XCTUnwrap(
            track.subviews.first(where: { abs($0.bounds.height - 8) < 0.5 })
        )
        let caption = try XCTUnwrap(
            card.descendants(ofType: UILabel.self)
                .first(where: { $0.text?.hasPrefix("Собрано достижений:") == true })
        )

        XCTAssertEqual(fill.bounds.width, track.bounds.width * 0.2, accuracy: 1)
        XCTAssertGreaterThan(caption.bounds.height, 0)
    }

    @MainActor
    func testProfileHidesFaceIDRowWithoutLeavingAGapWhenUnsupported() throws {
        let viewModel = ProfileViewModel(
            authService: AuthService(),
            diaryService: DiaryService(),
            achievementService: AchievementService(),
            faceIDAvailabilityProvider: FaceIDAvailabilityStub(supportsFaceID: false)
        )
        let viewController = ProfileViewController(viewModel: viewModel)

        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        viewController.view.layoutIfNeeded()

        let rows = viewController.view.descendants(ofType: ProfileToggleRow.self)
        let faceIDRow = try XCTUnwrap(
            rows.first(where: { row in
                row.descendants(ofType: UILabel.self).contains(where: { $0.text == "Вход через Face ID" })
            })
        )
        let notificationsRow = try XCTUnwrap(
            rows.first(where: { row in
                row.descendants(ofType: UILabel.self).contains(where: { $0.text == "Уведомления" })
            })
        )
        let passwordField = try XCTUnwrap(
            viewController.view
                .descendants(ofType: ProfileTextField.self)
                .max(by: {
                    $0.convert($0.bounds, to: viewController.view).minY
                        < $1.convert($1.bounds, to: viewController.view).minY
                })
        )

        let passwordFrame = passwordField.convert(passwordField.bounds, to: viewController.view)
        let notificationsFrame = notificationsRow.convert(notificationsRow.bounds, to: viewController.view)

        XCTAssertTrue(faceIDRow.isHidden)
        XCTAssertEqual(notificationsFrame.minY - passwordFrame.maxY, 20, accuracy: 1)
    }

}

private struct FaceIDAvailabilityStub: FaceIDAvailabilityProviding {
    let supportsFaceID: Bool
}

private func rgbaComponents(of color: UIColor?) throws -> [CGFloat] {
    let color = try XCTUnwrap(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    XCTAssertTrue(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
    return [red, green, blue, alpha]
}

private extension UIView {
    func descendants<T: UIView>(ofType type: T.Type) -> [T] {
        subviews.flatMap { subview in
            (subview as? T).map { [$0] } ?? []
                + subview.descendants(ofType: type)
        }
    }
}
