//
//  Speaker.swift
//  RecipesBook
//
//  Created by Elena Zisina on 6/23/21.
//https://gist.github.com/Libranner/052de5f482da046deae0ad6b6bc1b8ef

import SwiftUI
#if canImport(AVFoundation)
import AVFoundation
#endif

#if !os(macOS)

final class Speaker: NSObject, ObservableObject {
    
    @Published var state: State = .inactive
    @Published private(set) var shouldSpeakUpStep = false
    
    enum State: String {
        case inactive, speaking, paused
    }

    override init() {
        super.init()
        synth.delegate = self
        do { try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker) }
        catch {
            print(error.localizedDescription)
        }

    }
    
    func setEnabled(_ isEnabled: Bool = true) {
        shouldSpeakUpStep = isEnabled
        if !isEnabled {
            stop()
        }
    }
//
//    func speak(words: String, completionHandler: () -> Void = {}) {
//        stop()
//        synth.speak()
//        print("speak \(words)")
//    }
    
    func speak(text: String, completionHandler: @escaping () -> Void = {}) {
        stop()
        let utterance = AVCallBackableSpeechUtterance(string: text, completionHandler: completionHandler)
        synth.speak(utterance)
        print("speak \(text)")
    }
    
    func stop() {
        synth.stopSpeaking(at: .immediate )
    }
    
    func pause() {
        synth.pauseSpeaking(at: .word)
    }
    
    private let synth: AVSpeechSynthesizer = .init()
    
}
extension Speaker: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.state = .speaking
        print("speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        self.state = .paused
        print("paused")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.state = .inactive
        (utterance as? AVCallBackableSpeechUtterance)?.complete()
        print("finished")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        (utterance as? AVCallBackableSpeechUtterance)?.complete()
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {}

    
}


// MARK: -

class AVCallBackableSpeechUtterance: AVSpeechUtterance {
    private let completionHandler: () -> Void
    init(string: String, completionHandler: @escaping () -> Void = {}) {
        self.completionHandler = completionHandler
        super.init(string: string)
    }
    
    func complete() {
        DispatchQueue.main.async(execute: completionHandler)
    }
    
    required init?(coder: NSCoder) {
        self.completionHandler = {}
        super.init(coder: coder)
    }
}
#else

final class Speaker: NSObject, ObservableObject {
    let state: State = .inactive
    let shouldSpeakUpStep = false
    enum State: String {
        case inactive, speaking, paused
    }

    override init() {
        super.init()
    }
    
    func setEnabled(_ isEnabled: Bool) {
      
    }
//
//    func speak(words: String, completionHandler: () -> Void = {}) {
//        stop()
//        synth.speak()
//        print("speak \(words)")
//    }
    
    func speak(text: String, completionHandler: @escaping () -> Void = {}) {
    }
    
    func stop() {
    }
    
    func pause() {
    }
    
    
}


#endif
