//
//  Cursor.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

///	UTF-8 based cursor.
///	You cannot edit the code-storage while there's any cursor that using it.
class Cursor {
	init(storage:CodeStorage, point:CodePoint) {
		self.state		=	State(storage: storage, point: point)
		
		state.storage.lockEditing()
	}
	deinit {
		state.storage.unlockEditing()
	}
	var available:Bool {
		get {
			return	state.available
		}
	}
	var	currentUnit:UTF8.CodeUnit {
		get {
			let	p	=	state.point
			let	ln	=	state.currentLine()
			let	idx	=	p.column
			assert(idx != ln.data.count)
			
			precondition(idx < ln.data.count)
			let	u	=	ln.data[p.column]
			return	u
		}
	}
	
	func step() {
		state.step()
	}
	
	////
	
	private var	state:State
}

extension Cursor {
//	var	currentCharacter:Character {
//		get {
//		}
//	}
}


extension Cursor {
	struct State {
		init(storage:CodeStorage, point:CodePoint) {
			assert(point.line < storage.lines.count)
			assert(point.column < storage.lines[point.line].data.count)
			
			self.storage	=	storage
			self.point		=	point
		}
		var	available:Bool {
			get {
				return	point.line < storage.lines.count && point.column < currentLine().data.count
			}
		}
		
		var	pastSliceOfCurrentLine:Slice<UTF8.CodeUnit> {
			get {
				let	ln	=	currentLine()
				return	ln.data[ln.data.startIndex..<point.column]
			}
		}
		var	futureSliceOfCurrentLine:Slice<UTF8.CodeUnit> {
			get {
				let	ln	=	currentLine()
				return	ln.data[point.column..<ln.data.endIndex]
			}
		}
		
		///	Steps a `UTF8.CodeUnit` (byte).
		///	If you need larger units like Unicode-scalar or grapheme cluster, 
		///	you need to do it yourself.
		mutating func step() {
			precondition(available)
			
			let	ln	=	currentLine()
			point.column++
			if point.column == ln.data.endIndex {
				if let n = ln.next {
					point.line		+=	1
					point.column	=	0
				} else {
					//	Becomes *unavailable* state.
				}
			}
		}
		
		private var storage:CodeStorage
		private var	point:CodePoint
		
		private func currentLine() -> CodeLine {
			return	storage.lines[point.line]
		}
	}
}
extension Cursor {
}





