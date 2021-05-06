//
//  Config.swift
//  wav2images
//
//  Created by Johan Halin on 6.5.2021.
//

import AVFAudio
import Foundation

struct Config: Codable {
    let inputFile: String
    let outputDir: String
    let sampleRate: Double
    let channels: AVAudioChannelCount
    let frameRate: Double
    
    static func decode(path: String) -> Config {
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try! decoder.decode(Config.self, from: jsonData)
    }
}
