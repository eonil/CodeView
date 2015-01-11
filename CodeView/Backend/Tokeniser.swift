//
//  Tokeniser.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

typealias	U8		=	UTF8.CodeUnit







struct Tokeniser {
	var	tokens	=	[] as [ContiguousArray<U8>]
	
	init(_ data:UTF8CodeUnitGenerator) {
		chk		=	data
	}
	
	var available:Bool {
		get {
			return	f
		}
	}
	
	///	Call this while `Progressing`. (until you get `Pass` or `Fail`)
	mutating func step(inout g:UTF8CodeUnitGenerator) {
		precondition(f == true)
		
		//
		//	Current best approach. Dynamic dispatch slows down.
		//
		
		switch nn {
		case 0:
			substep(&t1, &g)
			
		case 1:
			substep(&t2, &g)
			
		default:
			//	No proper tokeniser for current byte position.
			//	Just skip it.
			if let _ = g.next() {
			} else {
				f	=	false
			}
			nn	=	0
			ss	=	StateSlot()
			chk	=	g
			return
		}
		
		////
		
		switch ss.value {
		case .Progressing:
			break
			
		case .Pass:
			nn	=	0
			chk	=	g
			ss	=	StateSlot()
//			println("pass: chk = g")
			
		case .Fail:
			if nn < 2 {
				nn++
				g	=	chk				///	Rollback cursor.
				ss	=	StateSlot()		///	Reset state.
//				println("fail: g = chk")
			}
		}
	}
	
	mutating func substep<T:TokenType>(inout t:T, inout _ g:UTF8CodeUnitGenerator) {
		if let u = g.next() {
//			println(Character(UnicodeScalar(u)))
			t.step(u, g)
			switch t.state {
			case .Progressing:
				buf.append(u)
				break
				
			case .Pass:
				buf.append(u)
				tokens.append(buf)
				
				t.reset()
				buf.removeAll(keepCapacity: true)
				ss.setPass()
				
			case .Fail:
				t.reset()
				buf.removeAll(keepCapacity: true)
				ss.setFail()
			}
		} else {
			f	=	false
		}
	}
	
	////
	
	private var	chk	:	UTF8CodeUnitGenerator
	private var	f	=	true
	
	private var	buf	=	ContiguousArray<U8>()
	
	private var	t1	=	CSingleLineCommentToken()
	private var	t2	=	CMultilineBlockCommentTokeniser()

	
	private var	nn	=	0
	private var	ss	=	StateSlot()
}




































protocol TokenType {
	var state:State { get }
	///	`state` will be `Progressing` until pass/fail to be determined.
	///	Once determined, you shouldn't call further `step` call.

	mutating func reset()
	
	///	u:	for current.
	///	g:	for preview.
	mutating func step(u:U8, var _ g:UTF8CodeUnitGenerator)
}
enum State {
	case Progressing
	case Fail
	case Pass
}


func preview(var g:UTF8CodeUnitGenerator) -> (u:U8?, continuation:UTF8CodeUnitGenerator) {
	let	u	=	g.next()
	return	(u,g)
}






let	SLASH	=	U8(UnicodeScalar("/").value)
let	STAR	=	U8(UnicodeScalar("*").value)
let	NL		=	U8(UnicodeScalar("\n").value)






struct CMultilineBlockCommentTokeniser: TokenType {
	var state:State {
		get {
			return	s.value
		}
	}
	mutating func reset() {
		self	=	CMultilineBlockCommentTokeniser()
	}
	mutating func step(u: U8, _ g: UTF8CodeUnitGenerator) {
		precondition(state != State.Pass)
		precondition(state != State.Fail)
		
		switch p {
		case .Start:
			switch c {
			case 0:	s.setFailIf(u != SLASH)
			case 1:
				s.setFailIf(u != STAR)
				p	=	Phase.Content
				c	=	0
			default:	break
			}
			c++
			
		case .Content:
			if u == STAR {
				let	(u1, _)	=	preview(g)
				if u1 == SLASH {
					p	=	Phase.End
					c	=	0
					step(u, g)
				}
			}
			
		case .End:
			switch c {
			case 0:	s.setFailIf(u != STAR)
			case 1:
				s.setFailIf(u != SLASH)
				s.setPass()
			default:	break
			}
			c++
		}
	}
	
	////
	
	private enum Phase {
		case Start
		case Content
		case End
	}
	
	private var	s	=	StateSlot()
	private var	p	=	Phase.Start
	private var	c	=	0
}



//struct SequenceTokeniser: TokenType {
//	let	sample:[U8]
//	
//	init(sample:ContiguousArray<U8>) {
//		self.init(sample: [U8](sample))
//	}
//	init(sample:[U8]) {
//		self.sample	=	sample
//	}
//	var state:State {
//		get {
//			return	s
//		}
//	}
//	mutating func step(u: U8, _ g: UTF8CodeUnitGenerator) {
//		assert(s != State.Fail)
//		assert(s != State.Pass)
//		precondition(p < sample.count)
//		
//		if sample[p] != u {
//			s	=	State.Fail
//		}
//		
//		p++
//	}
//	
//	////
//	
//	private var	s	=	State.Progressing
//	private var	p	=	0
//}



struct CSingleLineCommentToken: TokenType {
	var state:State {
		get {
			return	s
		}
	}
	mutating func reset() {
		self	=	CSingleLineCommentToken()
	}
	mutating func step(u:U8, var _ g:UTF8CodeUnitGenerator) {
		assert(s != State.Fail)
		assert(s != State.Pass)

		switch p {
		case 0:
			errorIf(u != SLASH)
		case 1:
			errorIf(u != SLASH)
		default:
			switch u {
			case NL:
				done()
				
			default:
				progressing()
			}
		}
		
		p++
	}
	
	
	////
	
	private var	p		=	0
	private var	s		=	State.Progressing
	
	private mutating func error() {
		assert(s != State.Fail)
		s	=	State.Fail
	}
	private mutating func progressing() {
		assert(s != State.Fail)
		assert(s != State.Pass)
		s	=	State.Progressing
	}
	private mutating func done() {
		assert(s != State.Fail)
		assert(s != State.Pass)
		s	=	State.Pass
	}
}
extension CSingleLineCommentToken {
	private mutating func errorIf(cond:Bool) {
		if cond {
			error()
		}
	}
}
















struct StateSlot {
	var value:State {
		get {
			return	s
		}
	}
	var isProgressing:Bool {
		get {
			return	s == State.Progressing
		}
	}
	var isPass:Bool {
		get {
			return	s == State.Pass
		}
	}
	var isFail:Bool {
		get {
			return	s == State.Fail
		}
	}
	mutating func setPass() {
		precondition(s != State.Pass)
		precondition(s != State.Fail)
		s	=	State.Pass
	}
	mutating func setFail() {
		precondition(s != State.Pass)
		precondition(s != State.Fail)
		s	=	State.Fail
	}
	private var	s	=	State.Progressing
}
extension StateSlot {
	mutating func setFailIf(condition:Bool) {
		if condition {
			setFail()
		}
	}
}













//struct Token {
//	let	dets	=	[] as [Chardet]
//	func push(u:UTF8.CodeUnit) {
//		
//	}
//	
//	static func blockComment() -> Token {
//		return	Token(dets: [
//			
//			])
//	}
//}
//














//
//func any(us:ContiguousArray<U8>) -> Chardet {
//	return	{ u1 in
//		for u in us {
//			if u == u1 {
//				return	true
//			}
//		}
//		return	false
//	}
//}
//func eq(u:U8) -> Chardet {
//	return	{ u1 in
//		return	u == u1
//	}
//}
//func not(det:Chardet) -> Chardet {
//	return	{ u in
//		return	!det(u)
//	}
//}
//
//
//
//typealias	Chardet	=	(UTF8.CodeUnit) -> Bool
//
//protocol ChardetType {
//	func determinate(u:UTF8.CodeUnit) -> Bool {
//	
//	}
//}
//struct CharDet {
//	func
//}


