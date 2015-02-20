//
//  MuseumInfoView.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class MuseumInfoView: UIScrollView {

    required init(museum: Museum, maxWidth: CGFloat) {
        super.init(frame: CGRectZero)

        var height: CGFloat = 0.0

        if !museum.name.isEmpty {
            let titleParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.blackColor()]
            let museumTitleView = TextDividerNode(text: museum.name, textParams: titleParams)
            let titleSize = museumTitleView.measure(CGSizeMake(maxWidth, 0))

            museumTitleView.frame = CGRectMake(0, height, maxWidth, titleSize.height)
            self.addSubview(museumTitleView.view)

            height += titleSize.height
        }

        self.frame = CGRectMake(0, 0, maxWidth, height)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
