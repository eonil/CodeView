//
//  StringEncodingUtility.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

func decodeFromUTF8Data(data:ContiguousArray<UTF8.CodeUnit>) -> String {
	var	e	=	UTF8()
	var	g	=	data.generate()
	var	s	=	""
	var	c	=	true
	while c {
		let	r	=	e.decode(&g)
		switch r {
		case .Error:
			fatalError("Undecodable UTF-8 data.")
		case .EmptyInput:
			c	=	false
			
		case .Result(let scalar):
			s.append(scalar)
		}
	}
	return	s
}

///	TODO:	Optimise...?
func encodeToUTF8Data(string:String) -> ContiguousArray<UTF8.CodeUnit> {
	let	a		=	string.nulTerminatedUTF8
	let	data	=	ContiguousArray(a[a.startIndex..<a.endIndex.predecessor()])
	return	data
}