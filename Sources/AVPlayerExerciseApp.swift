//
//  AVPlayerExerciseApp.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation
import ComposableArchitecture
import SwiftUI

@main
struct AVPlayerExerciseApp: App {
    var body: some Scene {

        let asset = HLSAsset(url: Constants.url)

        WindowGroup {
            HLSVideoView(
                store: Store<HLSVideoView.State, HLSVideoView.Action>(
                    initialState: HLSVideoView.State(
                        asset: asset,
                        player: AVPlayer(playerItem: asset.item)
                    ),
                    reducer: HLSVideoView.Reducer.debug(),
                    environment: HLSVideoView.Environment(
                        mainQueue: AnySchedulerOf<DispatchQueue>.main,
                        client: AssetClient.live
                    )
                )
            )
        }
    }
}
