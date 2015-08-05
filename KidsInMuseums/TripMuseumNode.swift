//
//  TripMuseumNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 06.08.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class TripMuseumNode: ASCellNode {
    var museumFound = false
    var museum: Museum?
    let textNode = ASTextNode()
    let divider = ASDisplayNode()
    let marginH: CGFloat = 16.0
    let marginV: CGFloat = 6.0

    required init(museumId: Int) {
        if let mus = DataModel.sharedInstance.findMuseum(museumId) {
            museum = mus
            museumFound = true

            let nameParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimColor()]
            let addressParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.blackColor()]
            let titleStr = NSMutableAttributedString(string: mus.name, attributes: nameParams)
            if mus.address != "" {
                let addrStr = NSAttributedString(string: "\n\(mus.address)", attributes: addressParams)
                titleStr.appendAttributedString(addrStr)
            }
            textNode.attributedString = titleStr
        }

        super.init()

        if museumFound {
            divider.backgroundColor = UIColor.lightGrayColor()
            addSubnode(divider)
            addSubnode(textNode)
            textNode.addTarget(self, action: "openMuseum", forControlEvents: ASControlNodeEvent.TouchUpInside)
        }

        placeholderEnabled = true
        placeholderFadeDuration = 0.25
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        if museumFound {
            let textSize = textNode.measure(CGSizeMake(constrainedSize.width - marginH * 2, CGFloat.max))
            return CGSizeMake(constrainedSize.width, textSize.height + marginV * 2)
        } else {
            return CGSizeZero
        }
    }

    override func layout() {
        if museumFound {
            let textSize = textNode.calculatedSize
            textNode.frame = CGRectMake(marginH, marginV, textSize.width, textSize.height)
            let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
            divider.frame = CGRectMake(0.0, 0.0, calculatedSize.width, pixelHeight)
        }
    }

    func openMuseum() {
        if let
            mus = museum,
            delegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            controllers = delegate.tabController?.viewControllers
        {
            for (index, cntr) in enumerate(controllers) {
                if let
                    controller = cntr as? UINavigationController,
                    mapView = controller.topViewController as? MapViewController
                {
                    mapView.selectMuseum(mus)
                    delegate.tabController?.selectedIndex = index
                }
            }
        }
    }
}
