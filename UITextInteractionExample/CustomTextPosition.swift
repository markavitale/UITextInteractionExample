// Licensed under the MIT License.

import UIKit


class CustomTextPosition: UITextPosition {
	let index: Int
	
	init(index: Int) {
		self.index = index
	}
}

extension CustomTextPosition: Comparable {
	static func < (lhs: CustomTextPosition, rhs: CustomTextPosition) -> Bool {
		lhs.index < rhs.index
	}
	
	static func <= (lhs: CustomTextPosition, rhs: CustomTextPosition) -> Bool {
		lhs.index <= rhs.index
	}

	static func >= (lhs: CustomTextPosition, rhs: CustomTextPosition) -> Bool {
		lhs.index >= rhs.index
	}

	static func > (lhs: CustomTextPosition, rhs: CustomTextPosition) -> Bool {
		lhs.index > rhs.index
	}

}
