//
//  ViewController.swift
//  SwipeTableViewCell
//
//  Created by SEN LIU on 3/3/17.
//  Copyright © 2017 SEN LIU. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = 120
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        let leftAction = SwipeTableViewCellAction(image: UIImage(named: "Bookmark")!, title: "Bookmark")
        let rightAction1 = SwipeTableViewCellAction(image: UIImage(named: "Delete")!, title: "Delete")
        let rightAction2 = SwipeTableViewCellAction(image: UIImage(named: "False Alarm")!, title: "False Alarm")
        cell.configure(leftActions: [leftAction], rightActions: [rightAction1, rightAction2])
        return cell
    }
}

