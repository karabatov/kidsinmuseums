//
//  AppInfoNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 17.03.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class AppInfoNode: ASCellNode {
    let appImage = ASImageNode()
    let infoLabel = ASTextNode()
    var textParams: [NSObject: AnyObject]
    let marginH: CGFloat = 20.0
    let marginV: CGFloat = 20.0

    required init(text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimGrayColor(), NSParagraphStyleAttributeName: paragraphStyle]

        super.init()

        appImage.image = UIImage(named: "appinfo-logo")

        infoLabel.attributedString = NSAttributedString(string: text, attributes: textParams)

        self.addSubnode(appImage)
        self.addSubnode(infoLabel)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let imageSize = appImage.image.size
        let narrowSize = CGSizeMake(constrainedSize.width - 2 * marginH, CGFloat.max)
        let infoLabelSize = infoLabel.measure(narrowSize)

        return CGSizeMake(constrainedSize.width, imageSize.height + infoLabelSize.height + 3 * marginV)
    }

    override func layout() {
        let imageSize = appImage.image.size
        let infoLabelSize = infoLabel.calculatedSize

        appImage.frame = CGRectMake((calculatedSize.width - imageSize.width) / 2.0, marginV, imageSize.width, imageSize.height)
        infoLabel.frame = CGRectMake(marginH, imageSize.height + 2 * marginV, calculatedSize.width - 2 * marginH, infoLabelSize.height)
    }
}
