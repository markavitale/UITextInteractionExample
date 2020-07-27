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

extension CustomTextLabel: UITextInput {
	
	func text(in range: UITextRange) -> String? {
		text // TextRange
	}
	
	func replace(_ range: UITextRange, withText text: String) {
		<#code#>
	}
	
	var selectedTextRange: UITextRange? {
		get {
			<#code#>
		}
		set(selectedTextRange) {
			<#code#>
		}
	}
	
	var markedTextRange: UITextRange? {
		return nil //TODO: implement
	}
	
	var markedTextStyle: [NSAttributedString.Key : Any]? {
		get {
			return attributes
		}
		set(markedTextStyle) {
			// TODO: implement
		}
	}
	
	func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
		// TODO: implement
	}
	
	func unmarkText() {
		// TODO: implement
	}
	
	var beginningOfDocument: UITextPosition {
		CustomTextPosition(index: 0)
	}
	
	var endOfDocument: UITextPosition {
		CustomTextPosition(index: text.count) // TODO: -1?
	}
	
	func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
		return nil // TODO: implement
	}
	
	func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
		guard let position = position as? CustomTextPosition else {
			return nil
		}
		return CustomTextPosition(index: position.index + offset)
	}
	
	func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
		guard let position = position as? CustomTextPosition else {
			return nil
		}
		
		var newPosition: Int = position.index
		if direction == .left {
			newPosition = position.index - offset
		}
		
		if direction == .right {
			newPosition = position.index + offset
		}
		
		return CustomTextPosition(index: newPosition)

	}
	
	func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
		guard let position = position as? CustomTextPosition,
			  let other = other as? CustomTextPosition else {
			return .orderedSame
		}
		
		if position.index < other.index {
			return .orderedAscending
		} else if position.index > other.index {
			return .orderedDescending
		}
		return .orderedSame
	}
	
	func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
		guard let from = from as? CustomTextPosition,
			  let toPosition = toPosition as? CustomTextPosition else {
			return 0
		}
		
		return toPosition.index - from.index
	}
	
	var inputDelegate: UITextInputDelegate? {
		get {
			nil // TODO: implement
		}
		set(inputDelegate) {
			// TODO: implement
		}
	}
	
	var tokenizer: UITextInputTokenizer {
		UITextInputStringTokenizer(textInput: self)
	}
	
	func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
		
		let isStartFirst = compare(range.start, to: range.end) == .orderedAscending
		
		switch direction {
		case .left:
			return isStartFirst ? range.start : range.end
		case .right:
			return isStartFirst ? range.end : range.start
		case .up:
			return isStartFirst ? range.start : range.end
		case .down:
			return isStartFirst ? range.end : range.start
		@unknown default:
			fatalError()
		}
		return range.start
	}
	
	func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
		guard let position = position as? CustomTextPosition else {
			return nil
		}
		
		switch direction {
		case .left, .up:
			return CustomTextRange(startIndex: 0, endIndex: position.index)
		case .right, .down:
			return CustomTextRange(startIndex: position.index, endIndex: text.count)
		@unknown default:
			fatalError()
		}
		
		return CustomTextRange(startIndex: CustomTextPosition.InvalidTextPosition, endIndex: CustomTextPosition.InvalidTextPosition)
	}
	
	func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
		.natural // Only support natural alignment
	}
	
	func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
		// Only support natural alignment
	}
		
	func firstRect(for range: UITextRange) -> CGRect {
		<#code#>
	}
	
	func caretRect(for position: UITextPosition) -> CGRect {
		<#code#>
	}
	
	func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
		<#code#>
	}
	
	func closestPosition(to point: CGPoint) -> UITextPosition? {
		<#code#>
	}
	
	func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
		<#code#>
	}
	
	func characterRange(at point: CGPoint) -> UITextRange? {
		<#code#>
	}
	
	var hasText: Bool {
		text.isEmpty
	}
	
	func insertText(_ text: String) {
		// TODO: implement
	}
	
	func deleteBackward() {
		// TODO: implement
	}
	
	
}
