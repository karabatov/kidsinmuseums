//
//  EventScheduleNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventScheduleNode: ASCellNode {
    var measureHumanTime = false
    var measureEventTime = false
    let clockNode = ASTextNode()
    let textNode = ASTextNode()
    let kEventScheduleNodeMarginH: CGFloat = 16.0
    let kEventScheduleNodeMarginV: CGFloat = 6.0
    let kEventScheduleNodePinFontSize: CGFloat = 14.0

    required init(event: Event) {
        super.init()

        let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.blackColor()]
        var titleStr = NSMutableAttributedString()

        if event.eventHumanTimes.count > 0 {
            if let humanTime = event.eventHumanTimes.first {
                if humanTime.time != "" {
                    measureHumanTime = true
                    let timeStr = NSAttributedString(string: humanTime.time, attributes: textParams)
                    titleStr.appendAttributedString(timeStr)

                    if humanTime.comment != "" {
                        let commentStr = NSAttributedString(string: "\n\(humanTime.comment)", attributes: textParams)
                        titleStr.appendAttributedString(commentStr)
                    }
                }
            }
        }

        if let nearestTime = event.earliestEventTime(NSDate()) {
            measureEventTime = true

            if measureHumanTime {
                let spacerStr = NSAttributedString(string: "\n\n", attributes: textParams)
                titleStr.appendAttributedString(spacerStr)
            }

            let nearStr = String(format: NSLocalizedString("Next event: %@", comment: "Next event introduction text, event details screen"), nearestTime.humanReadable(.Distance))
            let nearAttrStr = NSAttributedString(string: nearStr, attributes: textParams)
            titleStr.appendAttributedString(nearAttrStr)
        }

        if measureHumanTime || measureEventTime {
            let clock = FAKFontAwesome.clockOIconWithSize(kEventScheduleNodePinFontSize)
            clock.addAttribute(NSForegroundColorAttributeName, value: UIColor.kimColor())
            clockNode.attributedString = clock.attributedString()

            textNode.attributedString = titleStr

            addSubnode(clockNode)
            addSubnode(textNode)
        }

        placeholderEnabled = true
        placeholderFadeDuration = 0.25
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        if measureHumanTime || measureEventTime {
            let clockSize = clockNode.measure(CGSizeMake(constrainedSize.width, CGFloat.max))
            let textSize = textNode.measure(CGSizeMake(constrainedSize.width - kEventScheduleNodeMarginH * 2, CGFloat.max))
            return CGSizeMake(constrainedSize.width, max(clockSize.height + kEventScheduleNodeMarginV * 3, textSize.height + kEventScheduleNodeMarginV * 2))
        } else {
            return CGSizeZero
        }
    }

    override func layout() {
        if measureHumanTime || measureEventTime {
            let clockSize = clockNode.calculatedSize
            let textSize = textNode.calculatedSize
            clockNode.frame = CGRectMake(kEventScheduleNodeMarginH, kEventScheduleNodeMarginV, clockSize.width, clockSize.height)
            textNode.frame = CGRectMake(kEventScheduleNodeMarginH * 2, kEventScheduleNodeMarginV, textSize.width, textSize.height)
        }
    }
}
