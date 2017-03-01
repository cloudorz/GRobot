//
//  RobotManager.swift
//  GRobot
//
//  Created by Cloud Dai on 27/2/2017.
//  Copyright © 2017 Cloud Dai. All rights reserved.
//

import Foundation


private let MaxGroupCount = 200
private let MaxGridAreaCount = 200
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

  func run()
  {
    for _ in 0..<MaxGeneration
    {
      print("The genration: \(generation) is on working.")
      computeFitness()
      print("The results: \(avgScores)")
      print("The best robot: \(theBestRobot)")
      print("The avg score: \(avgScore)")
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
    queue.maxConcurrentOperationCount = 8
    queue.name = "G-Robot"

    var allRobotsScore: [[GridArea.Score]] = Array<[GridArea.Score]>(repeating: [], count: MaxGroupCount)
    for (index, bot) in robots.enumerated()
    {
      queue.addOperation {
        let area = GridArea()
        let scores = (0..<MaxGridAreaCount).map { _ in
          return area.runWithReset(bot)
        }
        OperationQueue.main.addOperation {
          allRobotsScore[index] = scores
        }
      }
    }
    queue.waitUntilAllOperationsAreFinished()

    avgScores = allRobotsScore.map { scores in
      return Float(scores.reduce(0, +)) / Float(MaxGroupCount)
    }
  }

  private func nextGenerationGroup()
  {
    let amendScores = avgScores.map({ $0 + 1000 })
    let sortedPairs = zip(0..<MaxGroupCount, amendScores).sorted { (r1, r2) -> Bool in
      return r1.1 > r2.1
    }
    let sum = Int(ceil(amendScores.reduce(0, +)))

    func randomIndex() -> Int
    {
      let num = random(sum)
      var preScoreSum: Float = 0
      for (index, score) in sortedPairs
      {
        preScoreSum += score
        if preScoreSum >= Float(num)
        {
          return index
        }
      }

      return MaxGroupCount - 1
    }

    var newGroupRobots: [GRobot] = []
    while newGroupRobots.count < MaxGroupCount
    {
      let robotA = robots[randomIndex()]
      let robotB = robots[randomIndex()]
      newGroupRobots.append(contentsOf: robotA.mate(robotB))
    }

    robots = newGroupRobots.map({ $0.mutate() })
    generation += 1
  }

}
