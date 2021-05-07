//
//  SpeechManager.swift
//  StoryListener
//
//  Created by Mohammad Yasir on 07/05/21.
//

import Foundation
import Speech

class SpeechManager {
    
    public var isRecording = false
    
    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioNode!
    private var audioSession: AVAudioSession!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    open func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization{ (authStatus) in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: break
                default:
                    print("Cant Speech Recogination setup")
                }
            }
        }
    }
    
    open func start(completion: @escaping(String?) -> Void) {
        if isRecording {
            stopListening()
        } else {
            startListening(completion: completion)
        }
    }
    
    open func startListening(completion: @escaping (String?) -> Void) {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            print("Speech Feature is not availble ")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest!.shouldReportPartialResults = true
        
        recognizer.recognitionTask(with: recognitionRequest!) { (result, error) in
            guard error == nil else {
                print("Error : \(error!.localizedDescription)")
                return
            }
            
            guard let result = result else { return }
            
            if result.isFinal {
                completion(result.bestTranscription.formattedString)
            }
        }
        
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){ (buffer, _) in
            self.recognitionRequest?.append(buffer)
            
        }
        
        audioEngine.prepare()
        
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioEngine.start()
        } catch {
            print(error)
        }
        
    }
    
    open func stopListening() {
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        try? audioSession.setActive(false)
        audioSession = nil
    }
    
    
}

