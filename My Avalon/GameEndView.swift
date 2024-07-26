//
//  GameEndView.swift
//  My Avalon
//
//  Created by Seokmin on 7/26/24.
//

import SwiftUI

struct GameEndView: View {
    var players: [Player]
    var onResetGame: () -> Void
    
    var body: some View {
        VStack {
            Text("게임 종료")
                .font(.largeTitle)
            List(players) { player in
                Text("\(player.name): \(player.role?.description ?? "알 수 없음")")
            }
            .padding()
            
            Button("게임 초기화") {
                onResetGame()
            }
            .padding()
        }
    }
}
