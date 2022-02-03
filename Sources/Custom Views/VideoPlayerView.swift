//
//  VideoPlayerView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation
import UIKit
import SwiftUI

// MARK: SwiftUI View
public struct VideoPlayerView: UIViewRepresentable {

    // MARK: Initializer
    public init(
        player: AVPlayer,
        mode: VideoPlayerView.Mode = .pause,
        selectedOptions: [AVMediaCharacteristic: HLSAssetOption] = [:]
    ) {
        self.player = player
        self.mode = mode
        self.selectedOptions = selectedOptions
    }

    // MARK: Stored Properties
    public var player: AVPlayer

    public var mode: VideoPlayerView.Mode

    public var selectedOptions: [AVMediaCharacteristic: HLSAssetOption]

    // MARK: UIViewRepresentable Methods
    public func updateUIView(_ uiView: _VideoPlayerView, context: Context) {
        switch self.mode {
            case .pause: uiView.player.pause()
            case .play: uiView.player.play()
        }

        self.selectedOptions.forEach { (_, asset) -> Void in
            uiView.player.currentItem?.select(asset.option, in: asset.group)
        }
    }

    public func makeUIView(context: Context) -> _VideoPlayerView {
        let view: _VideoPlayerView = _VideoPlayerView()
        view.player = self.player
        return view
    }

}

// MARK: Coordinator
public extension VideoPlayerView {

    enum Mode: Hashable {
        case play
        case pause
    }

}

// MARK: Underlying UIKit UIView
public class _VideoPlayerView: UIView { // swiftlint:disable:this type_name

    // MARK: AVFoundation related properties
    override class public var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    public var videoLayer: AVPlayerLayer {
        self.layer as! AVPlayerLayer // swiftlint:disable:this force_cast
    }

    public var player: AVPlayer {
        get { return self.videoLayer.player! } // swiftlint:disable:this force_unwrapping

        set { self.videoLayer.player = newValue }
    }
}
