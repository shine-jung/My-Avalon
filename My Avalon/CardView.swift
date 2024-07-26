//
//  CardView.swift
//  My Avalon
//
//  Created by Seokmin on 7/26/24.
//

import SwiftUI

struct CardView: View {
    let player: Player
    @Binding var isFlipped: Bool
    
    var body: some View {
        ZStack {
            if isFlipped {
                ZStack {
                    Image(player.role?.description ?? "없음")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    Text(player.role?.description ?? "없음")
                        .font(.title)
                        .bold()
                }
                .frame(width: 200, height: 300)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .scaleEffect(x: -1, y: 1)
            } else {
                VStack {
                    Text(player.name)
                        .bold()
                    Text("\n터치해서 카드를 뒤집으세용")
                }
                .frame(width: 200, height: 300)
                .foregroundColor(Color.white)
                .background(Color.gray)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
        .rotation3DEffect(
            Angle(degrees: isFlipped ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .animation(.default)
        .onTapGesture {
            withAnimation {
                isFlipped.toggle()
            }
        }
    }
}
