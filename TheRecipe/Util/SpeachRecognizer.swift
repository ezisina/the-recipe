//
//  SpeachRecognizer.swift
//  RecipesBook
//
//  Created by Elena Zisina on 6/25/21.
//

import Foundation
import AVFoundation
import Speech

class SpeechRecognizer: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest
    private var task : SFSpeechRecognitionTask?
    
    @Published var message = ""
    
    static var shared: SpeechRecognizer {
        struct Singleton {
            static var instance = SpeechRecognizer()
        }
        return Singleton.instance
    }
    
    private init() {
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()
        request = SFSpeechAudioBufferRecognitionRequest()
    }
    
//    func start() {
//        switch AVAudioSession.sharedInstance().recordPermission {
//        case .granted:
//            print("Permission granted")
//            self.startRecognition()
//        case .denied:
//            print("Pemission denied")
//        case .undetermined:
//            print("Request permission here")
//            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
//                guard granted else {
//                    print("permission denied")
//                    return
//                }
//                self.startRecognition()
//            })
//        @unknown default:
//            print("Permission unknoown")
//        }
//    }
    
    func start() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .notDetermined:
                print("Speech recognition status is not determined")
            case .denied:
                print("Speech recognition denied")
            case .restricted:
                print("Speech recognition is restricted")
            case .authorized:
                self.beginRecognition()
            @unknown default:
                print("Speech recognition status unknown")
            }
        }
    }
    
    private func beginRecognition() {
        stop()
        
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()
        request = SFSpeechAudioBufferRecognitionRequest()
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        request.requiresOnDeviceRecognition = true
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            print("Error comes here for starting the audio listner =\(error.localizedDescription)")
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            print("Recognization is not allow on your local")
            return
        }
        
        guard myRecognization.isAvailable else {
            print("Recognization is busy right now, Please try again after some time.")
            return
        }
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { (response, error) in
            guard let response = response else {
                if error != nil {
                    print(error.debugDescription)
                }else {
                    print("Problem in giving the response")
                }
                return
            }
            
            let message = response.bestTranscription.formattedString
            print("Message : \(message)")
            self.message = message
            
//            var lastString: String = ""
//            for segment in response.bestTranscription.segments {
//                let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
//                lastString = String(message[indexTo...])
//            }
        })
    }
    
    func stop() {
        task?.finish()
        task?.cancel()
        task = nil
                
        request.endAudio()
        audioEngine.stop()

        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
    
}
