//
//  Strategy.swift
//  MyFA
//
//  Investment strategy model
//

import Foundation

struct Strategy: Identifiable {
    let id: String
    let title: String
    let description: String
    let creator: Creator
    let performance: Performance
    let tags: [Tag]
    let engagement: Engagement
    let historicalData: [PerformanceDataPoint]
    
    struct Creator {
        let name: String
        let avatarColor: String // Hex color for avatar background
        let role: String
    }
    
    struct Performance {
        let annualReturn: Double // percentage
        let maxDrawdown: Double // percentage
        let sharpeRatio: Double
        let winRate: Double // percentage (0-100)
    }
    
    struct Tag {
        let text: String
        let type: TagType
        
        enum TagType {
            case risk
            case term
            case asset
        }
    }
    
    struct Engagement {
        let likes: Int
        let comments: Int
        let followers: Int
        let recentFollowers: Int // followers in last 7 days
    }
    
    struct PerformanceDataPoint {
        let month: String
        let returnPercentage: Double // Can be negative
    }
}

