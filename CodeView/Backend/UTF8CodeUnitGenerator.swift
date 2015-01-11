//
//  UTF8CodeUnitGenerator.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation







struct UTF8CodeUnitGenerator: GeneratorType {
	init(_ s:CodeStorage) {
		lg	=	s.lines.generate()
		cg	=	lg.next()!.generateColumns()
	}
	
	var	point:CodePoint {
		get {
			return	CodePoint(line: lg.count, column: cg.count)
		}
	}
	mutating func next() -> UTF8.CodeUnit? {		
		if let u = cg.next() {
			return	u
		} else {
			if let ln = lg.next() {
				cg	=	ln.generateColumns()
				return	next()
			} else {
				return	nil
			}
		}
	}
	
	private var	lg:CodeStorageLineListGenerator
	private var	cg:CodeLineColumnGenerator
}

