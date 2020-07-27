// Licensed under the MIT License.

import UIKit


class CustomTextPosition: UITextPosition {
	static let InvalidTextPosition = -1

	let index: Int
	
	init(index: Int) {
		self.index = index
	}
}
