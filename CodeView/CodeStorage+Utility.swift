//
//  CodeStorage+Utility.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

extension CodeStorage {
	func appendContentOfFile(path:String) {
		iterateAllLines(path) { bytes in
			var	ln			=	CodeLine()
			ln.data			=	bytes
			ln.annotation	=	RustCodeLineAnnotation()
			self.lines.append(ln)
		}
	}
}

private func iterateAllLines(path:String, function:(ContiguousArray<UInt8>)->()) {
	let	NL	=	UInt8(UnicodeScalar("\n").value)
	
	let	d	=	NSData(contentsOfFile: path)!
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
}

private let	LINE_BUFFER_SIZE_IN_BYTE	=	1024