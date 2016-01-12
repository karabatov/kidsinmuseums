//
//  TagCloudNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 02.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class TagCloudNode: ASCellNode {
    var enabled = true
    let tags: [String]
    var tagButtons = [TagButtonNode]()
    var origins = [CGPoint]()
    let marginH: CGFloat = 8.0
    let marginV: CGFloat = 8.0
    var selectedTags = [String]()

    required init(tags: [String], enabled: Bool) {
        self.enabled = enabled
        self.tags = tags
        selectedTags = DataModel.sharedInstance.filter.tags
        super.init()

        for tag in self.tags {
            let tagButton = TagButtonNode(tagStr: tag)
            if self.enabled {
                tagButton.selected = selectedTags.contains(tag)
                tagButton.addTarget(self, action: "tagButtonTapped:", forControlEvents: ASControlNodeEvent.TouchUpInside)
            }
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

    func tagButtonTapped(sender: TagButtonNode) {
        if sender.selected {
            if !selectedTags.contains(sender.tagStr) {
                selectedTags.append(sender.tagStr)
            }
        } else {
            if let index = selectedTags.indexOf(sender.tagStr) {
                selectedTags.removeAtIndex(index)
            }
        }
    }

    func clearSelectedTags() {
        selectedTags = []
        for tagButton in tagButtons {
            tagButton.selected = false
        }
    }
}
