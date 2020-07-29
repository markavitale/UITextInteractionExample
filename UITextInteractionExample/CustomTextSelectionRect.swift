// Licensed under the MIT License.

import UIKit

/// A `UITextSelectionRect` subclass for use with `UITextInput`
class CustomTextSelectionRect: UITextSelectionRect {
	
	/// The internal `CGRect` defining the size and location of the selection
	private let internalRect: CGRect
	/// The internal storage for the current writing direction of this text selection
	private let internalWritingDirection: NSWritingDirection
	/// The internal storage for whether this selection rect contains the start of the selection
	private let internalContainsStart: Bool
	/// The internal storage for whether this selection rect contains the end of the selection
	private let internalContainsEnd: Bool
	/// The internal storage for whether this selection is for vertical text
	private let internalIsVertical: Bool
	
	/// An initializer to create a `CustomTextSelectionRect` with all necessary properties
	/// - Parameters:
	///   - rect: The rect of the selection
	///   - writingDirection: The writing drection of the selection
	///   - containsStart: Whether this rect contains the start of the selection (only false in multi-rect selections)
	///   - containsEnd: Whether this rect contains the end of the selection (only false in multi-rect selections)
	///   - isVertical: Whether the text in the selection is vertical
	init(rect: CGRect, writingDirection: NSWritingDirection, containsStart: Bool, containsEnd: Bool, isVertical: Bool) {
		internalRect = rect
		internalWritingDirection = writingDirection
		internalContainsStart = containsStart
		internalContainsEnd = containsEnd
		internalIsVertical = isVertical
		super.init()
	}
	
	// MARK: UITextSelectionRect overrides
	
	override var rect: CGRect {
		get {
			return internalRect
		}
	}
	
	override var writingDirection: NSWritingDirection {
		return internalWritingDirection
	}
	
	override var containsStart: Bool {
		return internalContainsStart
	}
	
	override var containsEnd: Bool {
		return internalContainsEnd
	}
	
	override var isVertical: Bool {
		return internalIsVertical
	}
	
}
