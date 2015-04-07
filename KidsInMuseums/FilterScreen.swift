//
//  FilterScreen.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 07.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

enum FilterScreenMode {
    case Tags, Museums
}

class FilterScreen: UIViewController {
    let myToolbar = UIToolbar()
    let tagButton: FilterButton
    let museumButton: FilterButton
//    let listTags = ASTableView()
    var filterButtonV: CGFloat = 0.0

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let tagText = NSLocalizedString("By tags", comment: "Filter by tags")
        let museumText = NSLocalizedString("By museums", comment: "Filter by museums")

        tagButton = FilterButton(text: tagText)
        tagButton.highlighted = true
        museumButton = FilterButton(text: museumText)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        edgesForExtendedLayout = UIRectEdge.None
        title = NSLocalizedString("Filter", comment: "Filter screen title")
        view.opaque = true
        view.backgroundColor = UIColor.whiteColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let halfWidth = UIScreen.mainScreen().applicationFrame.size.width / 2.0
            self.filterButtonV = self.tagButton.measure(CGSizeMake(halfWidth, 0.0)).height
            self.museumButton.measure(CGSizeMake(UIScreen.mainScreen().applicationFrame.size.width / 2.0, 0.0)).height
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.addSubview(self.tagButton.view)
                self.view.addSubview(self.museumButton.view)
                self.tagButton.frame = CGRectMake(0, 0, halfWidth, self.filterButtonV)
                self.museumButton.frame = CGRectMake(halfWidth, 0, halfWidth, self.filterButtonV)
            })
        })
    }
}
