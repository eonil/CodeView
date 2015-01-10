//
//  CodeRenderingView.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit



class CodeRenderingView: NSView {
	weak var delegate:CodeRenderingViewDelegate?	=	nil
	weak var owner:CodeView?	=	nil
	
	var font:NSFont = NSFont(name: "Menlo", size: round(NSFont.smallSystemFontSize()))! {
		didSet {
			self.setNeedsDisplayInRect(bounds)
		}
	}
	
	func queryLineHeight() -> CGFloat {
		precondition(owner != nil)
		let	f	=	font
		let	asc	=	f.ascender
		let	des	=	f.descender
		let	led	=	f.leading
		let	lh	=	asc - des + led
		let	lh1	=	ceil(lh)
		return	lh1
	}
	
	func queryVisibleLineIndexRange() -> Range<Int> {
		precondition(owner != nil)
		let	b	=	owner!.bounds
		let	r	=	queryLineIndexRangeInBounds(b)
		return	r
	}
	
	func queryLineIndexRangeInBounds(bounds:CGRect) -> Range<Int> {
		precondition(owner != nil)
		let	p1	=	computeLineIndexAtY(bounds.maxY)
		let	p2	=	computeLineIndexAtY(bounds.minY)
		return	p1...p2
	}
	
	///	point:	is a point in reciever's bounds.
	func queryCodePointAtGraphicsPoint(point:CGPoint) -> CodePoint? {
		let	idx		=	computeLineIndexAtY(point.y)
		if idx < owner!.storage.lines.count {
			let	line	=	owner!.storage.lines[idx]
			let	gline	=	DrawableLine(line: line, font: font)
			if let col = gline.UTF8IndexForX(point.x) {
				return	CodePoint(line: idx, column: col)
			}
		}
		return	nil
	}
	
	
	///	Returns frames coordinated in receiver's bounding space.
	///
	///	This can return multiple frames because a code-range can span over 
	///	multiple lines, so it cannot be represented by single frame.
	func queryFramesForCodeRange(range:CodeRange) -> [CGRect] {
		return	range.lineSubrangesWithStorage(owner!.storage).map(computeGraphicsFrameForCodeRangeInSingleLine)
	}
	func queryFramesForLineRange(lines range:Range<Int>) -> [CGRect] {
		return	range.map(computeGraphicsFrameForLineAtIndex)
	}
	
	func invalidateDisplayForCodeRange(range:CodeRange) {
		let	fs	=	queryFramesForCodeRange(range)
		for f in fs {
			setNeedsDisplayInRect(f)
		}
	}
	
	
	
	
	
	override func drawRect(dirtyRect: NSRect) {
		precondition(owner != nil)
//		func drawDirtyRectForDebugging() {
//			NSColor.redColor().colorWithAlphaComponent(CGFloat(random()) / CGFloat(Int32.max)).setFill()
//			CGContextFillRect(NSGraphicsContext.currentContext()!.CGContext, dirtyRect)
//		}
//		drawDirtyRectForDebugging()
		
		
		
		
		////
		
		let	style	=	defaultStyle()
		
		let	f		=	font
		let	b		=	self.bounds
		let	ctx		=	NSGraphicsContext.currentContext()!.CGContext
		let	lineH	=	queryLineHeight()
		
		
		
		////	Compute metrics.
		
		let	topY				=	b.maxY
		let	lineCountAtStartY	=	computeLineIndexAtY(dirtyRect.maxY)
		let	lineCountAtEndY		=	computeLineIndexAtY(dirtyRect.minY)

		let	bidx				=	min(owner!.storage.lines.count, lineCountAtStartY)
		let	eidx				=	min(owner!.storage.lines.count, lineCountAtEndY + 1)
		let	dirtyLineRange		=	bidx..<eidx
//		println(dirtyLineRange)
		
		let	drawingStartY		=	topY - (CGFloat(lineCountAtStartY) * lineH)
		var	basepointY			=	drawingStartY - f.ascender
		
		
		
		
//		///
//		NSColor.textBackgroundColor().setFill()
//		CGContextFillRect(ctx, dirtyRect)
		
		
		
		
		
		
		
		
		
		
		////	Draw caret or selection background.
		func drawCaret(point:CodePoint, color:NSColor) {
			let	sel		=	CodeRange(startPoint: point, endPoint: point)
			var	fillF	=	computeGraphicsFrameForCodeRangeInSingleLine(sel)
			let	fillF1	=	CGRect(x: round(fillF.origin.x), y: round(fillF.origin.y), width: fillF.size.width+1, height: round(fillF.size.height))		//	Compensate to align to point grid. (can be overkill on Retina display)
			color.setFill()
			CGContextFillRect(ctx, fillF1)
			NSColor.clearColor().setFill()
		}
		///	Draws in character resolution.
		func drawSelectionBlockBackground(range:CodeRange, color:NSColor) {
			let	s	=	CodePoint(line: dirtyLineRange.startIndex, column: 0)
			let	e	=	CodePoint(line: dirtyLineRange.endIndex, column: 0)
			let	codeRangeToRedraw	=	CodeRange(startPoint: s, endPoint: e)
			let	visiblesel			=	CodeRange.intersection(range, right: codeRangeToRedraw)
			if let visiblesel1 = visiblesel {
				color.setFill()
				for lineR:CodeRange in visiblesel1.lineSubrangesWithStorage(owner!.storage) {
					let	fillF	=	computeGraphicsFrameForCodeRangeInSingleLine(lineR)
					CGContextFillRect(ctx, fillF)
				}
				NSColor.clearColor().setFill()
			}
		}

		let	sel	=	delegate!.codeRenderingViewQuerySelectionRange()
		if sel.isEmpty {
			if delegate!.codeRenderingViewQueryCaretDisplayState() {
				drawCaret(sel.startPoint, NSColor.textColor())
			}
		} else {
			drawSelectionBlockBackground(sel, NSColor.selectedTextBackgroundColor())
		}
		
		
		
		////	Draw text.
		
		///	Draws in line resolution.
		func drawTextOfLines() {
			for i in dirtyLineRange {
				let	line	=	owner!.storage.lines[i]
				CGContextSetTextPosition(ctx, 0, basepointY)
				
				let	dline	=	DrawableLine(line: line, font: f)
				dline.draw(ctx)
				
				basepointY	-=	lineH
			}
		}
		drawTextOfLines()
	}
	
	
	////
	
	///	y:	is a point in receiver's boudning space.
	///
	///	This simply computes the index by the position, and does not check actual existence of the line at the index.
	private func computeLineIndexAtY(y:CGFloat) -> Int {
		let	topY		=	self.bounds.maxY
		let	distFromTop	=	topY - y
		let	lineCount	=	Int(floor(distFromTop/queryLineHeight()))
		return	lineCount
	}
	
	///	Returns a frame coordinated in receiver's bounding space.
	private func computeGraphicsFrameForLineAtIndex(line index:Int) -> CGRect {
		let	f		=	font
		let	line	=	owner!.storage.lines[index]
		let	dline	=	DrawableLine(line: line, font: f)
		
		let	lineH	=	queryLineHeight()
		let	baseY	=	computeTextDrawingBasepointYForLineAtIndex(line: index)
		let	lineW	=	dline.typographicsWidth()
		let	lineF	=	CGRect(x: 0, y: baseY + f.ascender - lineH, width: lineW, height: lineH)
		return	lineF
	}
	
	///	Returns a frame coordinated in receiver's bounding space.
	private func computeGraphicsFrameForCodeRangeInSingleLine(range:CodeRange) -> CGRect {
		assert(range.startPoint.line == range.endPoint.line)
		
		let	f		=	font
		let	line	=	owner!.storage.lines[range.startPoint.line]
		let	dline	=	DrawableLine(line: line, font: f)
		
		let	lineH	=	queryLineHeight()
		let	baseY	=	computeTextDrawingBasepointYForLineAtIndex(line: range.startPoint.line)
		
		let	startX	=	dline.xForUTF8Index(range.startPoint.column)
		let	endX	=	dline.xForUTF8Index(range.endPoint.column)
		let	lineF	=	CGRect(x: startX, y: baseY + f.ascender - lineH, width: endX - startX, height: lineH)
		return	lineF
	}
	
	private func computeTextDrawingBasepointYForLineAtIndex(line index:Int) -> CGFloat {
		let	f		=	font
		let	lineH	=	queryLineHeight()
		let	topY	=	bounds.maxY
		let	lineY	=	topY - (lineH * CGFloat(index))
		let	baseY	=	lineY - f.ascender
		return	baseY
	}
	
	private func defaultStyle() -> OBJCDictionary {
//		struct Slot {
//			static let	value	=	[
//				NSFontAttributeName:			owner!.font,
//			]
//		}
//		return	Slot.value
		return	[
			NSFontAttributeName:			font,
		]
	}
}


protocol CodeRenderingViewDelegate: class {
	///	Returns `true` if the caret is currently visible.
	func codeRenderingViewQueryCaretDisplayState() -> Bool
	func codeRenderingViewQuerySelectionRange() -> CodeRange 
}


























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













