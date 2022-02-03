//
//  OverlayView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation
import ComposableArchitecture
import SwiftUI

// swiftlint:disable pattern_matching_keywords
public struct OverlayView: View {

    // MARK: Stored Properies
    public let store: Store<State, Action>

    private let controlSize: CGSize = CGSize(width: 44.0, height: 44.0)

    // MARK: Computed Properties
    private var cornerRadius: CGFloat {
        return self.controlSize.height / 2.0
    }

    public var body: some View {
        WithViewStore(self.store) { (viewStore: ViewStore<OverlayView.State, OverlayView.Action>) in
            Color.gray
                .grayscale(0.875)
                .cornerRadius(5.0)
                .overlay {
                    ZStack {
                        VStack(alignment: HorizontalAlignment.center, spacing: 0.0) {
                            PlaybackProgressView(
                                currentProgress: viewStore.binding(
                                    get: \.current,
                                    send: Action.updateProgress
                                ),
                                seekProgress: viewStore.binding(
                                    get: \.seekProgress,
                                    send: Action.seek
                                ),
                                end: viewStore.end
                            )
                            HStack(alignment: VerticalAlignment.bottom) {
                                Button(
                                    action: {
                                        viewStore.send(Action.seek(max(viewStore.current - 15.0, 0.0)))
                                    },
                                    label: {
                                        Image(systemName: "gobackward.15")
                                    }
                                )
                                    .playbackStyling(size: self.controlSize, cornerRadius: self.cornerRadius)
                                Button(
                                    action: {
                                        viewStore.send(Action.playPauseButtonTapped)
                                    },
                                    label: {
                                        Image(systemName: viewStore.state.isPlaying ? "pause.fill" : "play.fill")
                                    }
                                )
                                    .playbackStyling(size: self.controlSize, cornerRadius: self.cornerRadius)
                                Button(
                                    action: {
                                        viewStore.send(Action.seek(min(viewStore.current + 15.0, viewStore.end)))
                                    },
                                    label: {
                                        Image(systemName: "goforward.15")
                                    }
                                )
                                    .playbackStyling(size: self.controlSize, cornerRadius: self.cornerRadius)
                                Menu(
                                    content: {
                                        ForEach(viewStore.characteristics) { (characteristic: AVMediaCharacteristic) in
                                            Menu(
                                                characteristic.rawValue,
                                                content: {
                                                    let group: AVMediaSelectionGroup = viewStore
                                                        .groupsByCharacteristic[characteristic]! // swiftlint:disable:this force_unwrapping
                                                    ForEach(group.options) { (option: AVMediaSelectionOption) in
                                                        Button(
                                                            action: {
                                                                viewStore.send(
                                                                    OverlayView.Action.optionSelected(
                                                                        (characteristic, HLSAssetOption(option: option, group: group))
                                                                    )
                                                                )
                                                            },
                                                            label: {
                                                                let name = viewStore.selectedOptionsByCharacteristic[characteristic]??.name

                                                                VideoOptionView(
                                                                    name: option.displayName,
                                                                    isSelected: name == option.displayName
                                                                )
                                                            }
                                                        )
                                                    }
                                                    if characteristic == AVMediaCharacteristic.legible {
                                                        Button(
                                                            action: {
                                                                viewStore.send(Action.offSelected(characteristic))
                                                            },
                                                            label: {
                                                                let isSelected: Bool = viewStore
                                                                    .selectedOptionsByCharacteristic[AVMediaCharacteristic.legible] == nil
                                                                VideoOptionView(
                                                                    name: "Off",
                                                                    isSelected: isSelected
                                                                )
                                                            }
                                                        )
                                                    } else {
                                                        EmptyView()
                                                    }
                                                }
                                            )
                                        }
                                        Button(
                                            "Cancel",
                                            action: {
                                                viewStore.send(Action.cancelSelected)
                                            }
                                        )
                                    },
                                    label: {
                                        Image(systemName: "ellipsis")
                                            .frame(width: 44.0, height: 44.0, alignment: .center)
                                    }
                                )
                                    .foregroundColor(Color.black)
                                    .background(Color.red)
                                    .cornerRadius(self.cornerRadius)
                                    .onTapGesture {
                                        viewStore.send(Action.mediaOptionsButtonTapped)
                                    }
                                    .padding(.trailing, 15.0)
                            }
                            .padding(.bottom, 10.0)
                        }

                    }
                }
        }
    }
}

public extension OverlayView {

    // MARK: State
    struct State: Equatable {

        public weak var player: AVPlayer?

        /**
         Bool flag indicating whether or not the AVPlayer is playing
         */
        public var isPlaying: Bool = false

        /**
         Bool flag indicating where or not the user is browsing the audio/subtitle options
         */
        public var isShowingMediaOptions: Bool = false

        /**
         The groups associated with each characteristic of the asset
         */
        public var groupsByCharacteristic: [AVMediaCharacteristic: AVMediaSelectionGroup] = [:]

        /**
         The selected options of the video's audio and subtitles
         */
        public var selectedOptionsByCharacteristic: [AVMediaCharacteristic: HLSAssetOption?] = [:]

        /**
         Current time in the HLS stream
         */
        public var current: Double = 0.0

        /**
         The end time of the HLS
         */
        public var end: Double = 0.0

        public var seekProgress: Double?

        // MARK: Computed Properties
        public var characteristics: [AVMediaCharacteristic] {
            return groupsByCharacteristic.keys.sorted { $0.rawValue < $1.rawValue }
        }
    }

    // MARK: Actions
    enum Action: Equatable {
        case playPauseButtonTapped
        case mediaOptionsButtonTapped
        case optionSelected((AVMediaCharacteristic, HLSAssetOption))
        case offSelected(AVMediaCharacteristic)
        case cancelSelected
        case monitorProgress
        case newProgress(Result<TimeInterval, Never>)
        case updateProgress(TimeInterval)
        case seek(TimeInterval?)

        public static func == (lhs: OverlayView.Action, rhs: OverlayView.Action) -> Bool {
            switch (lhs, rhs) {
                case (.playPauseButtonTapped, .playPauseButtonTapped):
                    return true
                case (.mediaOptionsButtonTapped, .mediaOptionsButtonTapped):
                    return true
                case (.optionSelected(let lhsValue), .optionSelected(let rhsValue)):
                    return lhsValue.0 == rhsValue.0 && lhsValue.1 == rhsValue.1
                case (.offSelected(let lhsValue), .offSelected(let rhsValue)):
                    return lhsValue == rhsValue
                case (.cancelSelected, .cancelSelected):
                    return true
                case (.monitorProgress, .monitorProgress):
                    return true
                case (.newProgress(let lhsValue), .newProgress(let rhsValue)):
                    return lhsValue == rhsValue
                case (.updateProgress(let lhsValue), .updateProgress(let rhsValue)):
                    return lhsValue == rhsValue
                case (.seek(let lhsValue), .seek(let rhsValue)):
                    return lhsValue == rhsValue
                default:
                    return false
            }
        }
    }

    // MARK: Environment
    struct Environment {
        public var mainQueue: AnySchedulerOf<DispatchQueue>
        public var monitorProgress: (AVPlayer) -> Effect<TimeInterval, Never>
        public var seekProgress: (AVPlayer, TimeInterval) -> Effect<TimeInterval, Never>
    }

    // MARK: Reducer
    static let Reducer = ComposableArchitecture.Reducer<State, Action, Environment> {
        (state: inout State, action: Action, env: Environment) -> Effect<Action, Never> in // swiftlint:disable:this closure_parameter_position
        struct MonitorId: Hashable {}
        switch action {
            case .playPauseButtonTapped:
                state.isPlaying.toggle()
                return Effect(value: Action.monitorProgress)
            case .mediaOptionsButtonTapped:
                state.isShowingMediaOptions.toggle()
                return .none
            case .optionSelected((let characteristic, let option)):
                state.selectedOptionsByCharacteristic[characteristic] = option
                return .none
            case .offSelected(let characteristic):
                state.selectedOptionsByCharacteristic[characteristic] = nil
                return .none
            case .cancelSelected:
                return .none
            case .monitorProgress:
                if let player = state.player {
                    return env.monitorProgress(player)
                        .receive(on: env.mainQueue)
                        .catchToEffect(Action.newProgress)
                        .cancellable(id: MonitorId())
                } else {
                    return .none
                }
            case .newProgress(.success(let current)):
                return Effect(value: Action.updateProgress(current))
            case .updateProgress(let current):
                state.current = current
                return .none
            case .seek(let seekProgress):
                state.seekProgress = seekProgress
                if let player = state.player, let seekProgress = seekProgress {
                    return env.seekProgress(player, seekProgress)
                        .receive(on: env.mainQueue)
                        .catchToEffect(Action.newProgress)
                        .cancellable(id: MonitorId())
                } else {
                    return .none
                }
        }
    }

}
