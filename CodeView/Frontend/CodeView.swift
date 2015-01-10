//
//  CodeView.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import CoreText

///	Public interface to code-view system.
class CodeView: NSView {
	override convenience init() {
		self.init(frame: CGRect.zeroRect)
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		configure()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
	
//	var storage:CodeStorage {
//		get {
//			return	_storage
//		}
//	}
	var	font:NSFont {
		get {
			return	_render.font
		}
		set(v) {
			_render.font	=	v
		}
	}
	
	func loadFileAtPath(path:String) {
		_storage.appendContentOfFile(path)
		adjustRendering()
	}
	
	override func resizeSubviewsWithOldSize(oldSize: NSSize) {
		super.resizeSubviewsWithOldSize(oldSize)
		adjustRendering()
	}
	override func resetCursorRects() {
		addCursorRect(self.bounds, cursor: NSCursor.IBeamCursor())
	}
	override func mouseDown(theEvent: NSEvent) {
		super.mouseDown(theEvent)
		let	oldRange	=	_selection.range
		_selection.notifyMouseDown(theEvent)
		let	newRange	=	_selection.range
	}
	override func mouseDragged(theEvent: NSEvent) {
		super.mouseDragged(theEvent)
		_selection.notifyMouseDrag(theEvent)
		
	}
	override func mouseUp(theEvent: NSEvent) {
		super.mouseUp(theEvent)
		_selection.notifyMouseUp(theEvent)
	}
	
	////
	

	//
	//	Subcomponent types can be dependent to another as in order defined below.
	//	For example, `CodeSelectionManager` can access `CaretManager`, but not vice versa.
	//	`CodeRenderingView` can refer `CodeSelectionManager`, but not vice versa.
	//
	
	private let	_storage		=	CodeStorage()
	private let	_caretman		=	CaretManager()
	private let	_selection		=	CodeSelectionManager()
//	private let	_inputman		=	CodeTextInputManager()
	
	private let	_render			=	CodeRenderingView()
	private let	_scr			=	NSScrollView()
	
	private let	_delproc		=	CodeViewDelegationProcessor()
	
	private func configure() {
		_render.owner		=	self
		
		self.addSubview(_scr)
		_scr.documentView			=	_render
		_scr.hasHorizontalScroller	=	true
		_scr.hasVerticalScroller	=	true
		_scr.wantsLayer				=	true
		_scr.layer!.backgroundColor	=	NSColor.whiteColor().CGColor
		
		_scr.flashScrollers()
		
		adjustRendering()
		
		////
		
		_delproc.owner		=	self
		_caretman.delegate	=	_delproc
		_selection.delegate	=	_delproc
		_render.delegate	=	_delproc
	}
	
	private func adjustRendering() {
		let	w	=	_render.font.xHeight * 128		//	TODO:	Figure out a better way.
		let	b	=	self.bounds
		_scr.frame		=	b
		
		let	lineH		=	_render.queryLineHeight()
		let	lineC		=	_storage.lines.count
		let	renderH		=	lineH * CGFloat(lineC)
		_render.frame	=	CGRect(x: 0, y: 0, width: w, height: renderH)
	}
}

internal extension CodeView {
//	var selection:CodeSelectionManager {
//		get {
//			return	_selection
//		}
//	}
	var storage:CodeStorage {
		get {
			return	_storage
		}
	}
//	var renderingView:CodeRenderingView {
//		get {
//			return	_render
//		}
//	}
}




//extension CodeView: NSTextInput {
//	//	Essential methods.
//	func selectedRange() -> NSRange {
//		return	_inputman.selectedRange()
//	}
//	func markedRange() -> NSRange {
//		return	_inputman.markedRange()
//	}
//	func hasMarkedText() -> Bool {
//		return	_inputman.hasMarkedText()
//	}
//	
//	func insertText(aString: AnyObject, replacementRange: NSRange) {
//		_inputman.insertText(aString, replacementRange: replacementRange)
//	}
//	func setMarkedText(aString: AnyObject, selectedRange: NSRange, replacementRange: NSRange) {
//		_inputman.setMarkedText(aString, selectedRange: selectedRange, replacementRange: replacementRange)
//	}
//	func unmarkText() {
//		_inputman.unmarkText()
//	}
//	
//	///	Non-essential methods, but required. Implemented all as just empty.
//	func attributedSubstringForProposedRange(aRange: NSRange, actualRange: NSRangePointer) -> NSAttributedString? {
//		return	nil
//	}
//	func validAttributesForMarkedText() -> [AnyObject] {
//		return	[]
//	}
//	func firstRectForCharacterRange(aRange: NSRange, actualRange: NSRangePointer) -> NSRect {
//		return	CGRect.zeroRect
//	}
//	func characterIndexForPoint(aPoint: NSPoint) -> Int {
//		return	NSNotFound
//	}
//	
//	///	Responder chain management.
//	override var acceptsFirstResponder:Bool {
//		get {
//			return	true
//		}
//	}
//	override func becomeFirstResponder() -> Bool {
//		return	true
//	}
//	override func resignFirstResponder() -> Bool {
//		return	true
//	}
//	override func keyDown(theEvent: NSEvent) {
//		self.inputContext!.handleEvent(theEvent)
//	}
//}

















































private class CodeViewDelegationProcessor: CaretManagerDelegate, CodeSelectionManagerDelegate, CodeRenderingViewDelegate {
	weak var owner:CodeView?	=	nil
	
	var caret:CaretManager {
		get {
			return	owner!._caretman
		}
	}
	var rendering:CodeRenderingView {
		get {
			return	owner!._render
		}
	}
	var selection:CodeSelectionManager {
		get {
			return	owner!._selection
		}
	}
	
	////
	
	private var	oldSelectionRange:CodeRange?	=	nil
	
	private func invaldateGraphicsByCodeRange(range:CodeRange) {
		if range.isEmpty {
			//	Invalidate area for caret.
			let	newbs	=	rendering.queryFramesForCodeRange(range)
			for b in newbs {
				let	b1	=	b.rectByAddingWith(10)
				rendering.setNeedsDisplayInRect(b1)
			}
		} else {
			let	newbs	=	rendering.queryFramesForCodeRange(range)
			for b in newbs {
				rendering.setNeedsDisplayInRect(b)
			}
		}
	}
	
	private func caretDisplayStateWillChange() {
	}
	private func caretDisplayStateDidChange() {
		invaldateGraphicsByCodeRange(selection.range)
	}
	
	private func selectionQueryCodePointAtGraphicsPointInWindow(point: CGPoint) -> CodePoint? {
		let	p1	=	rendering.convertPoint(point, fromView: nil)
		let	p2	=	rendering.queryCodePointAtGraphicsPoint(p1)
		return	p2
	}
	private func selectionWillChange() {
		oldSelectionRange	=	selection.range
	}
	private func selectionDidChange() {
		caret.resetBlinking()
		invaldateGraphicsByCodeRange(oldSelectionRange!)
		invaldateGraphicsByCodeRange(selection.range)
	}

	private func codeRenderingViewQueryCaretDisplayState() -> Bool {
		return	caret.hidden == false
	}
	
	private func codeRenderingViewQuerySelectionRange() -> CodeRange {
		return	selection.range
	}
}










































