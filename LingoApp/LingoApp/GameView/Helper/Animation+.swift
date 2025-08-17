//
//  Animation+.swift
//  LingoApp
//
//  Created by Zeynep Toy on 17.08.2025.
//

import SwiftUI

extension Animation {
    static func blink(duration: Double = 1.0) -> Animation {
        Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}
