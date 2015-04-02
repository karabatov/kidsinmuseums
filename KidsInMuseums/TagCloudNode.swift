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

    required init(tags: [String]) {
        self.tags = tags
        super.init()
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        return CGSizeZero
    }

    override func layout() {
    }
}
