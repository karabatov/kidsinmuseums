//
//  EventItemViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventItemViewController: UIViewController {

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(event: Event) {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        let b = self.view.bounds
    }
}
