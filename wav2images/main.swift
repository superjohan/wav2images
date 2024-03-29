//
//  main.swift
//  wav2images
//
//  Created by Johan Halin on 2.5.2021.
//

import AVFAudio
import Cocoa
import Foundation

let arguments = CommandLine.arguments

if arguments.count != 2 {
    print("usage: wav2images config_json_file")
    exit(0)
}

let configFile = arguments[1]
let config = Config.decode(path: configFile)
dump(config)

let inputFile = config.inputFile
let outputDir = config.outputDir
let sampleRate = config.sampleRate
let channels = config.channels
let frameRate = config.frameRate
let isTest = config.test

let width = 1920
let height = 1080
let samplesPerImage = sampleRate / frameRate

let url = URL(fileURLWithPath: inputFile)
let file = try! AVAudioFile(forReading: url)
let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels)!
let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samplesPerImage))!

var fileCounter = 0
let totalFrames = ceil(Double(file.length) / samplesPerImage)
let digits = totalFrames > 0 ? Int(log10(totalFrames)) + 1 : 1

let queue = DispatchQueue(label: "renderQueue", attributes: .concurrent)
let group = DispatchGroup()

while file.framePosition < file.length {
    try! file.read(into: buffer)
    let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
    let fc = fileCounter

    group.enter()
    
    queue.async(group: group) {
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )!

        context.setFillColor(config.backgroundColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setStrokeColor(config.waveColor.cgColor)
        context.setLineWidth(config.lineWidth)
        context.beginPath()
        
        func y(_ sample: Float) -> CGFloat {
            CGFloat(((sample + 1.0) / 2.0) * Float(height))
        }
        
        context.move(to: CGPoint(x: 0, y: y(samples[0])))
        
        let xStride = CGFloat(width) / CGFloat(samplesPerImage)
        var x = CGFloat(0)
        
        for sample in samples {
            context.addLine(to: CGPoint(x: x, y: y(sample)))
            
            x += xStride
        }
        
        context.strokePath()

        let image = context.makeImage()!
        let filename = String(format: "image %0\(digits)d.png", fc)
        let destinationURL = URL(fileURLWithPath: "\(outputDir)/\(filename)")
        let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)

        if fc % 100 == 0 {
            print("\(fc) frames of \(Int(totalFrames)) rendered")
        }
        
        // FIXME: this is goofy in an async context
        if (isTest) {
            print("test frame rendered")
            exit(0)
        }

        group.leave()
    }

    fileCounter += 1
}

group.wait()

print("done! \(fileCounter) total frames rendered")
