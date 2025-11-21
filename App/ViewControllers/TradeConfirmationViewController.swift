//
//  TradeConfirmationViewController.swift
//  MyFA
//
//  Confirms a trade suggested by the agent
//

import UIKit

class TradeConfirmationViewController: UIViewController {
    
    private let assetId: String
    private let symbol: String
    private let type: TransactionType
    private let quantity: Double
    private let price: Double
    
    private let wealthService = WealthService.shared
    
    init(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        self.assetId = queryItems.first(where: { $0.name == "assetId" })?.value ?? ""
        self.symbol = queryItems.first(where: { $0.name == "symbol" })?.value ?? "UNKNOWN"
        let typeString = queryItems.first(where: { $0.name == "type" })?.value ?? "buy"
        self.type = TransactionType(rawValue: typeString) ?? .buy
        self.quantity = Double(queryItems.first(where: { $0.name == "quantity" })?.value ?? "0") ?? 0
        
        // Fetch current price
        self.price = WealthService.shared.getPrice(assetId: assetId) ?? 0
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        
        let titleLabel = UILabel()
        titleLabel.text = LocalizationHelper.localized("trade.confirm.title")
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.textAlignment = .center
        
        let total = quantity * price
        let actionKey = type == .buy ? "trade.confirm.buy" : "trade.confirm.sell"
        let action = LocalizationHelper.localized(actionKey)
        let color = type == .buy ? UIColor.systemGreen : UIColor.systemRed
        
        let attrText = NSMutableAttributedString(string: LocalizationHelper.localized("trade.confirm.question") + " \n")
        attrText.append(NSAttributedString(string: "\(action) \(quantity) \(symbol)", attributes: [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: color]))
        attrText.append(NSAttributedString(string: "\n" + LocalizationHelper.localized("trade.confirm.for") + " "))
        attrText.append(NSAttributedString(string: String(format: "$%.2f", total), attributes: [.font: UIFont.boldSystemFont(ofSize: 18)]))
        attrText.append(NSAttributedString(string: "?"))
        
        detailLabel.attributedText = attrText
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(detailLabel)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(LocalizationHelper.localized("app.cancel"), for: .normal)
        cancelButton.backgroundColor = .systemGray5
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle(LocalizationHelper.localized("trade.confirm.button"), for: .normal)
        confirmButton.backgroundColor = color
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(confirmButton)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            detailLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            detailLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            
            stack.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            stack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func confirmTapped() {
        let success: Bool
        if type == .buy {
            success = wealthService.buy(assetId: assetId, quantity: quantity)
        } else {
            success = wealthService.sell(assetId: assetId, quantity: quantity)
        }
        
        if success {
            // Show success and dismiss
            let alert = UIAlertController(
                title: LocalizationHelper.localized("trade.success.title"),
                message: LocalizationHelper.localized("trade.success.message"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.ok"), style: .default) { _ in
                self.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            // Show error
            let alert = UIAlertController(
                title: LocalizationHelper.localized("trade.failed.title"),
                message: LocalizationHelper.localized("trade.failed.message"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.ok"), style: .default))
            present(alert, animated: true)
        }
    }
}

