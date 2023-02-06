//
//  AudioSpectrumKit.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 6/12/22.
//

import UIKit
import AVFoundation
private let microphonePermissionKey = "NSMicrophoneUsageDescription"

public protocol AudioSpectrumKitResultsDelegate: NSObject {
    func didReceiveSample(frequencyResponse:FrequencyResponse)
    func samplingFailedToStart(error:Error)
    func samplingFailedToSetup(error:Error)
}

public class AudioSpectrumKit: NSObject, AudioSamplingInstanceDelegate {
    
    internal var sampleRate:UInt = 4096
    var delegate: AudioSpectrumKitResultsDelegate?
    internal var audioSession: AVAudioSession {
        didSet {
            do {
                try audioSession.setCategory(.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
            } catch {
                delegate?.samplingFailedToSetup(error: error)
            }
        }
    }
    
    internal var samplingInstance: SamplingInstance?
    public init(delegate: AudioSpectrumKitResultsDelegate? = nil,
                audioSession: AVAudioSession = AVAudioSession.sharedInstance(),
                bundle:Bundle = Bundle.main) {
        self.delegate = delegate
        self.audioSession = audioSession
        super.init()
        
        if !verifyRecordingPermissionKey(bundle: bundle) {
            delegate?.samplingFailedToSetup(error: AudioSpectrumKitErrorFactory.plistError())
            return
        }
        
        self.samplingInstance = SamplingInstance(delegate: self,
                                                 rate: sampleRate,
                                                 powerSpectrum: FFTPowerSpectrum(n: sampleRate),
                                                 audioSession: self.audioSession)
    }
    
    func verifyRecordingPermissionKey(bundle:Bundle) -> Bool {
        if let info = bundle.infoDictionary, let permissionKey = info[microphonePermissionKey] as? String {
            return permissionKey.count > 0
        }
        return false
    }
    
    public func start() {
        weak var weakSelf = self
        audioSession.requestRecordPermission { (granted) -> Void in
            if !granted {
                OperationQueue.main.addOperation {
                    if let strongSelf = weakSelf {
                        strongSelf.delegate?.samplingFailedToSetup(error: AudioSpectrumKitErrorFactory.permissionError())
                    }
                }
                return
            }
            if let instance = weakSelf?.samplingInstance {
                instance.sample()
            }
        }
    }
    
    func sampleProcessed(result: FrequencyResponse) {
        delegate?.didReceiveSample(frequencyResponse: result)
    }
}
