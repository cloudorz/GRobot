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
      return Action(rawValue: random(7)) ?? .none
    }

    static var randomMoveAction: Action {
      let moves: [Action] = [.up, .down, .left, .right]
      return moves[random(moves.count)]
    }

  }

  private var actions: [Action]

  init()
  {
    actions = (0..<243).map { _ in
      return Action.randomAction
    }
  }

  init(actions: [Action])
  {
    self.actions = actions
  }

  private func robotEnvToActionIndex(_ env: GridArea.RobotEnv) -> Int
  {
    return env.reduce(0) { (total, pair) in
      return total + pair.type.rawValue * powInt(3, pair.direction.rawValue)
    }
  }

  func action(_ env: GridArea.RobotEnv) -> Action
  {
    let index = robotEnvToActionIndex(env)
    return actions[index]
  }

  func mate(_ other: GRobot) -> [GRobot]
  {
    let matingIndex = random(actions.count)
    let (headA, tailA) = (actions[0..<matingIndex], actions[matingIndex..<actions.count])
    let (headB, tailB) = (other.actions[0..<matingIndex], other.actions[matingIndex..<other.actions.count])

    let childAlice = GRobot(actions: Array(headA) + Array(tailB))
    let childBob = GRobot(actions: Array(headB) + Array(tailA))

    return [childAlice, childBob]
  }

  mutating func mutate()
  {
    func change(times: Int)
    {
      for _ in 0..<times
      {
        let mutatingIndex = random(actions.count)
        actions[mutatingIndex] = Action.randomAction
      }
    }

    if random(100) < 5
    {
      change(times: 2)
    }
  }

}
