//
//  AgeCloudNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 08.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class AgeCloudNode: ASCellNode {
    let ageRanges: [AgeRange] = [ AgeRange(from: 5, to: 7), AgeRange(from: 7, to: 12), AgeRange(from: 12, to: 14), AgeRange(from: 14, to: 999) ]
    var ageButtons = [AgeButtonNode]()
    var origins = [CGPoint]()
    let marginH: CGFloat = 8.0
    let marginV: CGFloat = 8.0
    var selectedAges = [AgeRange]()

    override required init() {
        // TODO: Init ranges from DataModel filter
        selectedAges = [ AgeRange(from: 5, to: 7), AgeRange(from: 14, to: 999) ]
        super.init()

        for age in self.ageRanges {
            let ageButton = AgeButtonNode(ageRange: age)
            ageButton.selected = contains(selectedAges, age)
            ageButton.addTarget(self, action: "ageButtonTapped:", forControlEvents: ASControlNodeEvent.TouchUpInside)
            ageButtons.append(ageButton)
            addSubnode(ageButton)
        }
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        var ageButtonHeight: CGFloat = 0.0
        let maxWidth = constrainedSize.width - 2 * marginH
        var rollingOrigin = CGPointMake(marginH, marginV)
        for ageButton in ageButtons {
            let textSize = ageButton.measure(CGSizeMake(maxWidth, CGFloat.max))
            if ageButtonHeight == 0.0 {
                ageButtonHeight = textSize.height
            }
            if textSize.width > (maxWidth - rollingOrigin.x - marginH) {
                rollingOrigin = CGPointMake(marginH, rollingOrigin.y + ageButtonHeight)
            }
            origins.append(rollingOrigin)
            rollingOrigin.x += textSize.width
        }
        return CGSizeMake(constrainedSize.width, rollingOrigin.y + ageButtonHeight + marginV)
    }

    override func layout() {
        for var i = 0; i < ageButtons.count && i < origins.count; i++ {
            let ageButton = ageButtons[i]
            let origin = origins[i]
            let ageSize = ageButton.calculatedSize
            ageButton.frame = CGRectMake(origin.x, origin.y, ageSize.width, ageSize.height)
        }
    }

    func ageButtonTapped(sender: AgeButtonNode) {
        if sender.selected {
            if !contains(selectedAges, sender.ageRange) {
                selectedAges.append(sender.ageRange)
            }
        } else {
            if let index = find(selectedAges, sender.ageRange) {
                selectedAges.removeAtIndex(index)
            }
        }
        NSLog("\(selectedAges)")
    }

    func clearSelectedAges() {
        selectedAges = []
        for ageButton in ageButtons {
            ageButton.selected = false
        }
    }
}
