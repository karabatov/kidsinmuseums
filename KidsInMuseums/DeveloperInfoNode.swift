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

    required init(image: UIImage, text: String) {
        super.init()

        devLogo.image = image

        let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        let devTextStr = NSAttributedString(string: text, attributes: textParams)
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
