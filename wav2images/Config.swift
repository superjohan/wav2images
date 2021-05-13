//
//  Config.swift
//  wav2images
//
//  Created by Johan Halin on 6.5.2021.
//

import AVFAudio
import Foundation

struct Config: Decodable {
    let inputFile: String
    let outputDir: String
    let sampleRate: Double
    let channels: AVAudioChannelCount
    let frameRate: Double
    let waveColor: Color
    let backgroundColor: Color
    let lineWidth: CGFloat
    let test: Bool
    
    static func decode(path: String) -> Config {
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try! decoder.decode(Config.self, from: jsonData)
    }
}

struct Color: Decodable {
    let cgColor: CGColor
    
    init(from decoder: Decoder) throws {
        let container = try! decoder.singleValueContainer()
        let hexString = try! container.decode(String.self)
        
        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000ff) / 255

            self.cgColor = CGColor(red: r, green: g, blue: b, alpha: 1)
        } else {
            print("could not decode hex string: \(hexString)")

            self.cgColor =  CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        }
    }
}
