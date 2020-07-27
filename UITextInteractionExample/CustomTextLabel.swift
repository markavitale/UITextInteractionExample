// Licensed under the MIT License.

import UIKit

class CustomTextLabel: UIView {
	var text: String {
		get {
			textStorage.string
		}
		set {
			textStorage.mutableString.setString(newValue)
		}
	}
	
	private var textStorage = NSTextStorage()
	
	var attributes: [NSAttributedString.Key: Any] = {
		[
			.foregroundColor: UIColor.red,
			.backgroundColor: UIColor.systemBackground,
		]
	}()
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		let attributedString = NSAttributedString(string: text, attributes: attributes)
		attributedString.draw(in: rect)
	}
	
	override var intrinsicContentSize: CGSize {
		return textStorage.size()
	}
}
