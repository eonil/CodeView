//
//  main.swift
//  PerfTest
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

func readTestData(f:(ContiguousArray<UInt8>)->()) {
	let	p	=	"/Users/Eonil/Workshop/Incubation/CodeView/PerfTest/test-data-ascii-500kb.rs"
	readAllLines(p, f)
}

func readAllLines(path:String, function:(ContiguousArray<UInt8>)->()) {
	let	NL	=	UInt8(UnicodeScalar("\n").value)
	
	let	d	=	NSData(contentsOfFile: path)!
	let	len	=	d.length
	let	bs	=	d.bytes
	var	p1	=	UnsafePointer<UInt8>(bs)
	var	bs1	=	ContiguousArray<UInt8>()
	bs1.reserveCapacity(1024)
	for i in 0..<len {
		let	b	=	p1.memory
		bs1.append(b)
		if b == NL {
			function(bs1)
			bs1.removeAll(keepCapacity: true)
		}
		p1	=	p1.advancedBy(1)
	}
}

let	s	=	CodeStorage()
var	c	=	0
for i in 0..<20 {
//for i in 0..<1 {
	autoreleasepool {
		readTestData { bytes in
			var	ln			=	CodeLine()
			ln.data			=	bytes
			ln.annotation	=	RustCodeLineAnnotation()
			s.lines.append(ln)
			
			if ln.prior != nil {
				c++
			}
		}
	}
}
println("done loading. lines: \(s.lines.count), total bytes: \(s.countTotalLength()), c: \(c)")
sleep(1)

//let	c1	=	Cursor(storage: s, point: CodePoint(line: 0, column: 0))
//var	vv	=	UTF8.CodeUnit(0)
//while c1.available {
//	c1.step()
//	vv	+=	c1.currentUnit
//}
//println(vv)
//println("done stepping. lines: \(s.lines.count), total bytes: \(s.countTotalLength()), c: \(c)")

//var	vv:UTF8.CodeUnit	=	0
//var	cc	=	0
//for ln in s.lines {
//	for u in ln.data {
//		vv	+=	u
//	}
//	cc++
//}
//println("sum: \(vv)")

var	vv:UTF8.CodeUnit	=	0
var	cc	=	0
var	lg	=	s.lines.generate()
for ln in lg {
	var	ug	=	ln.data.generate()
	for u in ug {
		vv	+=	u
	}
	cc++
}
println("sum: \(vv)")

//var	vv:UTF8.CodeUnit	=	0
//var	cc	=	0
//for i in 0..<s.lines.count {
//	for i in 0..<s.lines[i].data.count {
//		let	u	=	s.lines[i].data[i]
//		vv	+=	u
//	}
//	cc++
//}
//println("sum: \(vv)")

//var	vv:UTF8.CodeUnit	=	0
//var	cur	=	Cursor2(s)
//while cur.available {
//	vv	+=	cur.currentUnit
//}
//println("sum: \(vv)")

//s.lines.removeRange(1..<s.lines.count-1)
//println("done removing. lines: \(s.lines.count), total bytes: \(s.countTotalLength()), c: \(c)")
//println(s.lines[0].string)
//println(s.lines[1].string)






























//let	KB				=	1024
//let	MB				=	KB * 1024
//let	SAMPLE_SIZE		=	10 * MB
//let	CHARS_PER_LINE	=	64
//let	LINE_COUNT		=	SAMPLE_SIZE / CHARS_PER_LINE
//println("LINE_COUNT: \(LINE_COUNT)")
//
//let	SAMPLE_LINE		=	"0123456789012345678901234567890123456789012345678901234567890123" as String		//	64 unicode characters.
//let	SAMPLE_CHARS	=	SAMPLE_LINE.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//
//func generateRamdonBytes() -> ContiguousArray<UInt8> {
//	let	len	=	random() % 1024
//	var	a	=	ContiguousArray<UInt8>()
//	a.reserveCapacity(len)
//	for i in 0..<len {
//		let	v	=	random() % 255
//		a.append(UInt8(v))
//	}
//	return	a
//}
//
//let	s	=	CodeStorage()
//s.lines.reserveCapacity(LINE_COUNT)
//for i in 0..<(LINE_COUNT) {
//	var	ln	=	CodeLine()
//	ln.content			=	generateRamdonBytes()
////	s.insertLineAtIndex(ln, index: s.lineCount/2)
//	s.lines.append(ln)
//	if i % 8192 == 0 {
//		println("i == \(i)")
//	}
//}
//println("done.")
//
////for i in 0..<s.lineCount {
////	let	ln	=	s.lineAtIndex(i)
////	println(ln.content)
////}
