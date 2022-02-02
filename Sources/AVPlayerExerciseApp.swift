//
//  AVPlayerExerciseApp.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import ComposableArchitecture
import SwiftUI

@main
struct AVPlayerExerciseApp: App {
    var body: some Scene {
        WindowGroup {
            HLSVideoView(
                store: Store<HLSVideoView.State, HLSVideoView.Action>(
                    initialState: HLSVideoView.State(
                        asset: HLSAsset(url: Constants.url)
                    ),
                    reducer: HLSVideoView.Reducer.debug(),
                    environment: HLSVideoView.Environment(
                        mainQueue: AnySchedulerOf<DispatchQueue>.main,
                        client: AssetClient.success
                    )
                )
            )
        }
    }
}
