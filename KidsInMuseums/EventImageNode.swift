//
//  EventImageNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventImageNode: ASCellNode, ASMultiplexImageNodeDataSource {
    var imageNode: ASMultiplexImageNode

    required init(image: KImage) {
        var images = [String]()
        images.append(image.url)
        if let thumbURL = image.thumb?.url {
            images.append(thumbURL)
        }
        if let thumb2URL = image.thumb2?.url {
            images.append(thumb2URL)
        }

        imageNode = ASMultiplexImageNode(cache: nil, downloader: ASBasicImageDownloader())
        imageNode.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
        imageNode.contentMode = UIViewContentMode.ScaleAspectFill

        super.init()

        imageNode.dataSource = self
        imageNode.imageIdentifiers = nil
        imageNode.imageIdentifiers = images

        addSubnode(imageNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        return CGSizeMake(constrainedSize.width, ceil(constrainedSize.width * 2.0 / 3.0))
    }

    override func layout() {
        imageNode.frame = CGRectMake(0, 0, calculatedSize.width, calculatedSize.height)
    }

    func multiplexImageNode(imageNode: ASMultiplexImageNode!, URLForImageIdentifier imageIdentifier: AnyObject!) -> NSURL! {
        return NSURL(string: imageIdentifier as String)
    }
}
