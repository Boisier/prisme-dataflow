//
//  AudioStreamReader.swift
//  dataflow
//
//  Created by Dev on 2018-12-06.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AVFoundation
import MultipeerConnectivity
import Repeat

/// An AudioStreamReader takes an InputStream receiving AVAudioPCMBuffer buffers encoded
/// into data, decodes them, and plays it
class AudioStreamReader: NSObject {
    
    // //////////////////////////////
    // MARK: Input stream properties

    internal var _inputStream: InputStream?
    internal var _timerInterval: Repeater.Interval = .seconds(0.5)
	internal var _timer: Repeater?

	// //////////////////////////////
	// MARK: Audio player properties

    internal var _audioSession = AVAudioSession.sharedInstance()
	internal var _audioEngine = AVAudioEngine()
	internal var _playerNode = AVAudioPlayerNode()
	internal var _audioInput: AVAudioInputNode!
	internal var _audioFormat: AVAudioFormat!
    
    internal var _allowedBufferSize:[UInt32] = [22528, 21504, 22579, 21638, 21639]

	/// Init the audio engine to allow for playing audio comming from the stream
	override init() {
		_audioInput = _audioEngine.inputNode
		_audioEngine.attach(_playerNode)
		_audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)

		_audioEngine.connect(_playerNode, to: _audioEngine.mainMixerNode, format: _audioFormat)
        
        _playerNode.volume = 1

		_audioEngine.prepare()
	}

	/// Init the AudioStreamReader anddirectly start pmlaying the given stream
	///
	/// - Parameter stream: The stream holding audio informations
	convenience init(stream: InputStream) {
		self.init()

		read(stream: stream)
	}

    /// Store and schedule the incoming stream
    ///
    /// - Parameter stream: The stream to play
    func read(stream: InputStream) {
		// Store the stream
        _inputStream = stream

		// Start the audio Engine
		try! _audioEngine.start()

        if _timer == nil {
            _timer = Repeater(interval: self._timerInterval) { [weak self] timer in
                guard let `self` = self else { return }
                self.pollStream()
            }
        }
        
        _playerNode.play()
        
		DispatchQueue.main.async {
            self._timer?.start()
            self._inputStream!.schedule(in: .current, forMode: .common)
            self._inputStream!.open()
		}
    }
    
	/// End playing the stream: Close the incoming stream and the audioEngine.
	///
	/// A new AudioStreamReader must be created to play another stream
    func end() {
        _inputStream?.close()
		_timer?.pause()

		_audioEngine.stop()
		_playerNode.stop()
    }

	/// Make sure we properly stops all our elements
    deinit {
		end()
        
        _timer?.removeAllObservers()
    }
}


/// MARK: - Polling the stream
extension AudioStreamReader {
    func pollStream() {
        guard _playerNode.isPlaying else {
//            print("[AudioStreamReader.pollStream] Cannot schedule buffer if the player isn't running")
            return
        }
        
		// Make sure we have a stream in the first place
        guard let inputStream = _inputStream else {
            print("[AudioStreamReader.pollStream] There is no stream to poll")
			_playerNode.pause()
            return
        }

		// Does the stream holds informations ?
        guard inputStream.hasBytesAvailable else {
            print("[AudioStreamReader.pollStream] Stream has nothing to read")
			_playerNode.pause()
            return
        }

		// Extract and convert the stream informations to an audio buffer
        let inputData = Data(reading: inputStream)
        let audioBuffer = AVAudioPCMBuffer(data: inputData, audioFormat: AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!)!
        
        // If the buffer has an unknown size, skip it
        guard _allowedBufferSize.contains(audioBuffer.frameLength) else {
            return;
        }
        
		// Play the buffer
        App.audioAnalysisQueue.async {
            self._playerNode.scheduleBuffer(audioBuffer, completionHandler: nil)
            self._playerNode.play()
        }
    }
}
