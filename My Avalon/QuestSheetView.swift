//
//  QuestSheetView.swift
//  My Avalon
//
//  Created by Seokmin on 7/26/24.
//

import SwiftUI

struct QuestSheetView: View {
    var missions: [Mission]
    var fourthMissionRequiresTwoFails: Bool
    
    var body: some View {
        HStack {
            ForEach(0..<missions.count, id: \.self) { index in
                let mission = missions[index]
                ZStack {
                    Circle()
                        .fill(missionColor(mission: mission, index: index))
                        .frame(width: 50, height: 50)
                    if mission.isSuccess == nil {
                        if fourthMissionRequiresTwoFails && index == 3 {
                            Text("\(mission.requiredTeamSize)(2)")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("\(mission.requiredTeamSize)")
                                .foregroundColor(.white)
                        }
                    } else {
                        Text(mission.isSuccess! ? "성공" : "실패")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    func missionColor(mission: Mission, index: Int) -> Color {
        if let isSuccess = mission.isSuccess {
            return isSuccess ? .good : .evil
        } else {
            return .silver
        }
    }
}
