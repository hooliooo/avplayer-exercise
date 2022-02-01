//
//  VideoPlayerView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import class AVFoundation.AVPlayer
import class AVFoundation.AVPlayerLayer
import UIKit
import SwiftUI

// MARK: SwiftUI View
public struct VideoPlayerView: UIViewRepresentable {

    // MARK: Initializer
    public init(url: URL, mode: VideoPlayerView.Mode = .pause) {
        self.url = url
        self.mode = mode
    }

    // MARK: Stored Properties
    public var url: URL

    public var mode: VideoPlayerView.Mode

    // MARK: UIViewRepresentable Methods
    public func updateUIView(_ uiView: _VideoPlayerView, context: Context) {
        switch self.mode {
            case .pause: uiView.player.pause()
            case .play: uiView.player.play()
        }

    }

    public func makeUIView(context: Context) -> _VideoPlayerView {
        let view: _VideoPlayerView = _VideoPlayerView()
        view.player = AVPlayer(url: self.url)
        return view
    }

}

// MARK: Coordinator
public extension VideoPlayerView {

    enum Mode {
//        case fastFoward
        case play
        case pause
//        case rewind
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
