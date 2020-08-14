//
//  ViewController.swift
//  burevestnik
//
//  Created by Marat Saytakov on 12.08.2020.
//

import UIKit

protocol UiHandler: UITableViewDataSource, UITableViewDelegate {

  var reloadHandler: AnyVoid { get set }
  func broadcastMessage(_ text: String)

}

class ViewController: UIViewController {

  var uiHandler: UiHandler? {
    didSet {

      uiHandler?.reloadHandler = reloadUI
    }
  }

  @IBOutlet weak var tableView: UITableView! 

  func reloadUI() {
    tableView.reloadData()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🤍❤️🤍"

    tableView.dataSource = uiHandler
    tableView.delegate = uiHandler
  }

  @IBAction func composeDidTap(_ sender: Any) {
    let alert = UIAlertController(title: "Broadcast", message: "Enter 140 chars messasge", preferredStyle: .alert)

    alert.addTextField { (tf) in
      tf.placeholder = "БЧБ"
    }

    alert.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { [weak alert] _ in
      if let text = alert?.textFields?.first?.text {
        self.uiHandler?.broadcastMessage(text)
      }
    }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true)
  }

}

extension MeshController {

  func dataAt(_ indexPath: IndexPath) -> BroadMessage {
    #warning("stub")
    return BroadMessage("")
  }

  var dataCount: Int {
    #warning("stub")
    return 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dataCount
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell

    let data = dataAt(indexPath)
    cell.t1?.text = data.msg
    cell.t2?.text = data.ti.description

    return cell
  }

}

class Cell: UITableViewCell {

  @IBOutlet weak var t1: UILabel!
  @IBOutlet weak var t2: UILabel!

}
