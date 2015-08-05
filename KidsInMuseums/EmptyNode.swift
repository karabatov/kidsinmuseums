//
//  EmptyNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 05.08.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class EmptyNode: ASCellNode {
    var emptyHeight: CGFloat = 0.0

    required init(height: CGFloat) {
        super.init()

        emptyHeight = height
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        return CGSize(width: constrainedSize.width, height: emptyHeight)
    }

    override func layout() {
        super.layout()
    }
}
