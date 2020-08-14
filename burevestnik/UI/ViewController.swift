//
//  ViewController.swift
//  burevestnik
//
//  Created by Marat Saytakov on 12.08.2020.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView! 

  func reloadUI() {
    tableView.reloadData()
  }

  var meshc: MeshController!

  override func viewDidLoad() {
    super.viewDidLoad()

    meshc = MeshController(reloadHandler: reloadUI)

    title = "🤍❤️🤍"

//    tableView.dataSource = meshc
//    tableView.delegate = meshc
  }

  @IBAction func composeDidTap(_ sender: Any) {
    let alert = UIAlertController(title: "Broadcast", message: "Enter 140 chars messasge", preferredStyle: .alert)

    alert.addTextField { (tf) in
      tf.placeholder = "БЧБ"
    }

    alert.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { [weak alert] _ in
      if let text = alert?.textFields?.first?.text {
//        self.btMan.sendMessage(text)
//        self.meshc.send
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
