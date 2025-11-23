//
//  PortfolioContextProvider.swift
//  MyFA
//
//  Provides portfolio context to the agent
//

import Foundation
import UIKit
import ConvoUI

@available(iOS 15.0, *)
@MainActor
final class PortfolioContextProvider: NSObject, @preconcurrency ConvoUIContextProvider {
    
    var id: String { "chatkit.portfolio" }
    var title: String { "Portfolio" } // LocalizationHelper.localized("portfolio.title")
    var iconName: String { "chart.pie.fill" } // specific SFSymbol
    var isAvailable: Bool { true }
    var priority: Int { 100 } // High priority
    var maximumAttachmentCount: Int { 1 }
    var shouldUseContainerPanel: Bool { true }
    
    override init() {
        super.init()
    }

    nonisolated func makeContext() async throws -> (any ConvoUIContextItem)? {
        // Interactive mode: return nil to show collector
        return nil
    }

    nonisolated func createCollectorView(onConfirm: @escaping ((any ConvoUIContextItem)?) -> Void) -> UIView? {
        // Create a simple view to confirm attachment
        // In a real app, this might let you select specific accounts
        return PortfolioCollectorView(onConfirm: onConfirm)
    }

    func createDetailView(for item: any ConvoUIContextItem, onDismiss: @escaping () -> Void) -> UIView? {
        guard let portfolioItem = item as? PortfolioContextItem else { return nil }
        return PortfolioDetailView(item: portfolioItem, onDismiss: onDismiss)
    }

    func localizedDescription(for item: any ConvoUIContextItem) -> String {
        return "Current Portfolio"
    }
}

@available(iOS 15.0, *)
struct PortfolioContextItem: ConvoUIContextItem {
    
    struct Payload: Codable {
        let totalValue: Double
        let cashBalance: Double
        let holdings: [HoldingPayload]
        
        struct HoldingPayload: Codable {
            let symbol: String
            let name: String
            let type: String
            let quantity: Double
            let value: Double
        }
    }
    
    let id = UUID()
    let providerId = "chatkit.portfolio"
    let type = "portfolio_snapshot"
    var displayName: String { "My Portfolio" }
    
    let portfolio: Portfolio
    let timestamp: Date
    
    init(portfolio: Portfolio) {
        self.portfolio = portfolio
        self.timestamp = Date()
    }
    
    var codablePayload: Encodable? {
        let wealthService = WealthService.shared // Access mock data
        // Note: In a real app, avoid accessing singleton from item init if possible, or pass data in.
        // Here, for demo simplicity, we calculate values using current mock prices.
        
        let holdingPayloads = portfolio.holdings.map { holding -> Payload.HoldingPayload in
            let price = wealthService.getPrice(assetId: holding.asset.id) ?? 0
            return Payload.HoldingPayload(
                symbol: holding.asset.symbol,
                name: holding.asset.name,
                type: holding.asset.type.rawValue,
                quantity: holding.quantity,
                value: holding.quantity * price
            )
        }
        
        return Payload(
            totalValue: wealthService.getTotalValue(),
            cashBalance: portfolio.cashBalance,
            holdings: holdingPayloads
        )
    }
    
    var encodingRepresentation: ConvoUIEncodingType { .json }
    
    var encodingMetadata: [String: String]? {
        return [
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "itemCount": "\(portfolio.holdings.count)"
        ]
    }
    
    var descriptionTemplates: [ContextDescriptionTemplate] {
        [
            ContextDescriptionTemplate(
                locale: "en",
                template: "Portfolio snapshot with {itemCount} holdings."
            )
        ]
    }
    
    func encodeForTransport() throws -> Data {
        guard let payload = codablePayload as? Payload else { return Data() }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(payload)
    }
    
    func createPreviewView(onRemove: @escaping () -> Void) -> UIView? {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 260, height: 60))
        container.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        container.layer.cornerRadius = 10
        
        let icon = UILabel(frame: CGRect(x: 12, y: 20, width: 24, height: 24))
        icon.text = "💼"
        icon.font = UIFont.systemFont(ofSize: 20)
        container.addSubview(icon)
        
        let titleLabel = UILabel(frame: CGRect(x: 48, y: 8, width: 180, height: 22))
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.text = "My Portfolio"
        container.addSubview(titleLabel)
        
        let detailLabel = UILabel(frame: CGRect(x: 48, y: 30, width: 180, height: 22))
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabel
        // Rough estimate
        detailLabel.text = "\(portfolio.holdings.count) Assets • Cash: $\(Int(portfolio.cashBalance))"
        container.addSubview(detailLabel)
        
        let remove = UIButton(type: .system)
        remove.frame = CGRect(x: 226, y: 18, width: 28, height: 28)
        remove.setTitle("✕", for: .normal)
        remove.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        remove.addAction(UIAction { _ in onRemove() }, for: .touchUpInside)
        container.addSubview(remove)
        
        return container
    }
}

@available(iOS 15.0, *)
class PortfolioCollectorView: UIView {
    var onConfirm: (((any ConvoUIContextItem)?) -> Void)?
    
    init(onConfirm: @escaping ((any ConvoUIContextItem)?) -> Void) {
        self.onConfirm = onConfirm
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        let label = UILabel()
        label.text = "Share your current portfolio with the agent for personalized advice."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        
        let valueLabel = UILabel()
        let total = WealthService.shared.getTotalValue()
        valueLabel.text = String(format: "Total Value: $%.2f", total)
        valueLabel.font = .preferredFont(forTextStyle: .headline)
        valueLabel.textAlignment = .center
        
        let attachButton = UIButton(type: .system)
        attachButton.setTitle("Attach Portfolio", for: .normal)
        attachButton.backgroundColor = .systemBlue
        attachButton.setTitleColor(.white, for: .normal)
        attachButton.layer.cornerRadius = 8
        attachButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        attachButton.addAction(UIAction { [weak self] _ in
            let item = PortfolioContextItem(portfolio: WealthService.shared.portfolio)
            self?.onConfirm?(item)
        }, for: .touchUpInside)
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(attachButton)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 200)
    }
}

@available(iOS 15.0, *)
class PortfolioDetailView: UIView {
    init(item: PortfolioContextItem, onDismiss: @escaping () -> Void) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Portfolio Details Sent"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Tap to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc func dismiss() {
        // onDismiss?() // No callback stored, just a view
    }
}

