// Licensed under the MIT License.

import UIKit

/// A simple custom text label that conforms to `UITextInput` for use with `UITextInteraction`
class CustomTextLabel: UIView {
	
	/// Primary initializer that takes in the labelText to display for this label
	/// - Parameter labelText: the string to display
	init(labelText: String) {
		self.labelText = labelText
		super.init(frame: .zero)
		commonInit()
	}
	
	/// Initializer for using `CustomTextLabel` with interface builder
	/// - Parameter coder: An unarchiver object
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	/// A convenience initializer for a custom text label with an empty labelText
	convenience init() {
		self.init(labelText: "")
	}
	
	/// Common code to be called after initialization
	private func commonInit() {
		self.backgroundColor = .systemBackground
	}
	
	/// The width of the caret rect for use in `UITextInput` conformance
	fileprivate static let caretWidth: CGFloat = 2.0
	
	/// The font used by the the `CustomTextLabel`
	fileprivate static let font = UIFont.systemFont(ofSize: 20.0)
	
	/// The text to be drawn to screen by this `CustomTextLabel`
	var labelText: String = "" {
		didSet {
			textDidChange()
		}
	}
	
	/// A simple draw call override that uses `NSAttributedString` to draw `labelText` with `attributes`
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		let attributedString = NSAttributedString(string: labelText, attributes: attributes)
		attributedString.draw(in: rect)
	}
	
	/// An intrinsicContentSize override to size this view based on the size of `labelText` when drawn with `attributes`
	override var intrinsicContentSize: CGSize {
		let size = NSAttributedString(string: labelText, attributes: attributes).size()
		return CGSize(width: ceil(size.width), height: ceil(size.height))
	}
	
	/// A helper function to call when our text contents have changed
	fileprivate func textDidChange() {
		invalidateIntrinsicContentSize()
		setNeedsDisplay()
	}
	
	/// The attributes used by this text label to draw the text in `labelText`
	var attributes: [NSAttributedString.Key: Any]? = {
		return [
			.foregroundColor: UIColor.label,
			.backgroundColor: UIColor.systemBackground,
			.font: CustomTextLabel.font,
		]
	}()
	
	/// The currently selected text range, which gets modified via UITextInput's callbacks
	var currentSelectedTextRange: UITextRange? = CustomTextRange(startOffset: 0, endOffset: 0)
	
	/// A text view should be allowed to become first responder
	override var canBecomeFirstResponder: Bool {
		true
	}
	
	/// Return an array of substrings split on the newline character
	/// - Parameter string: the string to be split
	/// - Returns: an array of the substrings, split on `\n`
	static fileprivate func linesFromString(string: String) -> [Substring] {
		return string.split(separator: "\n", omittingEmptySubsequences: false)
	}
}

// MARK: - UITextInput Conformance

/// `UITextInput` conformance for our `CustomTextLabel`
extension CustomTextLabel: UITextInput {
	
	func text(in range: UITextRange) -> String? {
		guard let rangeStart = range.start as? CustomTextPosition, let rangeEnd = range.end as? CustomTextPosition else {
			fatalError()
		}
		let location =  max(rangeStart.offset, 0)
		let length = max(min(labelText.count - location, rangeEnd.offset - location), 0)
		
		guard location < labelText.count,
			  let subrange = Range(NSRange(location: location, length:length), in: labelText) else {
			return nil
		}
		
		return String(labelText[subrange])
	}
	
	func replace(_ range: UITextRange, withText text: String) {
		guard let range = range as? CustomTextRange,
			  let textSubrange = Range(NSRange(location: range.startOffset, length: range.endOffset - range.startOffset), in: self.labelText) else {
			fatalError()
		}
		
		self.labelText.replaceSubrange(textSubrange, with: text)
		textDidChange()
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
		return nil // TODO: confirm this is ok
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
		CustomTextPosition(offset: 0)
	}
	
	var endOfDocument: UITextPosition {
		CustomTextPosition(offset: labelText.count)
	}
	
	func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
		guard let fromPosition = fromPosition as? CustomTextPosition, let toPosition = toPosition as? CustomTextPosition else {
			return nil
		}
		return CustomTextRange(startOffset: fromPosition.offset, endOffset: toPosition.offset)
	}
	
	func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
		guard let position = position as? CustomTextPosition else {
			return nil
		}
		
		let proposedIndex = position.offset + offset
		
		// return nil if proposed index is out of bounds, per documentation
		guard proposedIndex >= 0 && proposedIndex <= labelText.count else {
			return nil
		}
		
		return CustomTextPosition(offset: proposedIndex)
	}
	
	func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
		guard let position = position as? CustomTextPosition else {
			return nil
		}
		
		var proposedIndex: Int = position.offset
		if direction == .left {
			proposedIndex = position.offset - offset
		}
		
		if direction == .right {
			proposedIndex = position.offset + offset
		}
		
		// return nil if proposed index is out of bounds
		guard proposedIndex >= 0 && proposedIndex <= labelText.count else {
			return nil
		}
		
		return CustomTextPosition(offset: proposedIndex)
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
		
		return toPosition.offset - from.offset
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
			return CustomTextRange(startOffset: 0, endOffset: position.offset)
		case .right, .down:
			return CustomTextRange(startOffset: position.offset, endOffset: labelText.count)
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
		guard let rangeStart = range.start as? CustomTextPosition,
			  let rangeEnd = range.end as? CustomTextPosition else {
			return .zero
		}
		
		// Determine which line index and line the range starts in
		let (startLineIndex, startLine) = indexAndLine(from: rangeStart)
		
		// Determine the x position
		var initialXPosition: CGFloat = 0
		var rectWidth: CGFloat = 0
		
		// If our start and end line indices are the same, just get the whole range
		if rangeStart.offset >= labelText.count {
			initialXPosition = self.intrinsicContentSize.width
		} else {
			let startTextIndex = labelText.index(labelText.startIndex, offsetBy: rangeStart.offset)
			let endTextIndex = labelText.index(startTextIndex, offsetBy: max(rangeEnd.offset - rangeStart.offset - 1, 0))
			
			// Get the substring from the start of the line we're on to the start of our selection
			let preSubstring = startLine.prefix(upTo: labelText.index(labelText.startIndex, offsetBy: rangeStart.offset))
			let preSize = NSAttributedString(string: String(preSubstring), attributes: attributes).size()
			
			// Get the substring from the start of our range to the end of the line
			let selectionLineEndIndex = min(endTextIndex, startLine.index(before: startLine.endIndex))
			let actualSubstring = startLine[startTextIndex...selectionLineEndIndex]
			let actualSize = NSAttributedString(string: String(actualSubstring), attributes: attributes).size()
			
			initialXPosition = preSize.width
			rectWidth = actualSize.width
		}
		
		// Return the rect
		return CGRect(x: initialXPosition, y: CGFloat(startLineIndex)*CustomTextLabel.font.lineHeight, width: rectWidth, height: CustomTextLabel.font.lineHeight)
	}
	
	func caretRect(for position: UITextPosition) -> CGRect {
		// Turn our text position into an index into `labelText`
		let labelTextPositionIndex = stringIndex(from: position)
		
		// Determine what line index and line our text position is on
		let (lineIndex, line) = indexAndLine(from: position)
		
		// Get the substring from the beginning of that line up to our text position
		let substring = line.prefix(upTo: labelTextPositionIndex)
		
		// Check the size of that substring, our caret should draw just to the right edge of this range
		let size = NSAttributedString(string: String(substring), attributes: attributes).size()
		
		// Make the caret rect, accounting for which line we're on
		return CGRect(x: size.width, y:CustomTextLabel.font.lineHeight * CGFloat(lineIndex), width: CustomTextLabel.caretWidth, height: CustomTextLabel.font.lineHeight)
	}
	
	func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
		guard let rangeStart = range.start as? CustomTextPosition,
			  let rangeEnd = range.end as? CustomTextPosition else {
			fatalError()
		}
		
		let lines = CustomTextLabel.linesFromString(string: labelText)
		// Determine which line index and line the range starts and ends in
		let (startLineIndex, _) = indexAndLine(from: rangeStart)
		let (endLineIndex, _) = indexAndLine(from: rangeEnd)
		
		// Translate our range indexes into text indexes
		let startTextIndex = labelText.index(labelText.startIndex, offsetBy: rangeStart.offset)
		let endTextIndex = labelText.index(startTextIndex, offsetBy: max(rangeEnd.offset - rangeStart.offset - 1, 0))
		
		var selectionRects: [CustomTextSelectionRect] = []
		for (index, line) in lines.enumerated() {
			// Check if this is a valid line for selection
			if !line.isEmpty && index >= startLineIndex && index <= endLineIndex {
				let containsStart = line.startIndex <= startTextIndex && startTextIndex < line.endIndex
				let containsEnd = line.startIndex <= endTextIndex && endTextIndex < line.endIndex
				
				// Get the substring from the start of our range to the end of the line
				let selectionLineStartIndex = max(startTextIndex,line.startIndex)
				let selectionLineEndIndex = max(min(endTextIndex, line.index(before: line.endIndex)), selectionLineStartIndex)
				let actualSubstring = line[selectionLineStartIndex...selectionLineEndIndex]
				let actualSize = NSAttributedString(string: String(actualSubstring), attributes: attributes).size()
				
				// Set the initial x position
				var initialXPosition: CGFloat = 0
				if containsStart {
					// Get the substring from the start of the line we're on to the start of our selection
					let preSubstring = line.prefix(upTo: labelText.index(labelText.startIndex, offsetBy: rangeStart.offset))
					let preSize = NSAttributedString(string: String(preSubstring), attributes: attributes).size()
					initialXPosition = preSize.width
				}
				
				let rectWidth = actualSize.width
				
				// Make the selection rect for this line
				let rect = CGRect(x: initialXPosition, y: CGFloat(index)*CustomTextLabel.font.lineHeight, width: rectWidth, height: CustomTextLabel.font.lineHeight)
				selectionRects.append(CustomTextSelectionRect(rect: rect, writingDirection: .leftToRight, containsStart: containsStart, containsEnd: containsEnd, isVertical: false))
			}
		}
		
		// Return our constructed array
		return selectionRects
	}
	
	func closestPosition(to point: CGPoint) -> UITextPosition? {
		let lines = CustomTextLabel.linesFromString(string: labelText)
		// Get a valid line index
		let lineIndex = max(min(Int(point.y /  CustomTextLabel.font.lineHeight), lines.count - 1), 0)
		// Get the line from that index
		let line = lines[lineIndex]
		
		var totalWidth: CGFloat = 0.0
		for (index, character) in line.enumerated() {
			let characterSize = NSAttributedString(string: String(character), attributes: attributes).size()
			
			if totalWidth <= point.x && point.x < totalWidth + characterSize.width {
				// Selection ocurred inside this character, should we go one back or one forward?
				let offset = point.x - totalWidth > characterSize.width / 2.0
					? index + 1
					: index
				// Calculate our offset in terms of the full string, not just this line.
				let labelTextIndex = line.index(line.startIndex, offsetBy: offset)
				return CustomTextPosition(offset: labelText.distance(from: labelText.startIndex, to: labelTextIndex))
				
			} else {
				totalWidth = totalWidth + characterSize.width
			}
		}
		return CustomTextPosition(offset: 0)
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
		return CustomTextRange(startOffset: textPosition.offset, endOffset: textPosition.offset + 1)
	}
	
	// MARK: - UIKeyInput
	
	var hasText: Bool {
		!labelText.isEmpty
	}
	
	func insertText(_ text: String) {
		if let currentSelectedTextRange = currentSelectedTextRange {
			replace(currentSelectedTextRange, withText: text)
			textDidChange()
		}
		
		if let start = currentSelectedTextRange?.start as? CustomTextPosition {
			let newSelectionLocation = start.offset + text.count
			currentSelectedTextRange = CustomTextRange(startOffset: newSelectionLocation, endOffset: newSelectionLocation)
		}
	}
	
	func deleteBackward() {
		guard let currentSelectedTextRange = currentSelectedTextRange else {
			// no selection, how do we delete?
			fatalError()
		}
		
		var newSelectionIndex = 0
		if currentSelectedTextRange.isEmpty { // empty selection, just use the start position and move back by one if possible
			if let start = currentSelectedTextRange.start as? CustomTextPosition, start.offset > 0, start.offset <= labelText.count {
				if start.offset - 1 > 0 {
					if let subrange = Range(NSRange(location: start.offset - 1, length: 1), in: labelText) {
						labelText.removeSubrange(subrange)
						newSelectionIndex = start.offset - 1
					}
				}
			}
		} else if let start = currentSelectedTextRange.start as? CustomTextPosition, let end = currentSelectedTextRange.end as? CustomTextPosition { // there is a selection
			if let subrange = Range(NSRange(location: start.offset, length: end.offset - start.offset), in: labelText) {
				labelText.removeSubrange(subrange)
				newSelectionIndex = start.offset
			}
		}
		
		self.currentSelectedTextRange = CustomTextRange(startOffset: newSelectionIndex, endOffset: newSelectionIndex)
		textDidChange()
	}
	
	// MARK: - Helpers
	
	/// Return the line index and the substring representing the line of a given `UITextPosition`
	/// - Parameter position: The position used to determine the line and index
	/// - Returns: a tuple containing the integer index and the substring representing the line that contains the passed in `position`
	private func indexAndLine(from position: UITextPosition) -> (Int, Substring) {
		// Turn our text position into an index into `labelText`
		let labelTextPositionIndex = stringIndex(from: position)
		
		// Split `labelText` into an array of substrings where each line is a substring
		let lines = CustomTextLabel.linesFromString(string: labelText)
		
		// Figure out which line contains our text position
		guard let lineIndex = lines.firstIndex(where: {
			// Check if our overall index into the string is on this line
			$0.startIndex <= labelTextPositionIndex && labelTextPositionIndex <= $0.endIndex
		}) else {
			// Our index we're looking for isn't contained in labelString? Let's just default to
			// the beginning of the string
			return (0, lines[0])
		}
		return (lineIndex, lines[lineIndex])
	}
	
	/// Turn  a `UITextPosition` into a String Index into `labelText`
	/// - Parameter textPosition: the text position to translate into a string index
	/// - Returns: the corresponding string index
	private func stringIndex(from textPosition: UITextPosition) -> String.Index {
		guard let position = textPosition as? CustomTextPosition else {
			fatalError()
		}
		
		// Turn our text position into an index into `labelText`
		return labelText.index(labelText.startIndex, offsetBy: max(position.offset, 0))
	}
}
