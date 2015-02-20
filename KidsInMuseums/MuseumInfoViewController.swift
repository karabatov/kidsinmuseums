//
//  MuseumInfoViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

enum MuseumField {
    case Title, Address, Phone, Email, Website, Events
}

class MuseumInfoViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    let listView = ASTableView()
    var museum: Museum {
        didSet {
            self.configureWithMuseum(museum)
        }
    }
    var fields = [MuseumField]()

    required init(coder aDecoder: NSCoder) {
        fatalError("say no to storyboards")
    }

    required init(museum: Museum, frame b: CGRect) {
        self.museum = museum
        super.init(nibName: nil, bundle: nil)
        self.configureWithMuseum(museum)
    }

    func configureWithMuseum(museum: Museum) {
        fields.removeAll(keepCapacity: true)
        if !museum.name.isEmpty {
            fields.append(.Title)
        }
        if !museum.address.isEmpty {
            fields.append(.Address)
        }
        if !museum.phone.isEmpty {
            fields.append(.Phone)
        }
        if !museum.email.isEmpty {
            fields.append(.Email)
        }
        if !museum.site.isEmpty {
            fields.append(.Website)
        }
        fields.append(.Events)
        listView.reloadData()
    }

    override func viewDidLoad() {
        view.addSubview(listView)
        listView.separatorStyle = UITableViewCellSeparatorStyle.None
        listView.backgroundColor = UIColor.whiteColor()
        listView.asyncDataSource = self
        listView.asyncDelegate = self
    }

    // MARK: ASTableView

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let field = fields[indexPath.row]
        switch field {
        case .Title:
            let text = ASTextCellNode()
            text.text = museum.name
            return text
        default:
            return ASCellNode()
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
}