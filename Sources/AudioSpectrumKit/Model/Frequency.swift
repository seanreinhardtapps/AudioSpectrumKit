//
//  Frequency.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation

public struct Frequency: Codable, Identifiable {
    public var id:String
    public var hz: Float
    public var db: Float
    
    init(db:Float, freqHz:Float) {
        self.db = db
        self.hz = freqHz
        self.id = Frequency.makeId(hz: freqHz)
    }
    
    init(index:Int, db:Float, bucketSize:Double) {
        self.db = db
        let freqHz = Float(Double(index) * bucketSize)
        self.hz = freqHz
        self.id = Frequency.makeId(hz: freqHz)
    }
    
    static func makeId(hz:Float) -> String {
        if hz > 1000 {
            return String(format: "%.1fkHz", (hz / 1000))
        }
        return String(format: "%.1fHz", hz)
    }
}
