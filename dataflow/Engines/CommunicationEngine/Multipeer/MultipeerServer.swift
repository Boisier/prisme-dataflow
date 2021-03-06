//
//  MultipeerServer.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import MultipeerConnectivity

/// The multipeer server is used to create a new multipeer master
class MultipeerServer: MultipeerDevice {

	// /////////////////
	// MARK: Properties

	/// Tells if the server is currently runnin
	private var _running: Bool = false

	/// Tells if the server is currently runnin
	var isRunning: Bool { return _running }

	/// The advertiser used make ourself discoverable
	private var _peerServiceAdvertiser: MCNearbyServiceAdvertiser!

	/// Properly ends the server when free-ed
	deinit {
		close()
	}
}


// MARK: - Server start and shutdown
extension MultipeerServer {
	/// Open the server, making it discoverable by clients
	func open() {
		_peerServiceAdvertiser = MCNearbyServiceAdvertiser(peer: _devicePeerID,
														   discoveryInfo: nil,
														   serviceType: self.peerServiceName)

		_peerServiceAdvertiser!.delegate = self
		_peerServiceAdvertiser!.startAdvertisingPeer()

		_running = true
	}

	/// Close the server, closing all available connection
	func close() {
		_peerServiceAdvertiser?.stopAdvertisingPeer()
		_peerServiceAdvertiser = nil

		_session?.disconnect()

		_running = false
	}
}


// MARK: - Convenient session accesses
extension MultipeerServer {
	/// Tells the number of peers currently connected to the session
	var connectedPeers: [MCPeerID] {
		return _session.connectedPeers
	}
}
