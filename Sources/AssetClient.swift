//
//  AssetClient.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 02.02.22.
//

import AVFoundation
import ComposableArchitecture

public struct AssetClient {
    public var monitorStatus: (HLSAsset) -> Effect<AVPlayerItem.Status, Never>
}

public extension AssetClient {
    static let success = AssetClient(
        monitorStatus: { (asset: HLSAsset) -> Effect<AVPlayerItem.Status, Never> in
            return asset.item.statusPublisher().eraseToEffect()
        }
    )
}
