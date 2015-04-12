//
//  DayFilterNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 12.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class DayFilterNode: ASCellNode {
    let text: String
    private let accessoryNode = ASImageNode()
    private let textNode = ASTextNode()
    private let textParams = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody) ]
    private let checkmark = UIImage(named: "icon-checkmark")
    var selected: Bool = false {
        didSet {
            accessoryNode.hidden = selected ? false : true
        }
    }
    private let marginH: CGFloat = 16.0
    private let marginV: CGFloat = 8.0

    required init(text: String) {
        self.text = text
        super.init()
        selectionStyle = UITableViewCellSelectionStyle.None

        textNode.attributedString = NSAttributedString(string: self.text, attributes: textParams)
        accessoryNode.image = checkmark
        accessoryNode.hidden = true

        addSubnode(textNode)
        addSubnode(accessoryNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let imageSize = accessoryNode.image.size
        let checkSize = CGSizeMake(constrainedSize.width - imageSize.width - marginH * 3.0, CGFloat.max)
        let textSize = textNode.measure(checkSize)
        let maxHeight = max(textSize.height, imageSize.height)
        return CGSizeMake(constrainedSize.width, maxHeight + marginV * 2.0)
    }

    override func layout() {
        let imageSize = accessoryNode.image.size
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(marginH, (calculatedSize.height - textSize.height) / 2.0, textSize.width, textSize.height)
        accessoryNode.frame = CGRectMake(calculatedSize.width - imageSize.width - marginH, (calculatedSize.height - imageSize.height) / 2.0, imageSize.width, imageSize.height)
    }
}
