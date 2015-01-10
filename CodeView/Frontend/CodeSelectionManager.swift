//
//  CodeSelectionManager.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit






class CodeSelectionManager {
	weak var	delegate	=	nil as CodeSelectionManagerDelegate?
	var			start		=	CodePoint(line: 0, column: 0)
	var			end			=	CodePoint(line: 0, column: 0)
	
	///	Selection range always must be exists.
	///	This will be kept valid until you modify the code-storage.
	var	range:CodeRange {
		get {
			let	s	=	min(start, end)
			let	e	=	max(start, end)
			return	s..<e
		}
	}
	func notifyMouseDown(e:NSEvent) {
		if let p = queryCodePathAtMouseEvent(e) {
			delegate?.selectionWillChange()
			start	=	p
			end		=	p
			delegate?.selectionDidChange()
		}
	}
	func notifyMouseDrag(e:NSEvent) {
		if let p = queryCodePathAtMouseEvent(e) {
			delegate?.selectionWillChange()
			end		=	p
			delegate?.selectionDidChange()
		}
	}
	func notifyMouseUp(e:NSEvent) {
		
		if let p = queryCodePathAtMouseEvent(e) {
			delegate?.selectionWillChange()
			end		=	p
			delegate?.selectionDidChange()
		}
	}
	func containsLine(line index:Int) -> Bool {
		return	range.startPoint.line <= index && index <= range.endPoint.line
	}
	func containsPoint(point:CodePoint) -> Bool {
		return	range.startPoint <= point && point <= range.endPoint
	}
//	///	Returns column (UTF-8 code unit) of selected range if the line is selected.
//	func columnRangeInLineAtIndex(line index:Int) -> Range<Int>? {
//		if let r = range {
//			if containsLine(line: index) {
//				let	ln	=	owner!.storage.lines[index]
//				let	startP	=	r.startPoint.line == index ? r.startPoint.column : 0
//				let	endP	=	r.endPoint.line == index ? r.endPoint.column : ln.data.count
//				return	startP..<endP
//			}
//			
//		}
//		return	nil
//	}
	
	////
	
	private func queryCodePathAtMouseEvent(e:NSEvent) -> CodePoint? {
		let	p	=	e.locationInWindow
		return	delegate?.selectionQueryCodePointAtGraphicsPointInWindow(p)
//		let	p1	=	owner!.renderingView.convertPoint(p, fromView: nil)
//		let	p2	=	owner!.renderingView.queryCodePointAtGraphicsPoint(p1)
//		return	p2
	}
}

protocol CodeSelectionManagerDelegate: class {
	///	`point`: is a point in window space.
	func selectionQueryCodePointAtGraphicsPointInWindow(point:CGPoint) -> CodePoint?
	func selectionWillChange()
	func selectionDidChange()
}












extension CodeSelectionManager {
	///	A character means Swift `Character` type (Unicode grapheme cluster).
	///	This resets selection length to 0.
	func moveByCharacter(delta:Int) {
		
	}
	
	///	A word means text split by subword rules (capitalisation, abbreviation, underscore...).
	///	This resets selection length to 0.
	func moveBySubword(delta:Int) {
		
	}
	
	///	A word means text split by puncturators.
	///	This resets selection length to 0.
	func moveByWord(delta:Int) {
		
	}
	
	///	This resets selection length to 0.
	func moveToStartOfLine() {
		
	}
	
	///	This resets selection length to 0.
	func moveToEndOfLine() {
		
	}
	
	///	This resets selection length to 0.
	func moveToPoint(point:CodePoint) {
		
	}
	
}




















