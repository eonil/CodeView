//
//  CaretManager.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

///	This starts blinking automatically.
///	No need to call `resetBlinking` manually.
final class CaretManager {
	weak var delegate:CaretManagerDelegate?	=	nil
	
	init() {
		resetBlinking()
	}
	var blinkInterval:NSTimeInterval {
		get {
			//	Seems there's no API for this.
			//	Just use a constant value.
			//	https://bugzilla.mozilla.org/show_bug.cgi?id=518140
			//	http://hg.mozilla.org/mozilla-central/rev/80da5326b541
			//
//			return	0.567
			return	0.5
		}
	}
	var hidden:Bool {
		get {
			return	_hidden
		}
	}
	
	///	Resets blinking. Caret will be initially visible.
	func resetBlinking() {
		assertMainThread()
		
		_hidden		=	false
		_halted		=	false
		_context	=	Context()
		
		reserveStepping()
	}
	func haltBlinking() {
		assertMainThread()
		
		_hidden	=	false
		_halted	=	true
	}
	
	////
	
	private var	_halted	=	false
	private var	_hidden	:	Bool		=	false {
		willSet {
			self.delegate?.caretDisplayStateWillChange()
		}
		didSet {
			self.delegate?.caretDisplayStateDidChange()
		}
	}
	private var	_context	=	Context()
	
	private func reserveStepping() {
		assertMainThread()
		
		let	capturedContext	=	_context
		dispatchAfterOnMainSerialQueue(blinkInterval) { [weak self] in
			assertMainThread()
			if let me = self {
				if capturedContext !== me._context {
					//	Context disposed. This preservation has been invalidated.
					return
				}
				
				if me._halted == false {
					me._hidden	=	!me._hidden
					me.reserveStepping()
				}
			}
		}
	}
}

protocol CaretManagerDelegate: class {
	func caretDisplayStateWillChange()
	func caretDisplayStateDidChange()
}

private class Context {
}

