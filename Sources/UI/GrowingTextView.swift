//
//  GrowingTextView.swift
//  burevestnik
//
//  Created by Marat Saytakov on 11.09.2020.
//

import UIKit

class GrowingTextView: UITextView {

  private var onSend: (String?) -> Void
  private var onResign: AnyVoid

  init(frame: CGRect, textContainer: NSTextContainer?, onSend: @escaping (String?) -> Void, onResign: @escaping AnyVoid) {

    self.onSend = onSend
    self.onResign = onResign

    super.init(frame: frame, textContainer: textContainer)

    self.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func resignFirstResponder() -> Bool {
    defer{onResign()}
    return super.resignFirstResponder()
  }

}

extension GrowingTextView: UITextViewDelegate {

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if (text == "\n") {
      defer {
        onSend(self.text)
      }
      return false
    }

    return true
  }

}

class PaddingTextField: UITextField {

  private var onSend: (String?) -> Void
  private var onResign: AnyVoid
  private let xPadding: CGFloat = 12, yPadding: CGFloat = 8

  init(frame: CGRect, onSend: @escaping (String?) -> Void, onResign: @escaping AnyVoid) {

    self.onSend = onSend
    self.onResign = onResign

    super.init(frame: frame)

    self.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    CGRect(
      x: bounds.origin.x + xPadding,
      y: bounds.origin.y + yPadding,
      width: bounds.size.width - xPadding * 2,
      height: bounds.size.height - yPadding * 2
    )
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    var rect = textRect(forBounds: bounds)
    rect.size.width -= 20
    return rect
  }

  override func resignFirstResponder() -> Bool {
    defer{onResign()}
    return super.resignFirstResponder()
  }

}


extension PaddingTextField: UITextFieldDelegate {

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if (string == "\n") {
      defer {
        onSend(self.text)
      }
      return false
    }

    return true
  }

}
