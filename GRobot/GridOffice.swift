//
//  GridOffice.swift
//  GRobot
//
//  Created by Cloud Dai on 27/2/2017.
//  Copyright © 2017 Cloud Dai. All rights reserved.
//

import Foundation


final class GridArea
{
  typealias RobotEnv = [GridStatus]
  typealias Score = Int
  static let MaxActionSteps = 200
  static let AreaSize = 10

  struct Position
  {
    let i: Int
    let j: Int

    func trunTo(_ direction: Direction) -> Position
    {
      switch direction
      {
      case .center:
        return Position(i: i, j: j)

      case .left:
        return Position(i: i, j: j - 1)

      case .right:
        return Position(i: i, j: j + 1)

      case .down:
        return Position(i: i + 1, j: j)

      case .up:
        return Position(i: i - 1, j: j)
      }
    }

  }

  enum GridType: Int
  {
    case empty
    case can
    case wall
  }

  enum Direction: Int
  {
    case center
    case left
    case right
    case down
    case up

    static let allDirections: [Direction] = [.up, .down, .right, .left, .center]
  }

  struct GridStatus
  {
    let direction: Direction
    let type: GridType
  }

  var grids: [[GridType]]
  var robotPos: Position

  init()
  {
    self.grids = []
    self.robotPos = Position(i: 0, j: 0)

    resetNewArea()
    debugPrint("grids: \(grids)")
  }

  func getGrid(_ pos: Position) -> GridType
  {
    return grids[pos.i][pos.j]
  }

  func resetGrid(_ pos: Position, type: GridType)
  {
    grids[pos.i][pos.j] = type
  }

  func robotEnv(_ pos: Position) -> RobotEnv
  {
    let statuses = Direction.allDirections.map { direction -> GridStatus in
      let type = getGrid(pos.trunTo(direction))
      return GridStatus(direction: direction, type: type)
    }

    return statuses
  }

  func moveTo(_ direction: Direction) -> Score
  {
    let newPos = robotPos.trunTo(direction)
    let newPosStatus = getGrid(newPos)
    if newPosStatus == .wall
    {
      debugPrint("pos: \(newPos), sunk with wall, get -5 score.")
      return -5
    }
    else
    {
      debugPrint("pos: \(newPos), move to \(direction)")
      robotPos = newPos
      return 0
    }
  }

  func pickUp() -> Score
  {
    let status = getGrid(robotPos)
    if status == .can
    {
      debugPrint("pos: \(robotPos), pick up one can, get 10 score")
      resetGrid(robotPos, type: .empty)
      return 10
    }
    else
    {
      debugPrint("pos: \(robotPos), try to pick up one can, get -1 score")
      return -1
    }
  }

  func resetNewArea()
  {
    var grids: [[GridType]] = Array<[GridType]>(repeating: Array<GridType>(repeating: .empty, count: GridArea.AreaSize + 2), count: GridArea.AreaSize + 2)
    for i in 0..<grids.count
    {
      for j in 0..<grids[i].count
      {
        if i == 0 || i == 11 || j == 0 || j == 11
        {
          grids[i][j] = .wall
        }
        else
        {
          grids[i][j] = drand48() < 0.5 ? .can : .empty
        }
      }
    }

    self.grids = grids
    self.robotPos = Position(i: 1, j: 1)
  }

  func runWithReset(_ bot: GRobot) -> Score
  {
    resetNewArea()
    return run(bot)
  }

  func doNext(_ action: GRobot.Action) -> Score
  {
    switch action
    {
    case .up:
      return moveTo(.up)

    case .down:
      return moveTo(.down)

    case .left:
      return moveTo(.left)

    case .right:
      return moveTo(.right)

    case .pickUp:
      return pickUp()

    case .none:
      return 0

    case .randomMove:
      return doNext(GRobot.Action.randomMoveAction)
    }
  }

  func run(_ bot: GRobot) -> Score
  {


    return (0..<GridArea.MaxActionSteps).reduce(0) { (total, _) in
      return total + doNext(bot.action(robotEnv(robotPos)))
    }
  }

}
