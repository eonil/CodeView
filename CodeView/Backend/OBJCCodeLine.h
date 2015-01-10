//
//  OBJCCodeLine.h
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//


#pragma once


@interface OBJCCodeLine: NSObject
@end




struct CodeLineMap;
typedef void const*		CodeLineMapKey;

CodeLineMap const*		CodeLineMapCreate();
void					CodeLineMapDelete(CodeLineMap const* ptr);						///	This also removes all existing data.

intptr_t				CodeLineMapGetDataLengthForKey(CodeLineMapKey key);
uint8_t const*			CodeLineMapGetDataAddressForKey(CodeLineMapKey key);			///	Data address is fixed until it to be removed.


CodeLineMapKey			CodeLineMapAddData(intptr_t const length, uint8_t const* data);
void					CodeLineMapRemoveDataForKey(CodeLineMapKey key);




