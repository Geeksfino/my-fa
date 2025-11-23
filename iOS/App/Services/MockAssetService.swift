//
//  MockAssetService.swift
//  MyFA
//
//  Mock data service for assets and account opening
//

import Foundation

class MockAssetService {
    static let shared = MockAssetService()
    
    private init() {}
    
    enum AccountStatus {
        case notOpened
        case inProgress(step: Int)
        case opened
    }
    
    func getAccountStatus() -> AccountStatus {
        // For now, always return not opened
        return .notOpened
    }
    
    func getAccountOpeningSteps() -> [String] {
        return [
            LocalizationHelper.localized("assets.opening.step1"),
            LocalizationHelper.localized("assets.opening.step2"),
            LocalizationHelper.localized("assets.opening.step3")
        ]
    }
}

