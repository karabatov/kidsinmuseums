//
//  MuseumInfoController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 19.06.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class MuseumInfoController: UIViewController {
    var museum: Museum? {
        didSet {
            setNewMuseum(museum)
        }
    }
    var museumInfoView: MuseumInfoView?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let musInfo = museumInfoView {
            if musInfo.superview == nil {
                view.addSubview(musInfo)
            }

            musInfo.frame = view.bounds
        }
    }

    func setNewMuseum(newMuseum: Museum?) {
        if let musInfo = museumInfoView {
            musInfo.removeFromSuperview()
        }

        if let museum = newMuseum {
            title = museum.name

            museumInfoView = MuseumInfoView(museum: museum, maxWidth: UIScreen.mainScreen().applicationFrame.width, showsEvents: false)
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
