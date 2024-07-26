//
//  Mission.swift
//  My Avalon
//
//  Created by Seokmin on 7/26/24.
//

import Foundation

struct Mission: Identifiable {
    let id = UUID()
    let number: Int
    var team: [Player] = []
    var isSuccess: Bool?
    var requiredTeamSize: Int
}
