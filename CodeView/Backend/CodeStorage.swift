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




















struct CodeStorageLineListGenerator: GeneratorType {
	init(_ first:CodeLine?) {
		self.current	=	first
	}
	var count:Int {
		get {
			return	counter
		}
	}
	mutating func next() -> CodeLine? {
		counter++
		
		let	c	=	current
		current	=	current?.next
		return	c
	}
	private var	current	=	nil as CodeLine?
	private var	counter	=	0
}
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
//	func generate() -> Array<CodeLine>.Generator {
//		return	lines.generate()
//	}
	func generate() -> CodeStorageLineListGenerator {
		return	CodeStorageLineListGenerator(first)
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
		p?.setNext(line)
		n?.setPrior(line)

		line.setPrior(p)
		line.setNext(n)
	}
	func removeAt(index:Int) {
		precondition(owner.isEditable)
		func removeConnectivityOfLine(line:CodeLine) {
			let	p	=	line.prior
			let	n	=	line.next
			
			p?.setNext(n)
			p?.setPrior(p)
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

extension CodeStorageLineList {
	func dataCountOfLineAtIndex(index:Int) -> Int {
		let	ln	=	Unmanaged<CodeLine>.passUnretained(lines[index])
		return	ln.takeUnretainedValue().queryDataLength()
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























///	MARK:
///	MARK:	CodeLine

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
			_content			=	v
			_cache_content_len	=	_content.count
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
			return	_prior?.takeUnretainedValue()
		}
	}
	var	next:CodeLine? {
		get {
			return	_next?.takeUnretainedValue()
		}
	}
	
	func queryDataLength() -> Int {
		return	_cache_content_len
	}
	
	////

	private weak var	_owner:CodeStorage?
//	private weak var	_prior:CodeLine?
//	private weak var	_next:CodeLine?
	
	private var	_prior:Unmanaged<CodeLine>?
	private var _next:Unmanaged<CodeLine>?
	
	private var	_content	=	ContiguousArray<UTF8.CodeUnit>()
	private var	_annotation	=	nil as CodeLineAnnotation?
	
	private var	_cache_content_len:Int	=	0
	
	private func setPrior(line:CodeLine?) {
		_prior	=	line == nil ? nil : Unmanaged<CodeLine>.passUnretained(line!)
	}
	private func setNext(line:CodeLine?) {
		_next	=	line == nil ? nil : Unmanaged<CodeLine>.passUnretained(line!)
	}
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
	
	func generateColumns() -> CodeLineColumnGenerator {
		return	CodeLineColumnGenerator(_content.generate())
	}
}

///	Designed to be subclasses.
///	Subclass and add your own data.
class CodeLineAnnotation {
}





struct CodeLineColumnGenerator: GeneratorType {
	init(_ g:ContiguousArray<UTF8.CodeUnit>.Generator) {
		self._g	=	g
		self._c	=	0
	}
	var	count:Int {
		get {
			return	_c
		}
	}
	mutating func next() -> UTF8.CodeUnit? {
		_c++
		return	_g.next()
	}
	private var	_g	:	ContiguousArray<UTF8.CodeUnit>.Generator
	private var	_c	:	Int
}

struct CodeLineView {
	private let	ref:Unmanaged<CodeLine>
}























