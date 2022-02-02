//
//  HLSAsset.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation

public struct HLSAsset: Equatable {

    // MARK: Initializer
    public init(url: URL) {
        self.item = AVPlayerItem(url: url)
    }

    // MARK: Stored Properties
    public let item: AVPlayerItem

    // MARK: Computed Properties
    public var asset: AVAsset {
        self.item.asset
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

public struct HLSAssetOption: Equatable {

    public let option: AVMediaSelectionOption

    public let group: AVMediaSelectionGroup

    public var name: String {
        self.option.displayName
    }

}
