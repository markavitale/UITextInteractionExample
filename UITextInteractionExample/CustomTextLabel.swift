// Licensed under the MIT License.

import UIKit

class CustomTextLabel: UIView {
	static let caretWidth: CGFloat = 2.0
	var labelText: String = ""
	
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
		let attributedString = NSAttributedString(string: labelText, attributes: attributes)
		attributedString.draw(in: rect)
	}
	
	override var intrinsicContentSize: CGSize {
		let size = NSAttributedString(string: labelText, attributes: attributes).size()
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
		let length = max(min(labelText.count - location, rangeEnd.index - location), 0)
		
		guard location < labelText.count,
			let subrange = Range(NSRange(location: location, length:length), in: labelText) else {
			return nil
		}
		
		return String(labelText[subrange])
	}
	
	func replace(_ range: UITextRange, withText text: String) {
		guard let range = range as? CustomTextRange,
		let textSubrange = Range(NSRange(location: range.startIndex, length: range.endIndex - range.startIndex), in: self.labelText) else {
			fatalError()
		}
		
		self.labelText.replaceSubrange(textSubrange, with: text)
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
		CustomTextPosition(index: labelText.count) // TODO: -1?
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
		guard proposedIndex >= 0 && proposedIndex <= labelText.count else {
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
		guard proposedIndex >= 0 && proposedIndex <= labelText.count else {
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
			return CustomTextRange(startIndex: position.index, endIndex: labelText.count)
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
		
		var initialXposition: CGFloat = 0
		var rectWidth: CGFloat = 0
		if rangeStart.index >= labelText.count {
			initialXposition = self.intrinsicContentSize.width
		} else {
			let startTextIndex = labelText.index(labelText.startIndex, offsetBy: rangeStart.index)
			let endTextIndex = labelText.index(startTextIndex, offsetBy: max(rangeEnd.index - rangeStart.index - 1, 0))
			
			let preSubstring = labelText.prefix(upTo: labelText.index(labelText.startIndex, offsetBy: rangeStart.index))
			let preSize = NSAttributedString(string: String(preSubstring), attributes: attributes).size()
			let actualSubstring = labelText[startTextIndex...endTextIndex]
			
			let actualSize = NSAttributedString(string: String(actualSubstring), attributes: attributes).size()
			initialXposition = preSize.width
			rectWidth = actualSize.width
		}
		return CGRect(x: initialXposition, y: 0, width: rectWidth, height: font.lineHeight)
	}
	
	func caretRect(for position: UITextPosition) -> CGRect {
		guard let position = position as? CustomTextPosition,
			let font = attributes?[.font] as? UIFont else {
				return bounds
		}
		
		let substring = labelText.prefix(max(position.index, 0))
		let size = NSAttributedString(string: String(substring), attributes: attributes).size()
		return CGRect(x: size.width, y: 0, width: CustomTextLabel.caretWidth, height: font.lineHeight)
	}
	
	func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
		guard let rangeStart = range.start as? CustomTextPosition, let rangeEnd = range.end as? CustomTextPosition else {
			fatalError()
		}
		return [CustomTextSelectionRect(rect: firstRect(for: range), writingDirection: .leftToRight, containsStart: rangeStart.index == 0, containsEnd: rangeEnd.index == labelText.count, isVertical: false)]
	}
	
	func closestPosition(to point: CGPoint) -> UITextPosition? {
		var totalWidth: CGFloat = 0.0
		for (index, character) in labelText.enumerated() {
			let characterSize = NSAttributedString(string: String(character), attributes: attributes).size()

			if totalWidth <= point.x && point.x < totalWidth + characterSize.width {
				// Selection ocurred inside this character, should we go one back or one forward?
				if point.x - totalWidth > characterSize.width / 2.0 {
					return CustomTextPosition(index: index + 1)
				} else {
					return CustomTextPosition(index: index)
				}
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
		!labelText.isEmpty
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
			if let start = currentSelectedTextRange.start as? CustomTextPosition, start.index > 0, start.index <= labelText.count {
				if start.index - 1 > 0 {
					if let subrange = Range(NSRange(location: start.index - 1, length: 1), in: labelText) {
						labelText.removeSubrange(subrange)
						newSelectionIndex = start.index - 1
					}
				}
			}
		} else if let start = currentSelectedTextRange.start as? CustomTextPosition, let end = currentSelectedTextRange.end as? CustomTextPosition { // there is a selection
			if let subrange = Range(NSRange(location: start.index, length: end.index - start.index), in: labelText) {
				labelText.removeSubrange(subrange)
				newSelectionIndex = start.index
			}
		}
		
		self.currentSelectedTextRange = CustomTextRange(startIndex: newSelectionIndex, endIndex: newSelectionIndex)
		
		invalidateIntrinsicContentSize()
		setNeedsDisplay()
	}
	
	
}
