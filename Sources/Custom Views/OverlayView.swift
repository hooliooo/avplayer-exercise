//
//  OverlayView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation
import SwiftUI

public struct OverlayView: View {

    // MARK: Stored Properties
    public let asset: HLSAsset
    public var buttonText: String
    public let onPlayPauseButtonTapped: () -> Void
    public let onOptionSelected: ((AVMediaCharacteristic, HLSAssetOption)) -> Void
    public let onOffOptionSelected: () -> Void
    public let onOptionsButtonTapped: () -> Void
    public let onCancelSelected: () -> Void
    @Binding var selectedOptions: [AVMediaCharacteristic: HLSAssetOption]

    public var body: some View {
        Color.gray
            .grayscale(0.875)
            .cornerRadius(5.0)
            .overlay {
                ZStack {
                    HStack(alignment: VerticalAlignment.bottom) {
                        Text(self.buttonText)
                            .frame(width: 150.0, height: 66.0, alignment: .center)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .onTapGesture {
                                self.onPlayPauseButtonTapped()
                            }
                            .transition(.scale)
                        Menu(
                            content: {
                                ForEach(self.asset.characteristics) { characteristic in
                                    Menu(
                                        characteristic.rawValue,
                                        content: {
                                            let group = asset.group(for: characteristic)! // swiftlint:disable:this force_unwrapping
                                            ForEach(group.options) { option in
                                                Button(
                                                    action: {
                                                        self.onOptionSelected(
                                                            (characteristic, HLSAssetOption(option: option, group: group))
                                                        )
                                                    },
                                                    label: {
                                                        VideoOptionView(
                                                            name: option.displayName,
                                                            isSelected: self.selectedOptions[characteristic]?.name == option.displayName
                                                        )
                                                    }
                                                )
                                            }
                                            if characteristic == AVMediaCharacteristic.legible {
                                                Button(
                                                    action: {
                                                        self.onOffOptionSelected()
                                                    },
                                                    label: {
                                                        VideoOptionView(
                                                            name: "Off",
                                                            isSelected: self.selectedOptions[AVMediaCharacteristic.legible] == nil
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
                                        self.onCancelSelected()
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
                            .onTapGesture {
                                self.onOptionsButtonTapped()
                            }
                    }
                }
            }
    }
}
