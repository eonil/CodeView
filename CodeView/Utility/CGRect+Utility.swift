//
//  CGRect+Utility.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

extension CGRect {
	func rectByAddingWith(number:CGFloat) -> CGRect {
		return	CGRect(x: origin.x, y: origin.y, width: size.width+number, height: size.height)
	}
}