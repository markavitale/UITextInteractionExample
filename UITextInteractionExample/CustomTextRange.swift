// Licensed under the MIT License.

import UIKit

class CustomTextRange: UITextRange {
	
	let startIndex: Int
	let endIndex: Int

	init(startIndex: Int, endIndex: Int) {
		self.startIndex = startIndex
		self.endIndex = endIndex
		
		super.init()
	}
	
	override var isEmpty: Bool {
		return false
	}
	
	override var start: UITextPosition {
		return CustomTextPosition(index: startIndex)
	}
	
	override var end: UITextPosition {
		return CustomTextPosition(index: endIndex)
	}
	
}
