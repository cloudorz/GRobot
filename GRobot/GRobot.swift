//
//  GRobot.swift
//  GRobot
//
//  Created by Cloud Dai on 27/2/2017.
//  Copyright © 2017 Cloud Dai. All rights reserved.
//

import Foundation


struct GRobot
{
  enum Action: Int
  {
    case up
    case down
    case left
    case right
    case none
    case pickUp
    case randomMove

    static var randomAction: Action {
      return Action(rawValue: Int(arc4random_uniform(7))) ?? .none
    }

    static var randomMoveAction: Action {
      let moves: [Action] = [.up, .down, .left, .right]
      return moves[Int(arc4random_uniform(UInt32(moves.count)))]
    }

  }

  private var actions: [Action]

  init()
  {
    actions = (0..<243).map { _ in
      return Action.randomAction
    }
  }

  private func robotEnvToActionIndex(_ env: GridArea.RobotEnv) -> Int
  {
    return env.reduce(0) { (total, pair) in
      return total + pair.type.rawValue * Int(powf(3, Float(pair.direction.rawValue)))
    }
  }

  func action(_ env: GridArea.RobotEnv) -> Action
  {
    let index = robotEnvToActionIndex(env)
    return actions[index]
  }

  // TODO: 交配
  // TODO: 突变
}
