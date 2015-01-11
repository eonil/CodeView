//
//  CodeLineConnectionTest.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

func codeLineGraphTest1() {
	
	run {
		let	s	=	CodeStorage()
		s.lines.append(CodeLine())
		assert(s.lines.first! === s.lines.last!)
		assert(s.lines.first!.prior === nil)
		assert(s.lines.first!.next === nil)
	}
	
	run {
		let	s	=	CodeStorage()
		s.lines.append(CodeLine())
		assert(s.lines.first! === s.lines.last!)
		assert(s.lines.first!.prior === nil)
		assert(s.lines.first!.next === nil)
		
		let	ln1	=	CodeLine()
		s.lines.append(ln1)
		assert(s.lines.first! !== s.lines.last!)
		assert(s.lines.first!.prior === nil)
		assert(s.lines.first!.next! === s.lines.last!)
		assert(s.lines.last!.prior! === s.lines.first!)
		assert(s.lines.last!.next === nil)
		
	}
	
	run {
		let	s	=	CodeStorage()
		s.lines.append(CodeLine())
		s.lines.append(CodeLine())
		s.lines.append(CodeLine())
		
		assert(s.lines[0].prior === nil)
		assert(s.lines[1].prior! === s.lines[0])
		assert(s.lines[2].prior! === s.lines[1])
		
		assert(s.lines[0].next! === s.lines[1])
		assert(s.lines[1].next! === s.lines[2])
		assert(s.lines[2].next === nil)
		
	}
	
	run {
		let	s	=	CodeStorage()
		for i in 0..<1024 {
			let	l	=	CodeLine()
			s.lines.append(l)
		}
		
		assert(s.lines.first!.prior === nil)
		assert(s.lines.last!.next === nil)
		for i in 0..<(1024-1) {
			let	l0	=	s.lines[i]
			let	l1	=	s.lines[i+1]
			assert(l0.next! === l1)
			assert(l1.prior! === l0)
		}
	}
	
	run {
		func makeLine() -> CodeLine {
			let	l		=	CodeLine()
			l.string	=	"A\n"
			return	l
		}
		let	s	=	CodeStorage()
		s.lines.append(makeLine())
		s.lines.append(makeLine())
		s.lines.append(makeLine())
		
//		let	c	=	Cursor(storage: s, point: CodePoint(line: 0, column: 0))
//		assert(c.currentUnit == UTF8.CodeUnit(UnicodeScalar("A").value))
//		c.step()
//		assert(c.currentUnit == UTF8.CodeUnit(UnicodeScalar("\n").value))
//		c.step()
//		assert(c.currentUnit == UTF8.CodeUnit(UnicodeScalar("A").value))
//		c.step()
//		assert(c.currentUnit == UTF8.CodeUnit(UnicodeScalar("\n").value))
//		c.step()
//		assert(c.currentUnit == UTF8.CodeUnit(UnicodeScalar("A").value))
//		c.step()
//		assert(c.currentUnit == UTF8.CodeUnit(UnicodeScalar("\n").value))
//		assert(c.available == true)
//		c.step()
//		assert(c.available == false)
	}
	
	
	
	
	

}