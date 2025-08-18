//
//  JokersExplanationView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct JokersExplanationView: View {
    var body: some View {
        VStack(spacing: 15) {
            ForEach(JokerType.allCases, id: \.self) { jokerType in
                JokerExplanationRow(jokerType: jokerType)
            }
        }
    }
}
