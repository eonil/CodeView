//
//  OBJCCodeLine.m
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBJCCodeLine.h"
#import <unordered_map>
#import <vector>

@implementation OBJCCodeLine
@end




struct
CodeLine {
public:
	
private:
	std::vector<uint8_t>	_data	=	std::vector<uint8_t>();
	CodeLine*				_prior	=	nullptr;
	CodeLine*				_next	=	nullptr;
};


struct
CodeLineMap {
	using	datamap	=	std::unordered_map<CodeLineMapKey,DataEntry>;
public:
	CodeLineMap() {
	}
	~CodeLineMap() {
	}
private:
	
	datamap	_datamap	=	datamap();
};




CodeLineMap const*
CodeLineMapCreate() {
	return	new CodeLineMap();
}

void
CodeLineMapDelete(CodeLineMap const* ptr) {
	assert(ptr != nullptr);
	delete	ptr;
}



intptr_t
CodeLineMapGetDataLengthForKey(CodeLineMapKey key) {
	
}
uint8_t const*
CodeLineMapGetDataAddressForKey(CodeLineMapKey key) {
	
}



CodeLineMapKey
CodeLineMapAddData(intptr_t const length, uint8_t const* data) {
	
}
void
CodeLineMapRemoveDataForKey(CodeLineMapKey key) {
	
}