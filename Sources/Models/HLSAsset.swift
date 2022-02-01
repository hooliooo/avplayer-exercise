//
//  HLSAsset.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation

public struct HLSAsset {

    // MARK: Initializer
    public init(url: URL) {
        self.playerItem = AVPlayerItem(url: url)
    }

    // MARK: Stored Properties
    public let playerItem: AVPlayerItem

    // MARK: Computed Properties
    public var asset: AVAsset {
        self.playerItem.asset
    }

    public var characteristics: [AVMediaCharacteristic] {
        return self.asset.availableMediaCharacteristicsWithMediaSelectionOptions
    }

    func group(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        guard let group = self.asset.mediaSelectionGroup(forMediaCharacteristic: characteristic) else {
            return nil
        }
        return group
    }
}

public struct HLSAssetOption {

    public let option: AVMediaSelectionOption

    public let group: AVMediaSelectionGroup

    public var name: String {
        self.option.displayName
    }

}
