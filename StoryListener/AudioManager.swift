//
//  AudioManager.swift
//  StoryListener
//
//  Created by Mohammad Yasir on 07/05/21.
//

import Foundation
import AVFoundation

class MicManager: ObservableObject {
    
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    private var currentSample: Int
    private var numberOfSamples: Int

    @Published public var soundSamples: [Float]
    
    init(numberOfSamples: Int) {
        
        self.numberOfSamples = numberOfSamples > 0 ? numberOfSamples : 10
        self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission{ (success) in
                if !success {
                    fatalError("We need your audio to visualize")
                }
            }
        }
        
        let pathURL = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let audioRecorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: pathURL, settings: audioRecorderSettings)
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    open func startMonitoring() {
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {(timer) in
            self.audioRecorder.updateMeters()
            self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
    }
    
    open func stopMonitoring() {
        audioRecorder.stop()
    }
    
    deinit {
        timer?.invalidate()
        audioRecorder.stop()
    }

}
