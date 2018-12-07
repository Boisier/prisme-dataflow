//
//  streamEmitterDelegate.swift
//  dataflow
//
//  Created by Valentin Dufois on 06/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

protocol streamEmitterDelegate: AnyObject {
	func emit(data: Data)
}