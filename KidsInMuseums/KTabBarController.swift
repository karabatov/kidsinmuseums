//
//  KTabBarController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 27.07.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class KTabBarController: UITabBarController {
    var specialProjectEnabled = false {
        didSet {
            updateSpecialProject(specialProjectEnabled)
        }
    }
    var specialButton = UIButton.buttonWithType(.Custom) as! UIButton
    let buttonImage = UIImage(named: "icon-family-trip")!

    override func viewDidLoad() {
        super.viewDidLoad()

        specialButton.addTarget(self, action: "specialButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        specialButton.frame = CGRect(x: 0.0, y: 0.0, width: buttonImage.size.width, height: buttonImage.size.height)
        specialButton.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        specialButton.hidden = true
        view.addSubview(specialButton)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if specialProjectEnabled {
            let heightDiff = buttonImage.size.height - self.tabBar.frame.size.height
            if heightDiff < 0 {
                specialButton.center = self.tabBar.center
            } else {
                var center = self.tabBar.center
                center.y -= heightDiff / 2.0
                specialButton.center = center
            }
        }
    }

    func updateSpecialProject(status: Bool) {
        specialButton.hidden = !status
    }

    func specialButtonTapped(sender: UIButton) {
        selectedIndex = 2
    }
}
