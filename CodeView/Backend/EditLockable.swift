//
//  EditLockable.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation


class EditLockable {
	var isEditable:Bool {
		get {
			return	_edlockc == 0
		}
	}
	func lockEditing() {
		_edlockc++
	}
	func unlockEditing() {
		precondition(_edlockc > 0)
		_edlockc--
	}
	
	private var	_edlockc	=	0
}
