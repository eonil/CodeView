////
////  Cursor2.swift
////  CodeView
////
////  Created by Hoon H. on 2015/01/10.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Foundation
//
//class Cursor2 {
//	init(_ s:CodeStorage) {
//		assert(s.lines.count > 0)
//		
//		self._storage	=	s
//		
//		_storage.lines.generate()
//		_lc		=	_storage.lines.count
//		_cc		=	_storage.lines[_lidx].data.count
//	}
//	var available:Bool {
//		get {
//			return	_lidx < _lc && _cidx < _cc
//		}
//	}
//	var currentUnit:UTF8.CodeUnit {
//		get {
//			return	_storage.lines[_lidx].data[_cidx]
//		}
//	}
//	func step() {
//		_cidx++
//		if _cidx == _cc {
//			_lidx++
//			_cidx	=	0
//		}
//	}
//	
//	let	_storage:CodeStorage
//	
//	var	_lg		=
//	let	_lc		=	0
//	var	_lidx	=	0
//	var	_cc		=	0
//	var	_cidx	=	0
//	
////	var	_curln	:	CodeLine
////	var	_curdat	:	[UTF8.CodeUnit]
//}