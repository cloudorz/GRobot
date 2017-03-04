//
//  RobotManager.swift
//  GRobot
//
//  Created by Cloud Dai on 27/2/2017.
//  Copyright © 2017 Cloud Dai. All rights reserved.
//

import Foundation


private let MaxGroupCount = 200
private let MaxGridAreaCount = 100
private let MaxGeneration = 1000

final class RobotManager
{
  var robots: [GRobot]
  var avgScores: [Float] = Array(repeating: 0, count: MaxGroupCount)
  var generation: Int = 1

  init()
  {
    robots = (0..<MaxGroupCount).map { _ in
      return GRobot()
    }
  }

  func run(async: Bool = true)
  {
    for _ in 0..<MaxGeneration
    {
      print("The genration: \(generation) is on working.")
      print(Date().timeIntervalSinceReferenceDate)
      if async
      {
        asyncComputeFitness()
      }
      else
      {
        computeFitness()
      }
      print(Date().timeIntervalSinceReferenceDate)
//      print("The results: \(avgScores)")
      print("The best robot: \(theBestRobot)")
      print("The worst robot: \(theWorstRobot)")
      print("The avg score: \(avgScore)")
      print("==========================")
      print("Evoluation is coming...")
      nextGenerationGroup()
      print("The genration: \(generation) be born.")
    }
  }

  var theBestRobot: (GRobot, Float) {
    return zip(robots, avgScores).max { (bot1, bot2) -> Bool in
      return bot1.1 < bot2.1
    } ?? (robots[0], avgScores[0])
  }

  var theWorstRobot: (GRobot, Float) {
    return zip(robots, avgScores).max { (bot1, bot2) -> Bool in
      return bot1.1 > bot2.1
      } ?? (robots[0], avgScores[0])
  }

  var avgScore: Float {
    return avgScores.reduce(0, +) / Float(avgScores.count)
  }

  // fitness via index map to robots
  private func computeFitness()
  {
    let area = GridArea()
    let allRobotsScore: [[GridArea.Score]] = robots.map { bot in
      return (0..<MaxGridAreaCount).map { _ in
        return area.runWithReset(bot)
      }
    }

    avgScores = allRobotsScore.map { scores in
      return Float(scores.reduce(0, +)) / Float(MaxGroupCount)
    }
  }

  private func asyncComputeFitness()
  {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 4
    queue.name = "G-Robot"

    var avgScores = Array<Float>(repeating: 0, count: MaxGroupCount)
    for (index, bot) in robots.enumerated()
    {
      queue.addOperation {
        let area = GridArea()
        let scores = (0..<MaxGridAreaCount).map { _ in
          return area.runWithReset(bot)
        }
        avgScores[index] = Float(scores.reduce(0, +)) / Float(scores.count)
      }
    }
    queue.waitUntilAllOperationsAreFinished()

    self.avgScores = avgScores
  }

  private func nextGenerationGroup()
  {
//    let amendScores = avgScores.map({ $0 + 1100 })
//    var sortedPairs = Array(zip(0..<MaxGroupCount, amendScores))
//    let sum = sortedPairs.reduce(0, { $0 + $1.1 })
//    let percentPairs = sortedPairs.map({ (index, score) in
//      return (index, score / sum)
//    })
//
//    func randomIndex() -> Int
//    {
//      let num = Float(drand48())
//      var preScoreSum: Float = 0
//      for (index, score) in percentPairs
//      {
//        preScoreSum += score
//        if preScoreSum >= num
//        {
//          return index
//        }
//      }
//
//      return MaxGroupCount - 1
//    }

    let _avgScores = avgScores
    func randomIndex() -> Int
    {
      if let (index, _) = (0..<3).map({ _ -> (Int, Float) in
        let index = random(_avgScores.count)
        let score = _avgScores[index]

        return (index, score)
      }).max(by: { (i1, i2) -> Bool in
        return i1.1 < i2.1
      })
        {
          return index
      }

      return 0
    }

    var newGroupRobots: [GRobot] = []
    let oldRobots = robots
    while newGroupRobots.count < MaxGroupCount
    {
      let robotA = oldRobots[randomIndex()]
      let robotB = oldRobots[randomIndex()]
      newGroupRobots.append(contentsOf: robotA.mate(robotB))
    }

    robots = newGroupRobots.map({ $0.mutate() })
    generation += 1
  }

}
