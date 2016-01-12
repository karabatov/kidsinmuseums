//
//  FilterMuseumNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 10.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import CoreLocation

class FilterMuseumNode: ASCellNode {
    let museum: Museum
    var selected: Bool = false {
        didSet {
            accessoryNode.image = selected ? UIImage(named: "icon-checked") : UIImage(named: "icon-unchecked")
        }
    }
    let titleNode = ASTextNode()
    let addressNode = ASTextNode()
    let accessoryNode = ASImageNode()
    let dividerNode = ASDisplayNode()
    let marginH: CGFloat = 16.0
    let marginIntra: CGFloat = 8.0
    let marginV: CGFloat = 6.0

    required init(museum: Museum, location: CLLocation?) {
        self.museum = museum
        super.init()
        selectionStyle = UITableViewCellSelectionStyle.None
        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        let museumParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)]

        let titleStr = NSAttributedString(string: museum.name, attributes: headingParams)
        titleNode.attributedString = titleStr

        let museumStr = NSMutableAttributedString()
        if let loc = location {
            let distance = self.museum.distanceFromLocation(loc)
            let locStr = NSAttributedString(string: "\(distance.humanReadable()) \u{25b8} ", attributes: museumParams)
            museumStr.appendAttributedString(locStr)
        }

        let museumAddressStr = NSAttributedString(string: museum.address, attributes: museumParams)
        museumStr.appendAttributedString(museumAddressStr)
        addressNode.attributedString = museumStr

        accessoryNode.image = UIImage(named: "icon-unchecked")

        dividerNode.backgroundColor = UIColor.lightGrayColor()

        addSubnode(titleNode)
        addSubnode(addressNode)
        addSubnode(accessoryNode)
        addSubnode(dividerNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let imageSize = accessoryNode.image.size
        let textSize = CGSizeMake(constrainedSize.width - marginH * 2.0 - imageSize.width - marginIntra, CGFloat.max)
        let titleSize = titleNode.measure(textSize)
        let addressSize = addressNode.measure(textSize)
        let maxHeight: CGFloat = max(imageSize.height, titleSize.height + addressSize.height + marginV)
        return CGSizeMake(constrainedSize.width, maxHeight + marginV * 2.0)
    }

    override func layout() {
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        dividerNode.frame = CGRectMake(0.0, 0.0, calculatedSize.width, pixelHeight)
        let imageSize = accessoryNode.image.size
        let titleSize = titleNode.calculatedSize
        let addressSize = addressNode.calculatedSize

        accessoryNode.frame = CGRectMake(marginH, (calculatedSize.height - imageSize.height) / 2.0, imageSize.width, imageSize.height)
        let hiddenSize = accessoryNode.hidden ? 0 : imageSize.width + marginIntra
        titleNode.frame = CGRectMake(marginH + hiddenSize, marginV, titleSize.width, titleSize.height)
        addressNode.frame = CGRectMake(marginH + hiddenSize, marginV + titleSize.height + marginIntra, addressSize.width, addressSize.height)
    }
}
