//
//  MainTabBarController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class MainTabBarController: UIViewController {


    private let tabBarFrameHeight: CGFloat = 16 + 64


    private let tabBar = CustomTabBar()


    private var childControllers: [UIViewController] = []
    private var currentIndex: Int = 0


    func configure(with viewControllers: [UIViewController]) {
        childControllers = viewControllers
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupTabBar()
        select(index: 0)
    }


    private func setupTabBar() {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            tabBar.heightAnchor.constraint(equalToConstant: tabBarFrameHeight)
        ])

        tabBar.onTabSelected = { [weak self] index in
            self?.select(index: index)
        }
    }


    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.tabBar.alpha = hidden ? 0 : 1
        }
        tabBar.isUserInteractionEnabled = !hidden
    }


    private func select(index: Int) {
        guard index != currentIndex || childControllers[index].parent == nil else { return }

        if childControllers[currentIndex].parent != nil {
            let old = childControllers[currentIndex]
            old.willMove(toParent: nil)
            old.view.removeFromSuperview()
            old.removeFromParent()
        }

        let new = childControllers[index]
        addChild(new)
        view.insertSubview(new.view, belowSubview: tabBar)
        new.view.frame = view.bounds
        new.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        new.didMove(toParent: self)

        currentIndex = index
        tabBar.selectedIndex = index
    }
}
