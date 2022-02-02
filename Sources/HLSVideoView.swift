//
//  HLSVideoView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation
import AVFoundationCombine
import AVKit
import ComposableArchitecture
import OSLog
import SwiftUI

// swiftlint:disable pattern_matching_keywords
public struct HLSVideoView: View {

    // MARK: Stored Properies
    public let store: Store<State, Action>

    // MARK: View
    public var body: some View {
//        VideoPlayer(player: AVPlayer(playerItem: self.asset.playerItem))
        WithViewStore(self.store) { viewStore in
            ZStack(alignment: .bottom) {
                VideoPlayerView(
                    asset: viewStore.asset,
                    mode: viewStore.overlayState.isPlaying ? .play : .pause,
                    selectedOptions: viewStore.overlayState.selectedOptionsByCharacteristic.compactMapValues { $0 }
                )
                if viewStore.isShowingPlaybackOverlay {
                    OverlayView(
                        store: self.store.scope(state: \.overlayState, action: Action.overlay)
                    )
                        .frame(
                            minWidth: 0.0,
                            maxWidth: .infinity,
                            minHeight: 72.0,
                            maxHeight: 72.0,
                            alignment: Alignment.center
                        )
                }
            }
            .onAppear {
                viewStore.send(Action.monitorStatus)
            }
            .gesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged { _ in
                        os_log("Dragging Currently", log: Constants.ViewLog, type: OSLogType.info)
    //                    self.workItem?.cancel()
    //                    withAnimation {
    //                        self.showControls = true
    //                    }
                    }
                    .onEnded { _ in
                        os_log("Dragging Ended", log: Constants.ViewLog, type: OSLogType.info)
    //                    self.onGestureEnd()
                    }
                )
        }
    }

    /**
     Creates a DispatchWorkItem that changes the self.showControls state variable to false with an animation to make the overlay disappear 5 seconds after the user finishes a gesture of anykind.
     */
    private func onGestureEnd() {
//        if self.optionsButtonTapped {
//            self.workItem?.cancel()
//        } else {
//            let item: DispatchWorkItem = DispatchWorkItem {
//                withAnimation {
//                    self.showControls = false
//                }
//            }
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: item)
//            self.workItem = item
//        }
    }

    private func onOptionsSelected(_ option: (characteristic: AVMediaCharacteristic, option: HLSAssetOption)) {
//        self.optionsButtonTapped.toggle()
//        self.onGestureEnd()
//        self.selectedOptions[option.characteristic] = option.option
    }

    private func onOffOptionSelected() {
//        self.optionsButtonTapped.toggle()
//        self.onGestureEnd()
//        self.selectedOptions[AVMediaCharacteristic.legible] = nil
    }

    private func onOptionsButtonTapped() {
//        self.optionsButtonTapped.toggle()
//        self.onGestureEnd()
    }

    private func onCancelSelected() {
//        self.optionsButtonTapped.toggle()
//        self.onGestureEnd()
    }
}

public extension HLSVideoView {

    // MARK: State
    struct State: Equatable {

        /**
         The asset to be played by the AVPlayer
         */
        public var asset: HLSAsset

        /**
         The status of the AVPlayerItem
         */
        public var playerItemStatus: AVPlayerItem.Status = .unknown

        /**
         Bool flag indicating whether or not the playback overlay is currently being shown
         */
        public var isShowingPlaybackOverlay: Bool = true

        /**
         The state of the overlay controls
         */
        public var overlayState: OverlayView.State = .init()

    }

    // MARK: Actions
    enum Action: Equatable {
        case monitorStatus
        case playerItemStatus(Result<AVPlayerItem.Status, Never>)
        case isUserInteracting(Bool)
        case overlay(OverlayView.Action)

        public static func == (lhs: HLSVideoView.Action, rhs: HLSVideoView.Action) -> Bool {
            switch (lhs, rhs) {
                case (.monitorStatus, .monitorStatus):
                    return true
                case (.playerItemStatus(let lhsValue), .playerItemStatus(let rhsValue)):
                    return lhsValue == rhsValue
                case (.isUserInteracting(let lhsValue), .isUserInteracting(let rhsValue)):
                    return lhsValue == rhsValue
                case (.overlay(let lhsValue), .overlay(let rhsValue)):
                    return lhsValue == rhsValue
                default:
                    return false
            }
        }
    }

    // MARK: Environment
    struct Environment {
        public var mainQueue: AnySchedulerOf<DispatchQueue>
        public var client: AssetClient
    }

    // MARK: Reducer
    static let Reducer = ComposableArchitecture.Reducer<State, Action, Environment>.combine(
        OverlayView.Reducer.pullback(
            state: \.overlayState,
            action: /HLSVideoView.Action.overlay,
            environment: { (_: HLSVideoView.Environment) -> OverlayView.Environment in
                OverlayView.Environment()
            }
        ),
        .init {
            (state: inout State, action: Action, env: Environment) -> Effect<Action, Never> in // swiftlint:disable:this closure_parameter_position
            switch action {
                case .monitorStatus:
                    struct StatusId: Hashable {}
                    return env.client.monitorStatus(state.asset)
                        .receive(on: env.mainQueue)
                        .catchToEffect(Action.playerItemStatus)
                        .cancellable(id: StatusId(), cancelInFlight: true)

                case .playerItemStatus(.success(let status)):
                    state.playerItemStatus = status
                    if status == .readyToPlay {
                        for characteristic in state.asset.characteristics {
                            guard
                                let group = state.asset.group(for: characteristic)
                            else {
                                continue
                            }
                            state.overlayState.groupsByCharacteristic[characteristic] = group

                            if let selectedOption = state.asset.item.currentMediaSelection.selectedMediaOption(in: group) {
                                state.overlayState.selectedOptionsByCharacteristic[characteristic] = HLSAssetOption(
                                    option: selectedOption,
                                    group: group
                                )
                            }
                        }
                    }
                    return .none

                case .isUserInteracting(let isUserInteracting):
                    state.isShowingPlaybackOverlay = isUserInteracting
                    return .none

                case .overlay(let action):
                    return .none
            }
        }
    )
}
