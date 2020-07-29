// Licensed under the MIT License.

import UIKit

/// A `UITextRange` subclass for use with `UITextInput`
class CustomTextRange: UITextRange {
	
	/// The start offset of this range
	let startOffset: Int
	/// The end offset of this range
	let endOffset: Int
	
	/// Create a `CustomTextRange` with the given offsets
	/// - Parameters:
	///   - startOffset: The start offset of this range
	///   - endOffset: The end offset of this range
	init(startOffset: Int, endOffset: Int) {
		self.startOffset = startOffset
		self.endOffset = endOffset
		
		super.init()
	}
	
	// MARK: UITextRange Overrides
	
	override var isEmpty: Bool {
		return startOffset == endOffset
	}
	
	override var start: UITextPosition {
		return CustomTextPosition(offset: startOffset)
	}
	
	override var end: UITextPosition {
		return CustomTextPosition(offset: endOffset)
	}
	
}
