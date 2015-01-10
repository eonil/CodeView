//
//  Range+Utility.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation


///	This can return zero-length range if the ranges are consecutive.
///	Returns `nil` if there's no intersection.
func intersection<T:RandomAccessIndexType>(left:Range<T>, right:Range<T>) -> Range<T>? {
	let	s	=	max(left.startIndex, right.startIndex)
	let	e	=	min(left.endIndex, right.endIndex)
	return	s <= e ? s..<e : nil
}