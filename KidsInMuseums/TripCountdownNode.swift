//
//  TripCountdownNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 06.08.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class TripCountdownNode: ASCellNode {
    let startDate: NSDate
    var timer: NSTimer?

    let backgroundNode = ASDisplayNode()
    let titleNode = ASTextNode()
    let dayNode = ASTextNode()
    let hourNode = ASTextNode()
    let minuteNode = ASTextNode()
    let secondNode = ASTextNode()
    let dayTextNode = ASTextNode()
    let hourTextNode = ASTextNode()
    let minuteTextNode = ASTextNode()
    let secondTextNode = ASTextNode()
    let colon1Node = ASTextNode()
    let colon2Node = ASTextNode()

    let marginBG: CGFloat = 16.0
    let radiusBG: CGFloat = 8.0
    let marginBGIntra: CGFloat = 20.0
    let marginBGIntraSmall: CGFloat = 8.0

    let bigParams = [NSFontAttributeName: UIFont.systemFontOfSize(32.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
    let smallParams = [NSFontAttributeName: UIFont.systemFontOfSize(9.0), NSForegroundColorAttributeName: UIColor.whiteColor()]

    required init(date: NSDate) {
        startDate = date
        super.init()

        backgroundNode.backgroundColor = UIColor.kimOrangeColor()
        backgroundNode.cornerRadius = radiusBG
        addSubnode(backgroundNode)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Center
        let titleParams = [NSFontAttributeName: UIFont.systemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: paragraph]
        titleNode.attributedString = NSAttributedString(string: NSLocalizedString("TIME BEFORE THE FAMILY TRIP STARTS", comment: "Countdown timer heading"), attributes: titleParams)
        addSubnode(titleNode)

        dayNode.placeholderEnabled = true
        dayNode.placeholderColor = UIColor.kimOrangeColor()
        dayNode.placeholderFadeDuration = 0.15
        addSubnode(dayNode)
        hourNode.placeholderEnabled = true
        hourNode.placeholderColor = UIColor.kimOrangeColor()
        hourNode.placeholderFadeDuration = 0.15
        addSubnode(hourNode)
        minuteNode.placeholderEnabled = true
        minuteNode.placeholderColor = UIColor.kimOrangeColor()
        minuteNode.placeholderFadeDuration = 0.15
        addSubnode(minuteNode)
        secondNode.placeholderEnabled = true
        secondNode.placeholderColor = UIColor.kimOrangeColor()
        secondNode.placeholderFadeDuration = 0.15
        addSubnode(secondNode)

        dayTextNode.attributedString = NSAttributedString(string: NSLocalizedString("days", comment: "Countdown timer days"), attributes: smallParams)
        addSubnode(dayTextNode)
        hourTextNode.attributedString = NSAttributedString(string: NSLocalizedString("hours", comment: "Countdown timer hours"), attributes: smallParams)
        addSubnode(hourTextNode)
        minuteTextNode.attributedString = NSAttributedString(string: NSLocalizedString("minutes", comment: "Countdown timer minutes"), attributes: smallParams)
        addSubnode(minuteTextNode)
        secondTextNode.attributedString = NSAttributedString(string: NSLocalizedString("seconds", comment: "Countdown timer seconds"), attributes: smallParams)
        addSubnode(secondTextNode)

        colon1Node.attributedString = NSAttributedString(string: ":", attributes: bigParams)
        addSubnode(colon1Node)
        colon2Node.attributedString = NSAttributedString(string: ":", attributes: bigParams)
        addSubnode(colon2Node)

        updateCountdownTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func timerTicked(sender: NSTimer) {
        updateCountdownTimer()
    }

    func updateCountdownTimer() {
        let difference = Int(startDate.timeIntervalSinceDate(NSDate()))

        let daysLeft = difference / 86400
        let hoursLeft = (difference % 86400) / 3600
        let minutesLeft = (difference % 3600) / 60
        let secondsLeft = difference % 60

        dayNode.attributedString = NSAttributedString(string: "\(daysLeft)", attributes: self.bigParams)
        hourNode.attributedString = NSAttributedString(string: hoursLeft < 10 ? "0\(hoursLeft)" : "\(hoursLeft)", attributes: self.bigParams)
        minuteNode.attributedString = NSAttributedString(string: minutesLeft < 10 ? "0\(minutesLeft)" : "\(minutesLeft)", attributes: self.bigParams)
        secondNode.attributedString = NSAttributedString(string: secondsLeft < 10 ? "0\(secondsLeft)" : "\(secondsLeft)", attributes: self.bigParams)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let titleSize = titleNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        let daySize = dayNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        hourNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        minuteNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        secondNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        let dayTextSize = dayTextNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        hourTextNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        minuteTextNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        secondTextNode.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        colon1Node.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))
        colon2Node.measure(CGSize(width: constrainedSize.width - marginBG * 2 - marginBGIntra * 2, height: CGFloat.max))

        return CGSize(width: constrainedSize.width, height: marginBG * 2 + marginBGIntra * 3 + marginBGIntraSmall + titleSize.height +  daySize.height + dayTextSize.height)
    }

    override func layout() {
        backgroundNode.frame = CGRect(x: marginBG, y: marginBG, width: calculatedSize.width - marginBG * 2, height: calculatedSize.height - marginBG * 2)

        titleNode.frame = CGRect(x: (calculatedSize.width - titleNode.calculatedSize.width) / 2.0, y: marginBG + marginBGIntra, width: titleNode.calculatedSize.width, height: titleNode.calculatedSize.height)

        let avgWidth = (dayNode.calculatedSize.width + hourNode.calculatedSize.width + minuteNode.calculatedSize.width + secondNode.calculatedSize.width) / 4.0
        let spacingX = (calculatedSize.width - marginBG * 2.0 - marginBGIntra * 2.0 - avgWidth * 4.0) / 5.0

        dayNode.frame = CGRect(x: marginBG + marginBGIntra + spacingX + (avgWidth - dayNode.calculatedSize.width) / 2.0, y: titleNode.frame.maxY + marginBGIntra, width: dayNode.calculatedSize.width, height: dayNode.calculatedSize.height)
        hourNode.frame = CGRect(x: marginBG + marginBGIntra + avgWidth + spacingX * 2 + (avgWidth - hourNode.calculatedSize.width) / 2.0, y: titleNode.frame.maxY + marginBGIntra, width: hourNode.calculatedSize.width, height: hourNode.calculatedSize.height)
        minuteNode.frame = CGRect(x: marginBG + marginBGIntra + avgWidth * 2 + spacingX * 3 + (avgWidth - minuteNode.calculatedSize.width) / 2.0, y: titleNode.frame.maxY + marginBGIntra, width: minuteNode.calculatedSize.width, height: minuteNode.calculatedSize.height)
        secondNode.frame = CGRect(x: marginBG + marginBGIntra + avgWidth * 3 + spacingX * 4 + (avgWidth - secondNode.calculatedSize.width) / 2.0, y: titleNode.frame.maxY + marginBGIntra, width: secondNode.calculatedSize.width, height: secondNode.calculatedSize.height)

        colon1Node.frame = CGRect(x: marginBG + marginBGIntra + avgWidth * 2 + spacingX * 2.5 - colon1Node.calculatedSize.width / 2.0, y: titleNode.frame.maxY + marginBGIntra + (minuteNode.frame.height - colon1Node.calculatedSize.height), width: colon1Node.calculatedSize.width, height: colon1Node.calculatedSize.height)
        colon2Node.frame = CGRect(x: marginBG + marginBGIntra + avgWidth * 3 + spacingX * 3.5 - colon2Node.calculatedSize.width / 2.0, y: titleNode.frame.maxY + marginBGIntra + (minuteNode.frame.height - colon2Node.calculatedSize.height), width: colon2Node.calculatedSize.width, height: colon2Node.calculatedSize.height)

        dayTextNode.frame = CGRect(x: marginBG + marginBGIntra + spacingX + avgWidth / 2.0 - dayTextNode.calculatedSize.width / 2.0, y: calculatedSize.height - marginBG - marginBGIntra - dayTextNode.calculatedSize.height, width: dayTextNode.calculatedSize.width, height: dayTextNode.calculatedSize.height)
        hourTextNode.frame = CGRect(x: hourNode.frame.origin.x + (hourNode.frame.width - hourTextNode.calculatedSize.width) / 2.0, y: hourNode.frame.maxY + marginBGIntraSmall, width: hourTextNode.calculatedSize.width, height: hourTextNode.calculatedSize.height)
        minuteTextNode.frame = CGRect(x: minuteNode.frame.origin.x + (minuteNode.frame.width - minuteTextNode.calculatedSize.width) / 2.0, y: minuteNode.frame.maxY + marginBGIntraSmall, width: minuteTextNode.calculatedSize.width, height: minuteTextNode.calculatedSize.height)
        secondTextNode.frame = CGRect(x: secondNode.frame.origin.x + (secondNode.frame.width - secondTextNode.calculatedSize.width) / 2.0, y: secondNode.frame.maxY + marginBGIntraSmall, width: secondTextNode.calculatedSize.width, height: secondTextNode.calculatedSize.height)

        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerTicked:", userInfo: nil, repeats: true)
        }
    }
}
