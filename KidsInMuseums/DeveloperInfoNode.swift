//
//  DeveloperInfoNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 17.03.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class DeveloperInfoNode: ASCellNode {
    let devLogo = ASImageNode()
    let devText = ASTextNode()
    let margin: CGFloat = 20.0

    required override init() {
        super.init()

        devLogo.image = UIImage(named: "appinfo-dev")

        let devStr = NSLocalizedString("Our strategies, ideas and technology. Your big goals.", comment: "About the developer text")
        let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        let devTextStr = NSAttributedString(string: devStr, attributes: textParams)
        devText.attributedString = devTextStr

        self.addSubnode(devLogo)
        self.addSubnode(devText)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let imageSize = devLogo.image.size
        let textSize = devText.measure(CGSizeMake(constrainedSize.width - imageSize.width - 3 * margin, CGFloat.max))

        return CGSizeMake(constrainedSize.width, max(imageSize.height, textSize.height) + 2 * margin)
    }

    override func layout() {
        let imageSize = devLogo.image.size
        let textSize = devText.calculatedSize

        devLogo.frame = CGRectMake(margin, margin, imageSize.width, imageSize.height)
        devText.frame = CGRectMake(2 * margin + imageSize.width, margin, textSize.width, textSize.height)
    }
}
