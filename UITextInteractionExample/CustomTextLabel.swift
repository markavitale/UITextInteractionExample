// Licensed under the MIT License.

import UIKit

class CustomTextLabel: UIView {
	var text: String {
		get {
			textStorage.string
		}
		set {
			textStorage.mutableString.setString(newValue)
			invalidateIntrinsicContentSize()
			setNeedsDisplay()
		}
	}
	
	private var textStorage = NSTextStorage()
	
	var attributes: [NSAttributedString.Key: Any]? = {
		let font = UIFont.systemFont(ofSize: 20.0)
		
		return [
			.foregroundColor: UIColor.red,
			.backgroundColor: UIColor.systemBackground,
			.font: font,
		]
	}()
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		let attributedString = NSAttributedString(string: text, attributes: attributes)
		attributedString.draw(in: rect)
	}
	
	override var intrinsicContentSize: CGSize {
		let size = NSAttributedString(string: text, attributes: attributes).size()
		return CGSize(width: ceil(size.width), height: ceil(size.height))
	}
	
	var currentSelectedTextRange: UITextRange? = CustomTextRange(startIndex: 0, endIndex: 0)
	
	// MARK: First Responder
	override var canBecomeFirstResponder: Bool {
		true
	}
}

extension CustomTextLabel: UITextInput {
	
	func text(in range: UITextRange) -> String? {
		guard let rangeStart = range.start as? CustomTextPosition, let rangeEnd = range.end as? CustomTextPosition else {
			fatalError()
		}
		let location =  max(rangeStart.index, 0)
		let length = max(min(text.count - location, rangeEnd.index - location), 0)
		
		if location >= text.count {
			return nil
		}
		
		assert(location < text.count)
		assert(location + length <= text.count)
		
		return textStorage.attributedSubstring(from: NSRange(location: location, length:length)).string
	}
	
	func replace(_ range: UITextRange, withText text: String) {
		guard let range = range as? CustomTextRange else {
			fatalError()
		}
		
		textStorage.replaceCharacters(in: NSRange(location: range.startIndex, length: range.endIndex - range.startIndex), with: text)
		setNeedsDisplay()
		invalidateIntrinsicContentSize()
	}
	
	var selectedTextRange: UITextRange? {
		get {
			currentSelectedTextRange
		}
		set(selectedTextRange) {
			currentSelectedTextRange = selectedTextRange
		}
	}
	
	var markedTextRange: UITextRange? {
		return selectedTextRange // TODO: confirm this is ok
	}
	
	var markedTextStyle: [NSAttributedString.Key : Any]? {
		get {
			return attributes
		}
		set(markedTextStyle) {
			attributes = markedTextStyle
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
		guard let fromPosition = fromPosition as? CustomTextPosition, let toPosition = toPosition as? CustomTextPosition else {
			return nil
		}
		return CustomTextRange(startIndex: fromPosition.index, endIndex: toPosition.index)
	}
	
	func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
		guard let position = position as? CustomTextPosition else {
			return nil
		}
		
		let proposedIndex = position.index + offset
		
		// return nil if proposed index is out of bounds
		guard proposedIndex >= 0 && proposedIndex <= text.count else {
			return nil
		}
		
		return CustomTextPosition(index: proposedIndex)
	}
	
	func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
		guard let position = position as? CustomTextPosition else {
			return nil
		}
		
		var proposedIndex: Int = position.index
		if direction == .left {
			proposedIndex = position.index - offset
		}
		
		if direction == .right {
			proposedIndex = position.index + offset
		}
		
		// return nil if proposed index is out of bounds
		guard proposedIndex >= 0 && proposedIndex <= text.count else {
			return nil
		}
	
		return CustomTextPosition(index: proposedIndex)

	}
	
	func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
		guard let position = position as? CustomTextPosition,
			  let other = other as? CustomTextPosition else {
			return .orderedSame
		}
		
		if position < other {
			return .orderedAscending
		} else if position > other {
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
		case .left, .up:
			return isStartFirst ? range.start : range.end
		case .right, .down:
			return isStartFirst ? range.end : range.start
		@unknown default:
			fatalError()
		}
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
	}
	
	func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
		.natural // Only support natural alignment
	}
	
	func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
		// Only support natural alignment
	}
		
	// MARK: - Geometery
	func firstRect(for range: UITextRange) -> CGRect {
		guard let rangeStart = range.start as? CustomTextPosition, let rangeEnd = range.end as? CustomTextPosition, let font = attributes?[.font] as? UIFont else {
			return .zero
		}
		let preSubstring = textStorage.attributedSubstring(from: NSRange(location: 0, length: rangeStart.index))
		let preSize = NSAttributedString(string: preSubstring.string, attributes: attributes).size()
		let actualSubstring = textStorage.attributedSubstring(from: NSRange(location: rangeStart.index, length: rangeEnd.index - rangeStart.index))
		let actualSize = NSAttributedString(string: actualSubstring.string, attributes: attributes).size()
		
		return CGRect(x: preSize.width, y: 0, width: actualSize.width, height: font.lineHeight)
	}
	
	func caretRect(for position: UITextPosition) -> CGRect {
		guard let position = position as? CustomTextPosition,
			let font = attributes?[.font] as? UIFont else {
				return bounds
		}
		
		let substring = textStorage.attributedSubstring(from: NSRange(location: 0, length: max(position.index, 0)))
		let size = NSAttributedString(string: substring.string, attributes: attributes).size()
		return CGRect(x: size.width, y: 0, width: 2.0, height: font.lineHeight)
	}
	
	func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
		guard let rangeStart = range.start as? CustomTextPosition, let rangeEnd = range.end as? CustomTextPosition else {
			fatalError()
		}
		return [CustomTextSelectionRect(rect: firstRect(for: range), writingDirection: .leftToRight, containsStart: rangeStart.index == 0, containsEnd: rangeEnd.index == text.count, isVertical: false)]
	}
	
	func closestPosition(to point: CGPoint) -> UITextPosition? {
		var totalWidth: CGFloat = 0.0
		for (index, character) in text.enumerated() {
			let characterSize = NSAttributedString(string: String(character), attributes: attributes).size()

			if totalWidth <= point.x && point.x < totalWidth + characterSize.width {
				return CustomTextPosition(index: index)
			} else {
				totalWidth = totalWidth + characterSize.width
			}
		}
		return CustomTextPosition(index: 0)
	}
	
	func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
		guard let proposedPosition = closestPosition(to: point) as? CustomTextPosition,
			let rangeStart = range.start as? CustomTextPosition,
			let rangeEnd = range.end as? CustomTextPosition else {
			return nil
		}
		return min(max(proposedPosition, rangeStart), rangeEnd)
	}
	
	func characterRange(at point: CGPoint) -> UITextRange? {
		guard let textPosition = closestPosition(to: point) as? CustomTextPosition else {
			return nil
		}
		return CustomTextRange(startIndex: textPosition.index, endIndex: textPosition.index + 1)
	}
	
	var hasText: Bool {
		!text.isEmpty
	}
	
	func insertText(_ text: String) {
		if let currentSelectedTextRange = currentSelectedTextRange {
			replace(currentSelectedTextRange, withText: text)
			invalidateIntrinsicContentSize()
			setNeedsDisplay()
		}
		
		if let start = currentSelectedTextRange?.start as? CustomTextPosition {
			let newSelectionLocation = start.index + text.count
			currentSelectedTextRange = CustomTextRange(startIndex: newSelectionLocation, endIndex: newSelectionLocation)
		}
		
	}
	
	func deleteBackward() {
		guard let currentSelectedTextRange = currentSelectedTextRange else {
			// no selection, how do we delete?
			fatalError()
		}
		var newSelectionIndex = 0
		if currentSelectedTextRange.isEmpty { // empty selection, just use the start position and move back by one if possible
			if let start = currentSelectedTextRange.start as? CustomTextPosition, start.index > 0, start.index <= text.count {
				if start.index - 1 > 0 {
					textStorage.deleteCharacters(in: NSRange(location: start.index - 1, length: 1))
					newSelectionIndex = start.index - 1
				}
			}
		} else if let start = currentSelectedTextRange.start as? CustomTextPosition, let end = currentSelectedTextRange.end as? CustomTextPosition { // there is a selection
			textStorage.deleteCharacters(in: NSRange(location: start.index, length: end.index - start.index))
			newSelectionIndex = start.index
		}
		
		self.currentSelectedTextRange = CustomTextRange(startIndex: newSelectionIndex, endIndex: newSelectionIndex)
		
		invalidateIntrinsicContentSize()
		setNeedsDisplay()
	}
	
	
}
