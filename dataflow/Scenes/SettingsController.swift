//
//  SettingsController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 02/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

class SettingsController:UINavigationController {
	// Unuseds
}

class SettingsTableController:UITableViewController {
	@IBOutlet var serverURLField: UITextField!
	@IBOutlet var serverPortField: UITextField!
	@IBOutlet var appTypeControl: UISegmentedControl!

	override func viewDidLoad() {
		serverURLField.text = DataFlowDefaults.serverURL.url!.absoluteString
		serverPortField.text = "\(DataFlowDefaults.serverPort.integer!)"
		if(DataFlowDefaults.appType.string! == "receiver") {
			appTypeControl.selectedSegmentIndex = 1
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		DataFlowDefaults.serverURL.set(value: URL(string: serverURLField.text!)!)
		DataFlowDefaults.serverPort.set(value: Int(serverPortField.text!)!)

		NotificationCenter.default.post(name: Notifications.settingsUpdated.name, object: nil)
	}

	@IBAction func onAppTypeChanged(_ sender: Any) {
		// Switch from emitter to receiver
		if(DataFlowDefaults.appType.string == "emitter") {
			DataFlowDefaults.appType.set(value: "receiver")
			NotificationCenter.default.post(name: Notifications.switchToReceiver.name, object: nil)
			return
		}

		// Switch from receiver to emitter
		DataFlowDefaults.appType.set(value: "emitter")
		NotificationCenter.default.post(name: Notifications.switchToEmitter.name, object: nil)
	}
}
