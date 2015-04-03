//
//  TagCloudNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 02.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class TagCloudNode: ASCellNode {
    let tags: [String]
    var tagButtons = [TagButtonNode]()
    var origins = [CGPoint]()
    let marginH: CGFloat = 8.0
    let marginV: CGFloat = 8.0

    required init(tags: [String]) {
//        self.tags = tags
        self.tags = [ "квест", "история", "дом-музей", "беседа", "бал", "игровое занятие", "фильм", "поэзия", "мастер-класс", "выставка", "очень длинное название тега, воу воу воу", "my head is shaped like a frisbee twice its normal size" ]
        super.init()

        for tag in self.tags {
            let tagButton = TagButtonNode(tagStr: tag)
            tagButtons.append(tagButton)
            addSubnode(tagButton)
        }
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        var tagButtonHeight: CGFloat = 0.0
        let maxWidth = constrainedSize.width - 2 * marginH
        var rollingOrigin = CGPointMake(marginH, marginV)
        for tagButton in tagButtons {
            let textSize = tagButton.measure(CGSizeMake(maxWidth, CGFloat.max))
            if tagButtonHeight == 0.0 {
                tagButtonHeight = textSize.height
            }
            if textSize.width > (maxWidth - rollingOrigin.x - marginH) {
                rollingOrigin = CGPointMake(marginH, rollingOrigin.y + tagButtonHeight)
            }
            origins.append(rollingOrigin)
            rollingOrigin.x += textSize.width
        }
        return CGSizeMake(constrainedSize.width, rollingOrigin.y + tagButtonHeight + marginV)
    }

    override func layout() {
        for var i = 0; i < tagButtons.count && i < origins.count; i++ {
            let tagButton = tagButtons[i]
            let origin = origins[i]
            let tagSize = tagButton.calculatedSize
            tagButton.frame = CGRectMake(origin.x, origin.y, tagSize.width, tagSize.height)
        }
    }
}
