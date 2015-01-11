//
//  CodeStorage+Utility.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

extension CodeStorage {
	func appendContentOfString(s:String) {
		let	d	=	encodeToUTF8Data(s)
		iterateAllLines(d) { bytes in
			var	ln			=	CodeLine()
			ln.data			=	ContiguousArray(bytes)
			self.lines.append(ln)
		}
	}
	func appendContentOfFile(path:String) {
		iterateAllLinesFromPath(path) { bytes in
			var	ln			=	CodeLine()
			ln.data			=	bytes
			self.lines.append(ln)
		}
	}
}






private func iterateAllLines<S:SequenceType where S.Generator.Element == UInt8>(data:S, function:(Slice<UInt8>)->()) {
	let	NL	=	UInt8(UnicodeScalar("\n").value)
	var	bs1	=	ContiguousArray<UInt8>()
	bs1.reserveCapacity(LINE_BUFFER_SIZE_IN_BYTE)
	for b in data {
		bs1.append(b)
		if b == NL {
			function(bs1[bs1.startIndex..<bs1.endIndex])
			bs1.removeAll(keepCapacity: true)
		}
	}
	
	function(bs1[bs1.startIndex..<bs1.endIndex])
}

private func iterateAllLinesFromData(data:NSData, function:(ContiguousArray<UInt8>)->()) {
	let	NL	=	UInt8(UnicodeScalar("\n").value)
	
	let	d	=	data
	let	len	=	d.length
	let	bs	=	d.bytes
	var	p1	=	UnsafePointer<UInt8>(bs)
	var	bs1	=	ContiguousArray<UInt8>()
	bs1.reserveCapacity(LINE_BUFFER_SIZE_IN_BYTE)
	for i in 0..<len {
		let	b	=	p1.memory
		bs1.append(b)
		if b == NL {
			function(bs1)
			bs1.removeAll(keepCapacity: true)
		}
		p1++
	}
	
	function(bs1)
}

private func iterateAllLinesFromPath(path:String, function:(ContiguousArray<UInt8>)->()) {
	let	d	=	NSData(contentsOfFile: path)!
	iterateAllLinesFromData(d, function)
}

private let	LINE_BUFFER_SIZE_IN_BYTE	=	1024