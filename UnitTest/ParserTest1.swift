//
//  ParserTest1.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

func parserTest1() {
	
	run {
		let	s	=	CodeStorage()
		s.appendContentOfString("/A/B")
		var	g	=	UTF8CodeUnitGenerator(s)
		
		var	det	=	CSingleLineCommentToken()
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Fail)
	}
	
	run {
		let	s	=	CodeStorage()
		s.appendContentOfString("/**/")
		var	g	=	UTF8CodeUnitGenerator(s)
		
		var	det	=	CMultilineBlockCommentTokeniser()
		
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Pass)
	}
	
	run {
		let	s	=	CodeStorage()
		s.appendContentOfString("/*a*/")
		var	g	=	UTF8CodeUnitGenerator(s)
		
		var	det	=	CMultilineBlockCommentTokeniser()
		
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Progressing)
		
		det.step(g.next()!, g)
		assert(det.state == State.Pass)
	}
	
	run {
		let	s	=	CodeStorage()
		s.appendContentOfString("//A\n/*B*/")
		var	g	=	UTF8CodeUnitGenerator(s)
		var	p	=	Tokeniser(g)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		assert(p.tokens.count == 1)
		
		p.step(&g)
		assert(p.available == true)
		assert(p.tokens.count == 2)
		
		p.step(&g)
		assert(p.available == false)
		
		assert(decodeFromUTF8Data(p.tokens[0]) == "//A\n")
		assert(decodeFromUTF8Data(p.tokens[1]) == "/*B*/")
	}
	
	run {
		let	s	=	CodeStorage()
		s.appendContentOfString("/**/A")
		var	g	=	UTF8CodeUnitGenerator(s)
		var	p	=	Tokeniser(g)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		assert(p.tokens.count == 0)
		println(p.tokens)
		
		p.step(&g)
		assert(p.available == true)
		assert(p.tokens.count == 0)
		println(p.tokens)
		
		p.step(&g)
		assert(p.available == true)
		assert(p.tokens.count == 0)
		println(p.tokens)
		
		p.step(&g)
		assert(p.available == true)
		assert(p.tokens.count == 1)
		assert(decodeFromUTF8Data(p.tokens[0]) == "/**/")
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
		
		p.step(&g)
		assert(p.available == true)
	}

}















