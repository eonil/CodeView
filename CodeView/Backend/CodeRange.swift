//
//  CodeRange.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation



///	Valid only while the storage has not been mutated.
//struct CodeSlice {
//	let	storage:CodeStorage
//	let	range:CodeRange
//}
//struct CodePoint {
//	unowned var	line:CodeLine						///	Reference to a line. Invalidated after the line deallocated.
//	var			index:Int							///	Number of `UTF8.CodeUnit`(byte) from start of the line. 0 based.
//}

struct CodeRange {
	var	startPoint:CodePoint
	var	endPoint:CodePoint
}
extension CodeRange: Printable {
	var description:String {
		get {
			return	"\(startPoint)..<\(endPoint)"
		}
	}
}
extension CodeRange: Equatable {
	var isEmpty:Bool {
		get {
			return	startPoint == endPoint
		}
	}
	
	///	If `endPoint.line` contains any character at the line, then the line will be included.
	var lineRange:Range<Int> {
		get {
			let	e	=	endPoint.column == 0 ? endPoint.line : endPoint.line+1
			return	startPoint.line..<e
		}
	}
	func generateLineSubrangesWithStorage(storage:CodeStorage) -> GeneratorOf<CodeRange> {
		precondition(startPoint.line < storage.lines.count)
		precondition(endPoint.line < storage.lines.count)
		
		///	Take care that the `endPoint.line` is INCLUSIVE.
		let	lineidxR	=	startPoint.line...endPoint.line
		var	lineidxG	=	lineidxR.generate()
		
		//	Copies data to be integrate when the original has been modified.
		let	startCopy	=	startPoint
		let	endCopy		=	endPoint
		let	g			=	GeneratorOf { ()->CodeRange? in
			if let i = lineidxG.next() {
				let	ln		=	storage.lines[i]
				let	startP	=	startCopy.line == i ? startCopy.column : 0
				let	endP	=	endCopy.line == i ? endCopy.column : ln.data.count
				
				let	startP1	=	CodePoint(line: i, column: startP)
				let	endP1	=	CodePoint(line: i, column: endP)
				let	r		=	CodeRange(startPoint: startP1, endPoint: endP1)
				
				return	r
			}
			return	nil
		}
		
		return	g
	}
	
	///	TODO:	Optimise to use generator pattern to avoid issues with massive selection.
	@availability(*,deprecated=0)
	func lineSubrangesWithStorage(storage:CodeStorage) -> [CodeRange] {
		precondition(startPoint.line < storage.lines.count)
		precondition(endPoint.line < storage.lines.count)
		
		let	cap	=	endPoint.line - startPoint.line + 1
		var	rs	=	[] as [CodeRange]
		rs.reserveCapacity(cap)
		
		///	Take care that the `endPoint.line` is INCLUSIVE.
		for lineidx in startPoint.line...endPoint.line {
			let	ln		=	storage.lines[lineidx]
			let	startP	=	startPoint.line == lineidx ? startPoint.column : 0
			let	endP	=	endPoint.line == lineidx ? endPoint.column : ln.data.count
			
			let	startP1	=	CodePoint(line: lineidx, column: startP)
			let	endP1	=	CodePoint(line: lineidx, column: endP)
			let	r		=	CodeRange(startPoint: startP1, endPoint: endP1)
			rs.append(r)
		}
		return	rs
	}
	
	///	This can return zero-length range if the ranges are consecutive.
	///	Returns `nil` if there's no intersection.
	static func intersection(left:CodeRange, right:CodeRange) -> CodeRange? {
		let	s	=	max(left.startPoint, right.startPoint)
		let	e	=	min(left.endPoint, right.endPoint)
		return	s <= e ? s..<e : nil
	}
}
func == (left:CodeRange, right:CodeRange) -> Bool {
	return	left.startPoint == right.startPoint && left.endPoint == right.endPoint
}












struct CodePoint: Comparable {
	var	line:Int							///	Index to a line object. 0 based.
	var	column:Int							///	Number of `UTF8.CodeUnit`(byte) from start of the line. 0 based.
}
extension CodePoint: Printable {
	var	description:String {
		get {
			return	"\(line):\(column)"
		}
	}
}

func == (left:CodePoint, right:CodePoint) -> Bool {
	return	left.line == right.line && left.column == right.column
}
func < (left:CodePoint, right:CodePoint) -> Bool {
	return	left.line < right.line || (left.line == right.line && left.column < right.column)
}
func > (left:CodePoint, right:CodePoint) -> Bool {
	return	left.line > right.line || (left.line == right.line && left.column > right.column)
}
func <= (left:CodePoint, right:CodePoint) -> Bool {
	return	left.line < right.line || (left.line == right.line && left.column <= right.column)
}
func >= (left:CodePoint, right:CodePoint) -> Bool {
	return	left.line > right.line || (left.line == right.line && left.column >= right.column)
}
func ..<(left:CodePoint, right:CodePoint) -> CodeRange {
	return	CodeRange(startPoint: left, endPoint: right)
}

func min(left:CodePoint, right:CodePoint) -> CodePoint {
	return	left < right ? left : right
}
func max(left:CodePoint, right:CodePoint) -> CodePoint {
	return	left > right ? left : right
}









