//
//  PlayerModel.swift
//  Codenames
//
//  Created by Tyler Martin on 5/18/22.
//  Copyright © 2022 Tyler Martin. All rights reserved.
//

import Foundation

struct PlayerModel : Codable {
    var name: String
    var team: Team
    var role: Role?
}
