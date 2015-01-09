//
//  RustCodeStorage.swift
//  CodeStorage
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

class RustCodeLineAnnotation: CodeLineAnnotation {
	var	display			=	Display.None
	var	parsingCache	=	ParsingCache()
	
	enum Display {
		case None
		case Comment(CommentClass)
		case Keyword(KeywordClass)
		case Identifier(IdenfierClass)
		case Punctuator(PunctuatorClass)
		case Literal(LiteralClass)
		
		var isKeword:Bool {
			get {
				switch self {
				case .Keyword(_):	return	true
				default:			return	false
				}
			}
		}
		
		enum MacroClass {
			case Any
		}
		enum KeywordClass {
			case Any
		}
		enum CommentClass {
			case Text
			case Document
		}
		enum LiteralClass {
			case String
			case Number
		}
		enum IdenfierClass {
			case ModuleName
			case FunctionName
			case StructName
			case TraitName
		}
		enum PunctuatorClass {
			case Operator
			case Other
		}
	}
	
	struct ParsingCache {
		var	blockCommentStartMarker		=	false
		var	blockCommentEndMarker		=	false
		var	stringLiteralStartMarker	=	false
		var	stringLiteralEndMarker		=	false
	}
}