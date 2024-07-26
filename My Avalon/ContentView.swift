//
//  ContentView.swift
//  My Avalon
//
//  Created by Seokmin on 7/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var playerCount = 5
    @State private var players: [Player] = []
    @State private var rolesAssigned = false
    @State private var gameProgress: GameProgress?
    @State private var currentPlayerIndex = 0
    @State private var isFlipped = false
    @FocusState private var focusedField: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                Stepper(value: $playerCount, in: 5...10) {
                    Text("플레이어 수: \(playerCount)")
                }
                .padding()
                
                Button("플레이어 설정") {
                    setupPlayers()
                }
                .padding()
                
                if !players.isEmpty {
                    if rolesAssigned {
                        CardView(player: players[currentPlayerIndex], isFlipped: $isFlipped)
                            .padding()
                        
                        if currentPlayerIndex < players.count - 1 {
                            Button("다음 플레이어") {
                                withAnimation {
                                    isFlipped = false
                                    currentPlayerIndex += 1
                                }
                            }
                            .padding()
                        } else {
                            if let unwrappedGameProgress = gameProgress {
                                NavigationLink(destination: MissionView(players: players, gameProgress: Binding(get: { unwrappedGameProgress }, set: { gameProgress = $0 }))) {
                                    Text("게임 시작")
                                }
                                .padding()
                            }
                        }
                    } else {
                        List(players.indices, id: \.self) { index in
                            HStack {
                                TextField("이름 입력", text: $players[index].name)
                                    .focused($focusedField, equals: index)
                                    .submitLabel(index < players.count - 1 ? .next : .done)
                                    .onSubmit {
                                        if index < players.count - 1 {
                                            focusedField = index + 1
                                        } else {
                                            focusedField = nil
                                        }
                                    }
                            }
                        }
                        
                        Button("역할 할당") {
                            gameProgress = assignRolesAndQuestSheet(players: &players)
                            rolesAssigned = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("레지스탕스 아발론")
        }
    }
    
    func setupPlayers() {
        players = (1...playerCount).map { Player(name: "플레이어 \($0)") }
        rolesAssigned = false
        currentPlayerIndex = 0
        isFlipped = false
    }
}

func assignRolesAndQuestSheet(players: inout [Player]) -> GameProgress {
    var roles: [Role] = []
    var questSheet: [Int] = []
    var fourthMissionRequiresTwoFails: Bool = false
    
    switch players.count {
    case 5:
        roles = [.merlin, .assassin, .loyalServant, .loyalServant, .minion]
        questSheet = [2, 3, 2, 3, 3]
    case 6:
        roles = [.merlin, .assassin, .loyalServant, .loyalServant, .percival, .morgana]
        questSheet = [2, 3, 4, 3, 4]
    case 7:
        roles = [.merlin, .assassin, .loyalServant, .loyalServant, .percival, .morgana, .minion]
        questSheet = [2, 3, 3, 4, 4]
        fourthMissionRequiresTwoFails = true
    case 8:
        roles = [.merlin, .assassin, .loyalServant, .loyalServant, .loyalServant, .percival, .morgana, .minion]
        questSheet = [3, 4, 4, 5, 5]
        fourthMissionRequiresTwoFails = true
    case 9:
        roles = [.merlin, .assassin, .loyalServant, .loyalServant, .loyalServant, .loyalServant, .percival, .morgana, .mordred]
        questSheet = [3, 4, 4, 5, 5]
        fourthMissionRequiresTwoFails = true
    case 10:
        roles = [.merlin, .assassin, .loyalServant, .loyalServant, .loyalServant, .loyalServant, .percival, .morgana, .mordred, .minion]
        questSheet = [3, 4, 4, 5, 5]
        fourthMissionRequiresTwoFails = true
    default:
        break
    }
    
    roles.shuffle()
    
    for i in 0..<players.count {
        players[i].role = roles[i]
    }
    
    let missions = questSheet.enumerated().map { index, teamSize in
        Mission(number: index + 1, requiredTeamSize: teamSize)
    }
    
    return GameProgress(missions: missions, fourthMissionRequiresTwoFails: fourthMissionRequiresTwoFails)
}

#Preview {
    ContentView()
}
