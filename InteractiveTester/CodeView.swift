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
	var	font:NSFont = NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())! {
		didSet {
			adjustRendering()
			self.needsDisplay	=	true
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
		_selection.notifyMouseDown(theEvent)
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
	
	private let	_storage		=	CodeStorage()
	private let	_selection		=	CodeSelection()
	
	private let	_render			=	CodeRenderingView()
	private let	_scr			=	NSScrollView()
	
	private func configure() {
		_render.owner		=	self
		_selection.owner	=	self
		
		self.addSubview(_scr)
		_scr.documentView			=	_render
		_scr.hasHorizontalScroller	=	true
		_scr.hasVerticalScroller	=	true
		_scr.wantsLayer				=	true
		_scr.layer!.backgroundColor	=	NSColor.whiteColor().CGColor
		
		_scr.flashScrollers()
		
		adjustRendering()
	}
	
	private func adjustRendering() {
		let	w	=	font.xHeight * 128
		let	b	=	self.bounds
		_scr.frame		=	b
		
		let	lineH		=	_render.lineHeight()
		let	lineC		=	_storage.lines.count
		let	renderH		=	lineH * CGFloat(lineC)
		_render.frame	=	CGRect(x: 0, y: 0, width: w, height: renderH)
	}
}























///	MARK:
///	MARK:	Selection

private class CodeSelection {
	weak var	owner	=	nil as CodeView?
	var			start	=	nil as CodePoint?
	var			end		=	nil as CodePoint?
	
	var	range:CodeRange? {
		get {
			if start != nil && end != nil {
				let	s	=	min(start!, end!)
				let	e	=	max(start!, end!)
				return	s..<e
			}
			return	nil
		}
	}
	func notifyMouseDown(e:NSEvent) {
		if let p = queryCodePathAtMouseEvent(e) {
			start	=	p
		}
	}
	func notifyMouseDrag(e:NSEvent) {
		
		if let p = queryCodePathAtMouseEvent(e) {
			end		=	p
		}
		owner!._render.needsDisplay	=	true
	}
	func notifyMouseUp(e:NSEvent) {
		
		if let p = queryCodePathAtMouseEvent(e) {
			end		=	p
		}
		owner!._render.needsDisplay	=	true
	}
	func containsLine(line index:Int) -> Bool {
		if let r = range {
			return	r.startPoint.line <= index && index <= r.endPoint.line
		} else {
			return	false
		}
	}
	func containsPoint(point:CodePoint) -> Bool {
		if let r = range {
			return	r.startPoint <= point && point <= r.endPoint
		} else {
			return	false
		}
	}
	///	Returns column (UTF-8 code unit) of selected range if the line is selected.
	func columnRangeInLineAtIndex(line index:Int) -> Range<Int>? {
		if let r = range {
			if containsLine(line: index) {
				let	ln	=	owner!._storage.lines[index]
				let	startP	=	r.startPoint.line == index ? r.startPoint.column : 0
				let	endP	=	r.endPoint.line == index ? r.endPoint.column : ln.data.count
				return	startP..<endP
			}
			
		}
		return	nil
	}
	
	////
	
	private func queryCodePathAtMouseEvent(e:NSEvent) -> CodePoint? {
		let	p	=	e.locationInWindow
		let	p1	=	owner!._render.convertPoint(p, fromView: nil)
		let	p2	=	owner!._render.codePointAtGraphicsPoint(p1)
		return	p2
	}
}














































///	MARK:
///	MARK:	Rendering


private class CodeRenderingView: NSView {
	weak var owner:CodeView?
	
	func lineHeight() -> CGFloat {
		precondition(owner != nil)
		let	f	=	owner!.font
		let	asc	=	f.ascender
		let	des	=	f.descender
		let	led	=	f.leading
		let	lh	=	asc - des + led
		let	lh1	=	ceil(lh)
		return	lh1
	}
	
	func visibleLineIndexRange() -> Range<Int> {
		precondition(owner != nil)
		let	b	=	owner!.bounds
		let	r	=	lineIndexRangeInBounds(b)
		return	r
	}
	
	func lineIndexRangeInBounds(bounds:CGRect) -> Range<Int> {
		precondition(owner != nil)
		let	p1	=	computeLineIndexAtY(bounds.maxY)
		let	p2	=	computeLineIndexAtY(bounds.minY)
		return	p1...p2
	}
	
	///	point:	is a point in reciever's bounds.
	func codePointAtGraphicsPoint(point:CGPoint) -> CodePoint? {
		let	idx		=	computeLineIndexAtY(point.y)
		if idx < owner!._storage.lines.count {
			let	line	=	owner!._storage.lines[idx]
			let	gline	=	DrawableLine(line: line, font: owner!.font)
			if let col = gline.UTF8IndexForX(point.x) {
				return	CodePoint(line: idx, column: col)
			}
		}
		return	nil
	}
	
	override func drawRect(dirtyRect: NSRect) {
		precondition(owner != nil)
//		NSColor.redColor().colorWithAlphaComponent(CGFloat(random()) / CGFloat(Int32.max)).setFill()
//		CGContextFillRect(NSGraphicsContext.currentContext()!.CGContext, dirtyRect)
		
		let	style	=	defaultStyle()
		
		let	f		=	owner!.font
		let	b		=	self.bounds
		let	ctx		=	NSGraphicsContext.currentContext()!.CGContext
		let	lineH	=	lineHeight()
		
		let	topY				=	b.maxY
		let	lineCountAtStartY	=	computeLineIndexAtY(dirtyRect.maxY)
		let	lineCountAtEndY		=	computeLineIndexAtY(dirtyRect.minY)

		let	bidx				=	min(owner!._storage.lines.count, lineCountAtStartY)
		let	eidx				=	min(owner!._storage.lines.count, lineCountAtEndY + 1)
		let	drawingLineRange	=	bidx..<eidx
//		println(drawingLineRange)
		
		let	drawingStartY		=	topY - (CGFloat(lineCountAtStartY) * lineH)
		var	basepointY			=	drawingStartY - f.ascender
		
		for i in drawingLineRange {
			let	line	=	owner!._storage.lines[i]
			CGContextSetTextPosition(ctx, 0, basepointY)
			
			let	dline	=	DrawableLine(line: line, font: f)
			let	sel		=	owner!._selection.columnRangeInLineAtIndex(line: i)
			
			if let sel1 = sel {
				let	startX	=	dline.xForUTF8Index(sel1.startIndex)
				let	endX	=	dline.xForUTF8Index(sel1.endIndex)
				let	fillF	=	CGRect(x: startX, y: basepointY + f.ascender - lineH, width: endX - startX, height: lineH)
				NSColor.blueColor().colorWithAlphaComponent(0.2).setFill()
				CGContextFillRect(ctx, fillF)
			}
			
			dline.draw(ctx)
			
			basepointY	-=	lineH
		
//			if basepointY < dirtyRect.minY {
//				break
//			}
		}
	}
	
	
	////
	
	///	y:	is a point in receiver's boudning space.
	///
	///	This simply computes the index by the position, and does not check actual existence of the line at the index.
	private func computeLineIndexAtY(y:CGFloat) -> Int {
		let	topY		=	self.bounds.maxY
		let	distFromTop	=	topY - y
		let	lineCount	=	Int(floor(distFromTop/lineHeight()))
		return	lineCount
	}
	
	private func defaultStyle() -> OBJCDictionary {
//		struct Slot {
//			static let	value	=	[
//				NSFontAttributeName:			owner!.font,
//			]
//		}
//		return	Slot.value
		return	[
			NSFontAttributeName:			owner!.font,
		]
	}
}


/////	Caches line object for lines that being displayed on current screen.
/////	This automatically purges invisible lines.
//private class LineDrawingLayoutManager {
//	weak var owner:CodeView?
//	
//	func drawableLineForLineAtIndex(line index:Int) -> CTLine {
//		let	r1	=	owner!._render.visibleLineIndexRange()
//		
//	}
//	
//	private var	_glines	=	[:] as [Int:[CTLine]]
//	
//}



//private struct Palette {
//	let	normal:OBJCDictionary
//	let	selection:OBJCDictionary
//}
private typealias	OBJCDictionary	=	[NSObject:AnyObject]



private struct DrawableLine {
	init(line:CodeLine, font:NSFont) {
		self.line	=	line
		self.font	=	font
		
		self.string	=	line.string
		let	attrs	=	[
			NSFontAttributeName:			self.font,
		]
		self.text	=	NSAttributedString(string: string, attributes: attrs)
		self.gline	=	CTLineCreateWithAttributedString(self.text)
	}
	
	func typographicsWidth() -> CGFloat {
		let	lineW	=	CGFloat(CTLineGetTypographicBounds(gline, nil, nil, nil))
		return	lineW
	}
	
	///	TODO:	Optimise.
	func xForUTF8Index(index:Int) -> CGFloat {
		let	d1			=	line.data[0..<index]
		let	s			=	decodeFromUTF8Data(ContiguousArray<UTF8.CodeUnit>(d1))
		let	utf16idx	=	s.utf16Count
		return	xForUTF16Index(utf16idx)
	}
	
	///	TODO:	Optimise.
	func UTF8IndexForX(x:CGFloat) -> Int? {
		if let utf16idx = UTF16IndexForX(x) {
			let	s1:NSString	=	string.substringWithRange(NSRange(location: 0, length: utf16idx))
			let	len			=	s1.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			return	len
		}
		return	nil
	}
	
	func draw(context:CGContext) {
		CTLineDraw(gline, context)
	}
	
	////
	
	private let	line:CodeLine
	private let	font:NSFont
	private let	string:NSString
	private	let	text:NSAttributedString
	private let	gline:CTLine
	
	private func xForUTF16Index(index:Int) -> CGFloat {
		return	CTLineGetOffsetForStringIndex(gline, index, nil)
	}
	
	private func UTF16IndexForX(x:CGFloat) -> Int? {
		let	idx	=	CTLineGetStringIndexForPosition(gline, CGPoint(x: x, y: 0))
		if idx != kCFNotFound {
			return	idx
		}
		return	nil
	}
}















