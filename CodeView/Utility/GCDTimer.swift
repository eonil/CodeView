//
//  GCDTimer.swift
//  CodeView
//
//  Created by Hoon H. on 2015/01/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation






func dispatchAfterOnMainSerialQueue(interval:NSTimeInterval, function:()->()) {
	let	when	=	dispatch_time(DISPATCH_TIME_NOW, Int64(interval.toNanoseconds))
	dispatch_after(when, dispatch_get_main_queue(), function)
}




/////	ref:	https://developer.apple.com/library/mac/documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html#//apple_ref/doc/uid/TP40008091-CH103-SW2
//final class GCDTimer {
//	init(interval:NSTimeInterval, queue:dispatch_queue_t, leeway:NSTimeInterval, function:()->()) {
//		let	source		=	dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)!
//		
//		let	when		=	DISPATCH_TIME_NOW
//		let	start		=	dispatch_time(when, 0)
//		dispatch_source_set_timer(source, start, interval.toNanoseconds, leeway.toNanoseconds)
//		dispatch_source_set_event_handler(source, function)
//		dispatch_resume(source)
//		
//		self.source	=	source
//	}
//	deinit {
//		dispatch_source_cancel(source);
//	}
//	
//	private let	source: dispatch_source_t
//}
//
//extension GCDTimer {
//	class func onMainSerialQueue(interval:NSTimeInterval, leeway:NSTimeInterval, function:()->()) -> GCDTimer {
//		return	GCDTimer(interval: interval, queue: dispatch_get_main_queue(), leeway: leeway, function: function)
//	}
//	class func onGlobalDefaultConcurrentQueue(interval:NSTimeInterval, leeway:NSTimeInterval, function:()->()) -> GCDTimer {
//		let	queue	=	dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//		return	GCDTimer(interval: interval, queue: dispatch_get_main_queue(), leeway: leeway, function: function)
//	}
//	class func onGlobalBackgroundConcurrentQueue(interval:NSTimeInterval, leeway:NSTimeInterval, function:()->()) -> GCDTimer {
//		let	queue	=	dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
//		return	GCDTimer(interval: interval, queue: dispatch_get_main_queue(), leeway: leeway, function: function)
//	}
//	
//	class func onMainSerialQueue(interval:NSTimeInterval, function:()->()) -> GCDTimer {
//		return	GCDTimer(interval: interval, queue: dispatch_get_main_queue(), leeway: 0, function: function)
//	}
//	class func onGlobalDefaultConcurrentQueue(interval:NSTimeInterval, function:()->()) -> GCDTimer {
//		let	queue	=	dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//		return	GCDTimer(interval: interval, queue: dispatch_get_main_queue(), leeway: 0, function: function)
//	}
//	class func onGlobalBackgroundConcurrentQueue(interval:NSTimeInterval, function:()->()) -> GCDTimer {
//		let	queue	=	dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
//		return	GCDTimer(interval: interval, queue: dispatch_get_main_queue(), leeway: 0, function: function)
//	}
//}




private extension NSTimeInterval {
	var toNanoseconds:UInt64 {
		get {
			return	UInt64(self * NSTimeInterval(NSEC_PER_SEC))
		}
	}
}