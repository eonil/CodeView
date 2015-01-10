//
//  AppDelegate.swift
//  InteractiveTester
//
//  Created by Hoon H. on 2015/01/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	let	codeView	=	CodeView()

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		let	dataFilePath	=	"/Users/Eonil/Workshop/Sandbox3/CodeStorage/PerfTest/test-data-ascii-50kb.rs"
//		let	dataFilePath	=	"/Users/Eonil/Workshop/Sandbox3/CodeStorage/PerfTest/test-data-ascii-500kb.rs"

		window.contentView	=	codeView
		codeView.loadFileAtPath(dataFilePath)
		codeView.needsLayout	=	true
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

