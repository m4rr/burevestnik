import UIKit

class ViewController: UIViewController, Ui {

  weak var uiProvider: UiDataProvider?

//  lazy var reach = Reachability.forInternetConnection()

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet var mapViewWrapperHeight: NSLayoutConstraint!
  @IBOutlet var mapWrapperView: MapWrapperView!

  @IBOutlet weak var sendMessageBigButton: UIButton!

  @IBOutlet weak var gpsButton: UIBarButtonItem!
  @IBOutlet weak var peersButton: UIBarButtonItem!
//  @IBOutlet weak var wwanButton: UIBarButtonItem!

  func reloadUI() {
    tableView.reloadData()

    peersButton.title = "\(uiProvider?.numberOfPeers ?? 0) Online"

    sendMessageBigButton.isHidden = (uiProvider?.dataCount ?? 0) != 0
  }

  private var locMan: LocationMan?
  private var isAnimating = false
  private var isGPSSharingOn = true {
    didSet {
      if isGPSSharingOn {
        locMan = LocationMan(mapWrapperView.update)
      } else {
        locMan = nil

        mapWrapperView.update(with: nil)
      }

      guard !isAnimating else { return }
      isAnimating = true

      let newHeight = isGPSSharingOn ? 250 : view.safeAreaInsets.top
      let topInset = newHeight - self.view.safeAreaInsets.top

      mapViewWrapperHeight.constant = newHeight

      UIView.animate(
        withDuration: 0.150,
        delay: 0,
        options: .curveEaseOut,
        animations: {
          self.view.layoutIfNeeded()

          self.tableView.contentInset.top = topInset
      },
        completion: { _ in
          self.isAnimating = false
      })

      gpsButton.title = isGPSSharingOn ? "GPS (on)" : "GPS (off)"
    }
  }
  
  @IBAction func gpsButtonDidTap(_ sender: UIBarButtonItem) {
    isGPSSharingOn.toggle()
  }

  @IBAction func peersButtonDidTap(_ sender: UIBarButtonItem) {
    reloadUI()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    assert(uiProvider != nil)

    title = "🤍❤️🤍"

    tableView.dataSource = self
    tableView.delegate = self
    
    setupMapWrapperView()

    DispatchQueue.main.async { self.isGPSSharingOn = false }

    setupReachability()
  }

  private func setupMapWrapperView() {
    view.addSubview(mapWrapperView)
    mapWrapperView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    mapWrapperView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
  }

  private func setupReachability() {
//    wwanButton.title = reach?.currentReachabilityString()
//
//    reach?.reachabilityBlock = { r, _ in
//      DispatchQueue.main.async { [weak self] in
//        self?.wwanButton.title = r?.currentReachabilityString()
//      }
//    }
//
//    reach?.startNotifier()
  }

  private lazy var sendMessageTextView = GrowingTextView(
    frame: .init(x: 0, y: 0, width: 100, height: 50),
    textContainer: nil,
    onSend: { [weak self] text in
      self?.makeSendMessage(text: text)
      self?._canBecomeFirstResponder = false
    },
    onResign: { [weak self] in
      self?._canBecomeFirstResponder = false
    })
    .then { (textView) in
      if #available(iOS 13.0, *) {
        textView.backgroundColor = .systemGray6
      } else {
        textView.backgroundColor = .lightGray
      }
      textView.isScrollEnabled = false   // causes expanding height
      textView.font = .preferredFont(forTextStyle: .body)
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.returnKeyType = .send
    }

  override var inputAccessoryView: UIView? {
    _canBecomeFirstResponder ? sendMessageTextView : nil
  }

  override func resignFirstResponder() -> Bool {
    return super.resignFirstResponder()
  }

  private var _canBecomeFirstResponder = false {
    didSet {
      if _canBecomeFirstResponder == oldValue {
        return
      }

      if _canBecomeFirstResponder {
        becomeFirstResponder()
        sendMessageTextView.becomeFirstResponder()

      } else {
        _ = sendMessageTextView.resignFirstResponder()
        _ = resignFirstResponder()
      }
    }
  }

  override var canBecomeFirstResponder: Bool {
    _canBecomeFirstResponder
  }

  @IBAction func composeDidTap(_ sender: Any) {

    _canBecomeFirstResponder = true

  }

  func makeSendMessage(text: String?) {

    if let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
      uiProvider?.broadcastMessage(text)
    }

  }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    uiProvider?.dataCount ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell

    let data = uiProvider!.dataAt(indexPath)

    cell.t1?.text = data.msg

    //      let name = uiHandler.isConflicting(data.simpleFrom) ? data.from : data.simpleFrom

    cell.t2?.text = data.simpleFrom + " / " + data.simpleDate

    return cell
  }

}
