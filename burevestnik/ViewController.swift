//
//  ViewController.swift
//  burevestnik
//
//  Created by Marat on 12.08.2020.
//  Copyright © 2020 Marat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView! 

  var btMan: BtMan!

  func reloadHandler() {
    tableView.reloadData()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🤍❤️🤍"

    btMan = BtMan(reloadHandler: reloadHandler)

    tableView.dataSource = btMan
    tableView.delegate = btMan
  }

  @IBAction func composeDidTap(_ sender: Any) {
    let alert = UIAlertController(title: "Broadcast", message: "Enter 140 chars messasge", preferredStyle: .alert)

    alert.addTextField { (tf) in
      tf.placeholder = "БЧБ"
    }

    alert.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { [weak alert] _ in
      if let text = alert?.textFields?.first?.text {
        self.btMan.sendMessage(text)
      }
    }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true)
  }

}


extension BtMan: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    allSorted.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell

    let bbc = allSorted[indexPath.row]

    cell.t1?.text = bbc.msg
    cell.t2?.text = bbc.ti.description

    return cell

  }

}

class Cell: UITableViewCell {

  @IBOutlet weak var t1: UILabel!
  @IBOutlet weak var t2: UILabel!

}