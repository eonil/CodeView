//
//  Assert.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

func assertMainThread() {
	assert(NSThread.currentThread() == NSThread.mainThread())
}