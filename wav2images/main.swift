//
//  main.swift
//  wav2images
//
//  Created by Johan Halin on 2.5.2021.
//

import AVFAudio
import Cocoa
import Foundation

let width = 1920
let height = 1080
let sampleRate = 44100
let frameRate = 60
let samplesPerImage = sampleRate / frameRate

let url = URL(fileURLWithPath: "/Users/rm/Desktop/pink.wav")
let file = try! AVAudioFile(forReading: url)
let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samplesPerImage))!

var fileCounter = 0

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
    let destinationURL = URL(fileURLWithPath: "/Users/rm/Desktop/output/image \(fileCounter).png")
    let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
    
    fileCounter += 1
    
    print("rendered frame \(fileCounter)")
}

