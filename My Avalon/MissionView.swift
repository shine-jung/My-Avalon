//
//  MissionView.swift
//  My Avalon
//
//  Created by Seokmin on 7/26/24.
//

import SwiftUI

struct MissionView: View {
    @Binding var gameProgress: GameProgress
    @State private var mission: Mission
    @State private var votes: [Bool]
    @State private var selectedPlayers: [Player] = []
    @State private var isSelectingPlayers = true
    @State private var questResults: [Bool] = []
    @State private var currentQuestPlayerIndex = 0
    @State private var opposeCount = 0
    @State private var showOpposeAlert = false
    @State private var showGameEndAlert = false
    @State private var showRoles = false
    @State private var navigateToEndView = false
    @State private var players: [Player]
    @State private var selectedQuestCard: Bool? = nil
    @State private var showResults = false
    
    init(players: [Player], gameProgress: Binding<GameProgress>) {
        self._players = State(initialValue: players)
        self._gameProgress = gameProgress
        self._mission = State(initialValue: gameProgress.wrappedValue.missions.first!)
        self._votes = State(initialValue: [Bool](repeating: false, count: players.count))
    }
    
    var body: some View {
        VStack {
            Text("원정 \(mission.number)")
                .font(.largeTitle)
                .padding()
            
            QuestSheetView(missions: gameProgress.missions, fourthMissionRequiresTwoFails: gameProgress.fourthMissionRequiresTwoFails)
                .padding()
            
            HStack {
                Spacer()
                Button(action: {
                    self.showOpposeAlert = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 50, height: 50)
                        Text("\(opposeCount)")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                .alert(isPresented: $showOpposeAlert) {
                    Alert(
                        title: Text("원정 반대"),
                        message: Text("원정을 반대하시겠습니까?"),
                        primaryButton: .default(Text("확인")) {
                            self.opposeCount += 1
                            if self.opposeCount >= 5 {
                                self.showGameEndAlert = true
                            }
                        },
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
                .padding()
            }
            
            Spacer()
            
            if isSelectingPlayers {
                List(players) { player in
                    Button(action: {
                        togglePlayerSelection(player: player)
                    }) {
                        HStack {
                            Text(player.name)
                            if selectedPlayers.contains(where: { $0.id == player.id }) {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                .frame(maxHeight: 300)
                Button("선택 완료") {
                    if selectedPlayers.count == mission.requiredTeamSize {
                        startQuest()
                    }
                }
                .padding()
            } else if currentQuestPlayerIndex < mission.team.count {
                VStack {
                    Text("\(mission.team[currentQuestPlayerIndex].name)의 차례")
                    HStack {
                        Button("성공") {
                            selectedQuestCard = true
                        }
                        .padding()
                        .background(selectedQuestCard == true ? .green : .gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("실패") {
                            selectedQuestCard = false
                        }
                        .padding()
                        .background(selectedQuestCard == false ? .red : .gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    Button("다음 플레이어") {
                        if let selectedCard = selectedQuestCard {
                            questResults[currentQuestPlayerIndex] = selectedCard
                            currentQuestPlayerIndex += 1
                            selectedQuestCard = nil
                        }
                    }
                    .padding()
                    .disabled(selectedQuestCard == nil)
                }
            } else {
                if !questResults.isEmpty {
                    if showResults {
                        let successCount = questResults.filter { $0 }.count
                        let failCount = questResults.filter { !$0 }.count
                        
                        Text("원정 결과: 성공 \(successCount)명, 실패 \(failCount)명")
                            .onAppear {
                                processQuestResults()
                            }
                    } else {
                        Button("결과 보기") {
                            showResults = true
                        }
                        .padding()
                    }
                }
                
                if gameProgress.missions.filter({ $0.isSuccess == true }).count >= 3 {
                    Button("게임 종료") {
                        self.showGameEndAlert = true
                    }
                    .padding()
                    .alert(isPresented: $showGameEndAlert) {
                        return Alert(
                            title: Text("게임 종료"),
                            message: Text("게임 종료 버튼을 누르면 역할이 공개됩니다. 그래도 진행하시겠습니까?"),
                            primaryButton: .default(Text("확인")) {
                                self.navigateToEndView = true
                            },
                            secondaryButton: .cancel(Text("취소"))
                        )
                    }
                } else if gameProgress.missions.filter({ $0.isSuccess == false }).count >= 3 || opposeCount >= 5 {
                    Button("게임 종료") {
                        self.navigateToEndView = true
                    }
                    .padding()
                } else if showResults {
                    Button("다음 원정") {
                        nextMission()
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            NavigationLink(destination: GameEndView(players: players, onResetGame: {
                resetGame(&gameProgress, &mission, &votes, &selectedPlayers, &isSelectingPlayers, &questResults, &currentQuestPlayerIndex, &opposeCount, &showOpposeAlert, &showGameEndAlert, &showRoles, &navigateToEndView, &players)
            }), isActive: $navigateToEndView) {
                EmptyView()
            }
        }
    }
    
    func togglePlayerSelection(player: Player) {
        if selectedPlayers.contains(where: { $0.id == player.id }) {
            selectedPlayers.removeAll { $0.id == player.id }
        } else if selectedPlayers.count < mission.requiredTeamSize {
            selectedPlayers.append(player)
        }
    }
    
    func startQuest() {
        mission.team = selectedPlayers
        questResults = [Bool](repeating: false, count: mission.team.count)
        isSelectingPlayers = false
    }
    
    func nextMission() {
        if let currentIndex = gameProgress.missions.firstIndex(where: { $0.id == mission.id }) {
            let nextIndex = currentIndex + 1
            if nextIndex < gameProgress.missions.count {
                mission = gameProgress.missions[nextIndex]
                isSelectingPlayers = true
                selectedPlayers = []
                questResults = []
                currentQuestPlayerIndex = 0
                showResults = false
            }
        }
    }
    
    func updateMissionResult(mission: Mission, isSuccess: Bool) {
        if let index = gameProgress.missions.firstIndex(where: { $0.id == mission.id }) {
            gameProgress.missions[index].isSuccess = isSuccess
        }
    }
    
    func evaluateMissionResult(failCount: Int, missionNumber: Int, requiresTwoFails: Bool) -> Bool {
        if requiresTwoFails && missionNumber == 4 {
            return failCount < 2
        } else {
            return failCount == 0
        }
    }
    
    func processQuestResults() {
        let failCount = questResults.filter { !$0 }.count
        let isMissionSuccess = evaluateMissionResult(failCount: failCount, missionNumber: mission.number, requiresTwoFails: gameProgress.fourthMissionRequiresTwoFails)
        mission.isSuccess = isMissionSuccess
        updateMissionResult(mission: mission, isSuccess: isMissionSuccess)
    }
}

func resetGame(_ gameProgress: inout GameProgress, _ mission: inout Mission, _ votes: inout [Bool], _ selectedPlayers: inout [Player], _ isSelectingPlayers: inout Bool, _ questResults: inout [Bool], _ currentQuestPlayerIndex: inout Int, _ opposeCount: inout Int, _ showOpposeAlert: inout Bool, _ showGameEndAlert: inout Bool, _ showRoles: inout Bool, _ navigateToEndView: inout Bool, _ players: inout [Player]) {
    gameProgress = assignRolesAndQuestSheet(players: &players)
    mission = gameProgress.missions.first!
    votes = [Bool](repeating: false, count: players.count)
    selectedPlayers = []
    isSelectingPlayers = true
    questResults = []
    currentQuestPlayerIndex = 0
    opposeCount = 0
    showOpposeAlert = false
    showGameEndAlert = false
    showRoles = false
    navigateToEndView = false
}
