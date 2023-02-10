//
//  FrequencyResponse.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 2/5/23.
//

import Foundation

public struct FrequencyResponse:Codable {
    public var response: [Frequency]
    
    init(response:[Frequency]) {
        self.response = response
    }
    
    init(autoSpectrum: [Float], bucketSize:Double) {
        self.response = []
        for (index, value) in autoSpectrum.enumerated() {
            self.response.append(Frequency(index: index, db: value, bucketSize: bucketSize))
        }
    }
    
    func toAveragedResponse(binCount:Int) -> FrequencyResponse {
        let samplesPerBucket = Int(self.response.count / binCount)
        var newResponse:[Frequency] = []
        var freqAccum: Float = 0
        var dbAccum:Float = 0
        for (index, frequency) in self.response.enumerated() {
            freqAccum += frequency.hz
            dbAccum += frequency.db
            if index % samplesPerBucket == 0 {
                newResponse.append(Frequency(db: (dbAccum / Float(samplesPerBucket)),
                                             freqHz: (freqAccum / Float(samplesPerBucket))))
                freqAccum = 0
                dbAccum = 0
            }
        }
        return FrequencyResponse(response: newResponse)
    }
}
