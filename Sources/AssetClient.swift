//
//  AssetClient.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 02.02.22.
//

import AVFoundation
import Combine
import ComposableArchitecture

public struct AssetClient {
    public var monitorStatus: (HLSAsset) -> Effect<AVPlayerItem.Status, Never>
    public var monitorProgress: (AVPlayer) -> Effect<TimeInterval, Never>
    public var seekProgress: (AVPlayer, TimeInterval) -> Effect<TimeInterval, Never>
}

public extension AssetClient {
    static var live: Self {
        return Self(
            monitorStatus: { (asset: HLSAsset) -> Effect<AVPlayerItem.Status, Never> in
                return asset.item.statusPublisher().eraseToEffect()
            },
            monitorProgress: { (player: AVPlayer) -> Effect<TimeInterval, Never> in
                return player.playheadProgressPublisher(interval: 1.0).eraseToEffect()
            },
            seekProgress: { (player: AVPlayer, seconds: TimeInterval) -> Effect<TimeInterval, Never> in
                .task(priority: TaskPriority.userInitiated) {
                    let time: CMTime = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                    player.seek(to: time)
                    return seconds
                }
            }
        )
    }
}

private class AssetClientDelegate {

    init(player: AVPlayer) {
        self.player = player
    }

    // MARK: Stored Properties
    weak var player: AVPlayer?
}
