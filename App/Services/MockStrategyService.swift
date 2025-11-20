//
//  MockStrategyService.swift
//  MyFA
//
//  Mock data service for strategies
//

import Foundation

class MockStrategyService {
    static let shared = MockStrategyService()
    
    private init() {}
    
    func getStrategies() -> [Strategy] {
        return [
            Strategy(
                id: "strategy-1",
                title: "三次抄底失败之后，我换成这套\"慢半拍\"策略",
                description: "2023年初我经历了三次失败的抄底，每次都以为是底部结果还能跌。后来我改变策略，不再试图抓住最低点，而是等市场企稳后再进场。这个策略让我在2023-2024年稳定获得了68%的收益，最大回撤控制在12%以内。",
                creator: Strategy.Creator(
                    name: "稳健投资者",
                    avatarColor: "#6B5CE7",
                    role: "策略创建者"
                ),
                performance: Strategy.Performance(
                    annualReturn: 23.8,
                    maxDrawdown: -12.3,
                    sharpeRatio: 1.65,
                    winRate: 68.0
                ),
                tags: [
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.risk.medium"), type: .risk),
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.term.medium"), type: .term),
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.type.etf.stock"), type: .asset)
                ],
                engagement: Strategy.Engagement(
                    likes: 1247,
                    comments: 89,
                    followers: 2136,
                    recentFollowers: 183
                ),
                historicalData: generateHistoricalData(
                    startMonth: "2023.05",
                    months: 18,
                    pattern: [
                        -8, -5, 3, 5, 4, 6, 8, 7, 10, 12, 11, 14, 16, 15, 18, 20, 22, 24
                    ]
                )
            ),
            Strategy(
                id: "strategy-2",
                title: "只在极端恐慌时出手的宽基ETF策略",
                description: "我的投资哲学很简单：别人恐慌时我贪婪。这个策略只做一件事，就是等待市场恐慌指数达到极值时分批买入宽基ETF。2022年11月开始执行，至今收益45%，期间几乎不需要操作，适合上班族。",
                creator: Strategy.Creator(
                    name: "佛系投资人",
                    avatarColor: "#5B9FD7",
                    role: "策略创建者"
                ),
                performance: Strategy.Performance(
                    annualReturn: 18.5,
                    maxDrawdown: -8.7,
                    sharpeRatio: 2.1,
                    winRate: 72.0
                ),
                tags: [
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.risk.low"), type: .risk),
                    Strategy.Tag(text: LocalizationHelper.localized("strategies.term.long"), type: .term),
                    Strategy.Tag(text: "ETF", type: .asset)
                ],
                engagement: Strategy.Engagement(
                    likes: 892,
                    comments: 56,
                    followers: 1543,
                    recentFollowers: 94
                ),
                historicalData: generateHistoricalData(
                    startMonth: "2022.11",
                    months: 25,
                    pattern: Array(stride(from: 0.0, to: 45.0, by: 2.0))
                )
            )
        ]
    }
    
    private func generateHistoricalData(startMonth: String, months: Int, pattern: [Double]) -> [Strategy.PerformanceDataPoint] {
        var data: [Strategy.PerformanceDataPoint] = []
        
        let components = startMonth.split(separator: ".")
        guard let year = Int(components[0]), let month = Int(components[1]) else {
            return []
        }
        
        for i in 0..<min(months, pattern.count) {
            let currentMonth = month + i
            let currentYear = year + (currentMonth - 1) / 12
            let adjustedMonth = ((currentMonth - 1) % 12) + 1
            
            let monthString = String(format: "%04d.%02d", currentYear, adjustedMonth)
            data.append(Strategy.PerformanceDataPoint(
                month: monthString,
                returnPercentage: pattern[i]
            ))
        }
        
        return data
    }
}

