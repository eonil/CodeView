//
//  CodeStorage.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation


///	Stores text data in UTF-8 encoded form.
///
///	Limits
///	------
///	Designed for text data smaller than 10MiB when encoded into UTF-8.
///	This clas consumes huge memory, and optimised for response speed.
///	About 10Mib text file consumes more than 500Mib memory for internal
///	data structure. There's no problem to open files larger than 10MiB,
///	but you will be suffered by lack of available memory, and OS will 
///	fallback to disk swapping.
///
///	`CodeLine` also has its own limitations.
///
class CodeStorage: EditLockable {
	override init() {
		super.init()
		self._lines	=	CodeStorageLineList(owner: self)
	}
	
	var	lines:CodeStorageLineList {
		get {
			return	_lines!
		}
	}
	
//	func addObserver(o:CodeStorageObserver) {
//		_obss.append(o)
//	}
//	func removeObserver(o:CodeStorageObserver) {
//		_obss	=	_obss.filter { obs in
//			return	obs !== o
//		}
//	}
	
	private let	_lines	:	CodeStorageLineList?
//	private var	_obss	=	[] as [CodeStorageObserver]
}

extension CodeStorage {
	func countTotalLength() -> Int {
		var	len	=	0
		for ln in lines {
			len	+=	ln.data.count
		}
		return	len
	}
}


//protocol CodeStorageObserver: class {
//	func codeStorageDidChange()
//}





















class CodeStorageLineList: SequenceType {
	private init(owner:CodeStorage) {
		self.owner	=	owner
	}
	var storage:CodeStorage {
		get {
			return	owner
		}
	}
	
	var count:Int {
		get {
			return	lines.count
		}
	}
	subscript(index:Int) -> CodeLine {
		get {
			return	lines[index]
		}
	}
	subscript(range:Range<Int>) -> Slice<CodeLine> {
		get {
			return	lines[range]
		}
	}
	func generate() -> Array<CodeLine>.Generator {
		return	lines.generate()
	}
	
	func insert(line:CodeLine, index:Int) {
		precondition(owner.isEditable)
		precondition(line.owner == nil)
		precondition(line.prior == nil)
		precondition(line.next == nil)
		
		lines.insert(line, atIndex: index)
		line._owner	=	owner
		
		let	p:CodeLine?	=	index == 0 ? nil : lines[index-1]
		let	n:CodeLine?	=	index == count-1 ? nil : lines[index+1]
		
		//	Doesn't work. Seems to be a compiler bug.
		assert(p?.next === n?.prior)
		p?._next	=	line
		n?._prior	=	line
//		if let p1 = p {
//			p1._next	=	line
//		}
//		if let n1 = n {
//			n1._prior	=	line
//		}
		
		line._prior	=	p
		line._next	=	n
	}
	func removeAt(index:Int) {
		precondition(owner.isEditable)
		func removeConnectivityOfLine(line:CodeLine) {
			let	p	=	line.prior
			let	n	=	line.next
			
			p?._next	=	n
			n?._prior	=	p
			line._owner	=	nil
			line._prior	=	nil
			line._next	=	nil
		}
		
		let	ln	=	lines[index]
		removeConnectivityOfLine(ln)
		lines.removeAtIndex(index)
	}
	func removeRange(range:Range<Int>) {
		precondition(owner.isEditable)
		for i in reverse(range) {
			removeAt(i)
		}
	}
	
	private unowned let	owner	:	CodeStorage
	private var			lines	=	Array<CodeLine>()
	
}

extension CodeStorageLineList {
	var first:CodeLine? {
		get {
			return	lines.first
		}
	}
	var last:CodeLine? {
		get {
			return	lines.last
		}
	}
	func append(line:CodeLine) {
		self.insert(line, index: count)
	}
	func removeLast() {
		self.removeAt(count-1)
	}
}












//struct CodeBlock {
//	var	content		=	ContiguousArray<UTF8.CodeUnit>()
//	
//	var string:String {
//		get {
//			var	e	=	UTF8()
//			var	g	=	content.generate()
//			var	s	=	""
//			var	c	=	true
//			while c {
//				let	r	=	e.decode(&g)
//				switch r {
//				case .Error:
//					fatalError("Undecodable UTF-8 data.")
//				case .EmptyInput:
//					c	=	false
//					
//				case .Result(let scalar):
//					s.append(scalar)
//				}
//			}
//			return	s
//		}
//		set(v) {
//			let	a	=	v.nulTerminatedUTF8
//			content	=	a
//		}
//	}
//}

























///	Line contains ending newline character if one exists.
///	`data` will not contain ending NULL. Do not pass the data to C functions as is.
///
///	If this line is owned by a storage, and the storage editing is locked, 
///	then editing of this line is also will be locked.
///	Unowned line object cannot be locked.
///	
///	Limits
///	------
///	Optimised for short line string.
///	Overall design of this framework just presumes a line to be shorter 
///	than 1024 bytes in UTF-8 encoding. Longer lines are simply not well 
///	considered.
class CodeLine {
	init() {
	}
	var	data:ContiguousArray<UTF8.CodeUnit> {
		get {
			return	_content
		}
		set(v) {
			precondition(owner == nil || owner!.isEditable)
			_content	=	v
		}
	}
	var	annotation:CodeLineAnnotation? {
		get {
			return	_annotation
		}
		set(v) {
			precondition(owner == nil || owner!.isEditable)
			_annotation	=	v
		}
	}
	
	var	owner:CodeStorage? {
		get {
			return	_owner
		}
	}
	var	prior:CodeLine? {
		get {
			return	_prior
		}
	}
	var	next:CodeLine? {
		get {
			return	_next
		}
	}
	
	////

	private weak var	_owner:CodeStorage?
	private weak var	_prior:CodeLine?
	private weak var	_next:CodeLine?
	
	private var	_content	=	ContiguousArray<UTF8.CodeUnit>()
	private var	_annotation	=	nil as CodeLineAnnotation?
}

extension CodeLine {
	///	Performs full conversion, so expected to be slow if the `data` is very long.
	var string:String {
		get {
			return	decodeFromUTF8Data(data)
		}
		set(v) {
			data	=	encodeToUTF8Data(v)
		}
	}
}

///	Designed to be subclasses.
///	Subclass and add your own data.
class CodeLineAnnotation {
}
















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




struct CodePoint {
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




















