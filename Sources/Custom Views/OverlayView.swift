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

    public var body: some View {
        WithViewStore(self.store) { (viewStore: ViewStore<OverlayView.State, OverlayView.Action>) in
            Color.gray
                .grayscale(0.875)
                .cornerRadius(5.0)
                .overlay {
                    ZStack {
                        HStack(alignment: VerticalAlignment.bottom) {
                            Text(viewStore.isPlaying ? "Pause" : "Play")
                                .frame(width: 150.0, height: 66.0, alignment: .center)
                                .foregroundColor(Color.white)
                                .background(Color.red)
                                .onTapGesture {
                                    viewStore.send(Action.playPauseButtonTapped)
                                }
                                .transition(.scale)
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
                                            
                                        }
                                    )
                                },
                                label: {
                                    Image(systemName: "ellipsis")
                                        .frame(width: 66.0, height: 66.0, alignment: .center)
                                }
                            )
                                .foregroundColor(Color.black)
                                .background(Color.red)
                                .cornerRadius(33.0)
//                                .onTapGesture {
//                                    self.onOptionsButtonTapped()
//                                }
                        }
                    }
                }
        }
    }
}

public extension OverlayView {

    // MARK: State
    struct State: Equatable {

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
                default:
                    return false
            }
        }
    }

    // MARK: Environment
    struct Environment {
//        var player: AVPlayer
    }

    // MARK: Reducer
    static let Reducer = ComposableArchitecture.Reducer<State, Action, Environment> {
        (state: inout State, action: Action, _: Environment) -> Effect<Action, Never> in // swiftlint:disable:this closure_parameter_position
        switch action {
            case .playPauseButtonTapped:
                state.isPlaying.toggle()
                return .none
            case .mediaOptionsButtonTapped:
                state.isShowingMediaOptions.toggle()
                return .none
            case .optionSelected((let characteristic, let option)):
                state.selectedOptionsByCharacteristic[characteristic] = option
                return .none
            case .offSelected(let characteristic):
                state.selectedOptionsByCharacteristic[characteristic] = nil
                return .none
        }
    }

}
