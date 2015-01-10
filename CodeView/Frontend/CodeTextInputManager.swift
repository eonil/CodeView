//
//  CodeTextInputManager.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

///	Manages text input using IME.
///	This supports only in-line text input. No support for multiline-spanning text input.
class CodeTextInputManager {
	var	_buffer				=	NSMutableString()
	var	_markedRange		=	nil as Range<UTF16Index>?
	
	//	Essential methods.
	//	You need to make some proper selection management for your application.

	func selectedRange() -> NSRange {
		return	NSRange(location: _buffer.length, length: 0)
	}
	func markedRange() -> NSRange {
		return	NSRange.fromUTF16Range(_markedRange)
	}
	func hasMarkedText() -> Bool {
		return	_markedRange != nil
	}
	
	func insertText(aString: AnyObject, replacementRange: NSRange) {
		let	s	=	findNSStringObject(aString)
		let	r	=	replacementRange.location != NSNotFound ? replacementRange : (_markedRange != nil ? self.markedRange() : self.selectedRange())
		
		_buffer.replaceCharactersInRange(r, withString: s)
		self.unmarkText()
		self.inputContext!.invalidateCharacterCoordinates()
		
		println("insertText, current buffer = \(_buffer)")
	}
	func setMarkedText(aString: AnyObject, selectedRange: NSRange, replacementRange: NSRange) {
		let	s	=	findNSStringObject(aString)
		let	r	=	replacementRange.location != NSNotFound ? replacementRange : (_markedRange != nil ? self.markedRange() : self.selectedRange())
		
		_buffer.replaceCharactersInRange(r, withString: s)
		_markedRange	=	r.location..<(r.location+s.length)
		
		println("setMarkedText, current buffer = \(_buffer)")
	}
	func unmarkText() {
		_markedRange	=	nil
		self.inputContext!.discardMarkedText()
		
		println("unmarkText, current buffer = \(_buffer)")
	}
}