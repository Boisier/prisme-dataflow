//
//  DataFlowDefaults.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

enum DataFlowDefaults:String {
	case version
	case serverURL
	case serverPort
	case appType
	case peerServiceName
}

extension DataFlowDefaults {

	var url: URL? {
		return UserDefaults.standard.url(forKey: self.rawValue)
	}

	var integer: Int? {
		return UserDefaults.standard.integer(forKey: self.rawValue)
	}

	var string: String? {
		return UserDefaults.standard.string(forKey: self.rawValue)
	}

	func set(value: URL) -> Void {
		UserDefaults.standard.set(value, forKey: self.rawValue)
	}

	func set(value: Int) -> Void {
		UserDefaults.standard.set(value, forKey: self.rawValue)
	}

	func set(value: String) -> Void {
		UserDefaults.standard.set(value, forKey: self.rawValue)
	}
}
