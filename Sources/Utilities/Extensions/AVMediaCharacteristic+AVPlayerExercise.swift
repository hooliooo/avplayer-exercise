//
//  AVMediaCharacteristic+AVPlayerExercise.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 02.02.22.
//

import struct AVFoundation.AVMediaCharacteristic

extension AVMediaCharacteristic: Identifiable {
    public var id: String {
        return self.rawValue
    }
}
