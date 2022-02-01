//
//  ContentView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation
import AVFoundationCombine
import AVKit
import OSLog
import SwiftUI

internal let ViewLog: OSLog = OSLog(subsystem: "com.alorro.AVPlayerExercise", category: "UI")

struct ContentView: View {

    let asset: HLSAsset = HLSAsset(url: Constants.url)

    @State var isPlaying: Bool = false
    @State var showControls: Bool = true
    @State var workItem: DispatchWorkItem?
    @State var optionsButtonTapped: Bool = false
    @State var selectedOptions: [AVMediaCharacteristic: HLSAssetOption] = [:]

    var body: some View {
//        VideoPlayer(player: AVPlayer(playerItem: self.asset.playerItem))
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                VideoPlayerView(
                    asset: self.asset,
                    mode: isPlaying ? .play : .pause,
                    selectedOptions: self.selectedOptions
                )
                    .onReceive(self.asset.playerItem.statusPublisher()) { element in
                        guard self.selectedOptions.isEmpty else { return }
                        switch element {
                            case .readyToPlay:
                                for characteristic in self.asset.characteristics {
                                    guard
                                        let group = self.asset.group(for: characteristic),
                                        let selectedOption = self.asset.playerItem.currentMediaSelection.selectedMediaOption(in: group)
                                    else {
                                        continue
                                    }

                                    self.selectedOptions[characteristic] = HLSAssetOption(option: selectedOption, group: group)
                                }

                            default: break
                        }
                    }

                if self.showControls {
                    OverlayView(
                        asset: self.asset,
                        buttonText: self.isPlaying ? "Pause" : "Play",
                        onPlayPauseButtonTapped: {
                            self.isPlaying.toggle()
                            self.workItem?.cancel()
                            self.onGestureEnd()
                        },
                        onOptionSelected: self.onOptionsSelected,
                        onOffOptionSelected: self.onOffOptionSelected,
                        onOptionsButtonTapped: self.onOptionsButtonTapped,
                        onCancelSelected: self.onCancelSelected,
                        selectedOptions: self.$selectedOptions
                    )
                        .frame(
                            minWidth: proxy.size.width - 5.0,
                            maxWidth: proxy.size.width - 5.0,
                            minHeight: 72.0,
                            maxHeight: 72.0,
                            alignment: Alignment.center
                        )
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { _ in
                    os_log("Dragging Currently", log: ViewLog, type: OSLogType.info)
                    self.workItem?.cancel()
                    withAnimation {
                        self.showControls = true
                    }
                }
                .onEnded { _ in
                    os_log("Dragging Ended", log: ViewLog, type: OSLogType.info)
                    self.onGestureEnd()
                }
        )
    }

    /**
     Creates a DispatchWorkItem that changes the self.showControls state variable to false with an animation to make the overlay disappear 5 seconds after the user finishes a gesture of anykind.
     */
    private func onGestureEnd() {
        if self.optionsButtonTapped {
            self.workItem?.cancel()
        } else {
            let item: DispatchWorkItem = DispatchWorkItem {
                withAnimation {
                    self.showControls = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: item)
            self.workItem = item
        }
    }

    private func onOptionsSelected(_ option: (characteristic: AVMediaCharacteristic, option: HLSAssetOption)) {
        self.optionsButtonTapped.toggle()
        self.onGestureEnd()
        self.selectedOptions[option.characteristic] = option.option
    }

    private func onOffOptionSelected() {
        self.optionsButtonTapped.toggle()
        self.onGestureEnd()
        self.selectedOptions[AVMediaCharacteristic.legible] = nil
    }

    private func onOptionsButtonTapped() {
        self.optionsButtonTapped.toggle()
        self.onGestureEnd()
    }

    private func onCancelSelected() {
        self.optionsButtonTapped.toggle()
        self.onGestureEnd()
    }
}

extension AVMediaSelectionOption: Identifiable {}

extension AVMediaCharacteristic: Identifiable {
    public var id: String {
        return self.rawValue
    }
}

extension String: Identifiable {
    public var id: Int {
        return self.hashValue
    }
}
