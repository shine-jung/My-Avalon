//
//  Player.swift
//  My Avalon
//
//  Created by Seokmin on 7/26/24.
//

import Foundation

struct Player: Identifiable {
    let id = UUID()
    var name: String
    var role: Role?
}

enum Role: String {
    case merlin = "Merlin"
    case percival = "Percival"
    case loyalServant = "Loyal Servant"
    case assassin = "Assassin"
    case morgana = "Morgana"
    case mordred = "Mordred"
    case minion = "Minion"
    
    var description: String {
        switch self {
        case .merlin:
            return "멀린"
        case .percival:
            return "퍼시벌"
        case .loyalServant:
            return "충신"
        case .assassin:
            return "암살자"
        case .morgana:
            return "모르가나"
        case .mordred:
            return "모드레드"
        case .minion:
            return "악의 하수인"
        }
    }
}
