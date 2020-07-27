//
//  CustomTextSelectionRect.swift
//  UITextInteractionExample
//
//  Created by Mark Vitale on 7/27/20.
//  Copyright © 2020 Mark A Vitale. All rights reserved.
//

import UIKit

class CustomTextSelectionRect: UITextSelectionRect {
	
	private let internalRect: CGRect
	private let internalWritingDirection: NSWritingDirection
	private let internalContainsStart: Bool
	private let internalContainsEnd: Bool
	private let internalIsVertical: Bool
	
	init(rect: CGRect, writingDirection: NSWritingDirection, containsStart: Bool, containsEnd: Bool, isVertical: Bool) {
		internalRect = rect
		internalWritingDirection = writingDirection
		internalContainsStart = containsStart
		internalContainsEnd = containsEnd
		internalIsVertical = isVertical
		super.init()
	}
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
