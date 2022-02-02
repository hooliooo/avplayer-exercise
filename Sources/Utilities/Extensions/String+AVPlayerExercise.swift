//
//  String+AVPlayerExercise.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 02.02.22.
//

import Foundation

extension String: Identifiable {
    public var id: Int {
        return self.hashValue
    }
}
