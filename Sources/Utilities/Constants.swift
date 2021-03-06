//
//  Constants.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import Foundation
import OSLog

// swiftlint:disable line_length
public enum Constants {

    public static let url: URL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")! // swiftlint:disable:this force_unwrapping

    internal static let ViewLog: OSLog = OSLog(subsystem: "com.alorro.AVPlayerExercise", category: "UI")

    public static let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.allowsFractionalUnits = false
        f.zeroFormattingBehavior = .pad
        return f
    }()

}
