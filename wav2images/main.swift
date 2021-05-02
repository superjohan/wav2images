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

if arguments.count != 6 {
    print("usage: wav2images input_file output_dir sample_rate channels frame_rate")
    exit(0)
}

let inputFile = arguments[1]
let outputDir = arguments[2]
let sampleRate = Double(arguments[3])!
let channels = AVAudioChannelCount(arguments[4])!
let frameRate = Double(arguments[5])!

let width = 1920
let height = 1080
let samplesPerImage = sampleRate / frameRate

let url = URL(fileURLWithPath: inputFile)
let file = try! AVAudioFile(forReading: url)
let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels)!
let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samplesPerImage))!

var fileCounter = 0
let totalFrames = Int(ceil(Double(file.length) / samplesPerImage))

while file.framePosition < file.length {
    try! file.read(into: buffer)
    let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
    
    let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.genericRGBLinear)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    )!

    context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
    context.addRect(CGRect(x: 0, y: 0, width: width, height: height))
    context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    context.beginPath()
    context.move(to: CGPoint(x: 0, y: CGFloat(height) / 2.0))
    
    let xStride = CGFloat(width) / CGFloat(samplesPerImage)
    var x = CGFloat(0)
    
    for sample in samples {
        let y = CGFloat(((sample + 1.0) / 2.0) * Float(height))
        
        context.addLine(to: CGPoint(x: x, y: y))
        
        x += xStride
    }
    
    context.strokePath()

    let image = context.makeImage()!
    let destinationURL = URL(fileURLWithPath: "\(outputDir)/image \(fileCounter).png")
    let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
    
    fileCounter += 1
    
    if fileCounter % 100 == 0 {
        print("\(fileCounter) frames of \(totalFrames) rendered")
    }
}

print("done! \(fileCounter) total frames rendered")
