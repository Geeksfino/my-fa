//
//  AssetsViewController.swift
//  MyFA
//
//  Assets Dashboard & Portfolio View
//

import UIKit
import Combine

class AssetsViewController: UIViewController {
    
    weak var navigationDelegate: ChatNavigationDelegate?
    
    private let wealthService = WealthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - State
    
    private var isLoggedIn = false
    
    // MARK: - UI Components
    
    // --- Login State UI ---
    
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var iconView: UIView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var openingCard: AccountOpeningCardView!
    private var startButton: UIButton!
    private var loginButton: UIButton!
    private var loginLabel: UILabel!
    
    // --- Logged In State UI ---
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .systemGroupedBackground
        tv.delegate = self
        tv.dataSource = self
        tv.register(HoldingCell.self, forCellReuseIdentifier: HoldingCell.identifier)
        tv.separatorStyle = .none
        tv.isHidden = true // Hidden by default
        return tv
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 180))
        view.backgroundColor = .clear
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        card.layer.cornerRadius = 20
        view.addSubview(card)
        
        let titleLabel = UILabel()
        titleLabel.text = LocalizationHelper.localized("assets.total.balance")
        titleLabel.textColor = .secondaryLabel
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.tag = 100 // Tag to find and update
        valueLabel.text = "$0.00"
        valueLabel.textColor = .label
        valueLabel.font = .systemFont(ofSize: 42, weight: .bold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(valueLabel)
        
        let cashLabel = UILabel()
        cashLabel.tag = 101
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        cashLabel.text = LocalizationHelper.localized("assets.cash", formatter.string(from: NSNumber(value: 0)) ?? "$0.00")
        cashLabel.textColor = .secondaryLabel
        cashLabel.font = .systemFont(ofSize: 15)
        cashLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cashLabel)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            
            cashLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            cashLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            cashLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateViewState()
        bindData()
        observeLanguageChanges()
    }
    
    private func observeLanguageChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    @objc private func languageDidChange() {
        // Update all localized text
        title = LocalizationHelper.localized("assets.title")
        titleLabel.text = LocalizationHelper.localized("assets.journey.title")
        subtitleLabel.text = LocalizationHelper.localized("assets.journey.subtitle")
        startButton.setTitle(LocalizationHelper.localized("assets.start.opening"), for: .normal)
        loginLabel.text = LocalizationHelper.localized("assets.has.account")
        loginButton.setTitle(LocalizationHelper.localized("assets.login.demo"), for: .normal)
        
        // Update navigation buttons
        if isLoggedIn {
            if let buttons = navigationItem.rightBarButtonItems {
                buttons.first?.title = LocalizationHelper.localized("assets.trade")
                buttons.last?.title = LocalizationHelper.localized("assets.logout")
            }
        }
        
        // Reload table to update section headers
        tableView.reloadData()
        
        // Update header labels
        if let card = headerView.subviews.first {
            if let titleLabel = card.subviews.first(where: { $0 is UILabel && $0.tag == 0 }) as? UILabel {
                titleLabel.text = LocalizationHelper.localized("assets.total.balance")
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = LocalizationHelper.localized("assets.title")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup Login UI (Account Opening)
        setupLoginUI()
        
        // Setup Logged In UI (Portfolio)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.tableHeaderView = headerView
        
        // Layout header properly
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
    }
    
    private func setupLoginUI() {
        // ScrollView for Login UI
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemGroupedBackground
        view.addSubview(scrollView)
        
        // Content View
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Icon view (circular with exclamation mark)
        iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        iconView.layer.cornerRadius = 60
        
        let exclamationIcon = UILabel()
        exclamationIcon.text = "!"
        exclamationIcon.font = .systemFont(ofSize: 48, weight: .bold)
        exclamationIcon.textColor = .systemBlue
        exclamationIcon.textAlignment = .center
        exclamationIcon.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(exclamationIcon)
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = LocalizationHelper.localized("assets.journey.title")
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle
        subtitleLabel = UILabel()
        subtitleLabel.text = LocalizationHelper.localized("assets.journey.subtitle")
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Opening card
        let steps = MockAssetService.shared.getAccountOpeningSteps()
        openingCard = AccountOpeningCardView(steps: steps)
        openingCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Start button (Interactive Account Opening)
        startButton = UIButton(type: .system)
        startButton.setTitle(LocalizationHelper.localized("assets.start.opening"), for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 14
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startAccountOpening), for: .touchUpInside)
        
        // Login label
        loginLabel = UILabel()
        loginLabel.text = LocalizationHelper.localized("assets.has.account")
        loginLabel.font = .systemFont(ofSize: 15)
        loginLabel.textColor = .secondaryLabel
        loginLabel.textAlignment = .center
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Login Button (Simulated Login)
        loginButton = UIButton(type: .system)
        loginButton.setTitle(LocalizationHelper.localized("assets.login.demo"), for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(showLoginScreen), for: .touchUpInside)
        
        // Add to content view
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(openingCard)
        contentView.addSubview(startButton)
        contentView.addSubview(loginLabel)
        contentView.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Icon
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 120),
            iconView.heightAnchor.constraint(equalToConstant: 120),
            
            exclamationIcon.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            exclamationIcon.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Opening card
            openingCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            openingCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            openingCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Start button
            startButton.topAnchor.constraint(equalTo: openingCard.bottomAnchor, constant: 32),
            startButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Login label
            loginLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24),
            loginLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Login button
            loginButton.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func updateViewState() {
        // Toggle visibility based on login state
        scrollView.isHidden = isLoggedIn
        tableView.isHidden = !isLoggedIn
        
        // Update navigation bar button
        if isLoggedIn {
            let logoutButton = UIBarButtonItem(title: LocalizationHelper.localized("assets.logout"), style: .plain, target: self, action: #selector(logoutTapped))
            let tradeButton = UIBarButtonItem(title: LocalizationHelper.localized("assets.trade"), style: .plain, target: self, action: #selector(tradeButtonTapped))
            navigationItem.rightBarButtonItems = [tradeButton, logoutButton]
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    private func bindData() {
        wealthService.$portfolio
            .receive(on: RunLoop.main)
            .sink { [weak self] portfolio in
                self?.updateHeader(portfolio)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        wealthService.$marketData
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                if let portfolio = self?.wealthService.portfolio {
                    self?.updateHeader(portfolio)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateHeader(_ portfolio: Portfolio) {
        let totalValue = wealthService.getTotalValue()
        
        if let valueLabel = headerView.viewWithTag(100) as? UILabel {
            valueLabel.text = formatCurrency(totalValue)
        }
        if let cashLabel = headerView.viewWithTag(101) as? UILabel {
            cashLabel.text = LocalizationHelper.localized("assets.cash", formatCurrency(portfolio.cashBalance))
        }
    }
    
    // MARK: - Actions
    
    @objc private func startAccountOpening() {
        // Send a user message that will trigger the agent to ask for phone number
        // Instead of sending the agent's prompt message as a user message
        let message = LocalizationHelper.localized("account.opening.request")
        let context: [String: Any] = [
            "type": "account_opening",
            "step": "phone_verification"
        ]
        
        navigationDelegate?.navigateToChat(message: message, context: context)
    }
    
    @objc private func showLoginScreen() {
        let alert = UIAlertController(
            title: LocalizationHelper.localized("assets.login.title"),
            message: LocalizationHelper.localized("assets.login.message"),
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = LocalizationHelper.localized("assets.login.username")
            textField.text = "johndoe"
        }
        
        alert.addTextField { textField in
            textField.placeholder = LocalizationHelper.localized("assets.login.password")
            textField.isSecureTextEntry = true
            textField.text = "12345678"
        }
        
        let loginAction = UIAlertAction(title: LocalizationHelper.localized("assets.login.button"), style: .default) { [weak self] _ in
            guard let self = self else { return }
            let username = alert.textFields?[0].text
            let password = alert.textFields?[1].text
            
            if username == "johndoe" && password == "12345678" {
                self.isLoggedIn = true
                self.updateViewState()
            } else {
                let errorAlert = UIAlertController(
                    title: LocalizationHelper.localized("app.error"),
                    message: LocalizationHelper.localized("assets.login.error"),
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.ok"), style: .default))
                self.present(errorAlert, animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: LocalizationHelper.localized("app.cancel"), style: .cancel)
        
        alert.addAction(loginAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: LocalizationHelper.localized("assets.logout.confirm.title"),
            message: LocalizationHelper.localized("assets.logout.confirm.message"),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: LocalizationHelper.localized("assets.logout"), style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        isLoggedIn = false
        updateViewState()
    }
    
    @objc private func tradeButtonTapped() {
        let message = LocalizationHelper.localized("trade.want")
        navigationDelegate?.navigateToChat(message: message, context: [:])
        
        if let tabBar = tabBarController {
            tabBar.selectedIndex = 0
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    private func askAboutAsset(_ holding: Holding) {
        let message = LocalizationHelper.localized("assets.ask.about", holding.asset.name, holding.asset.symbol)
        navigationDelegate?.navigateToChat(message: message, context: [:])
        
        if let tabBar = tabBarController {
            tabBar.selectedIndex = 0
        }
    }
}

// MARK: - UITableViewDataSource

extension AssetsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AssetType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = AssetType.allCases[section]
        return wealthService.portfolio.holdings.filter { $0.asset.type == type }.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let type = AssetType.allCases[section]
        let count = wealthService.portfolio.holdings.filter { $0.asset.type == type }.count
        if count > 0 {
            let key = "portfolio.\(type.rawValue)"
            return LocalizationHelper.localized(key)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HoldingCell.identifier, for: indexPath) as? HoldingCell else {
            return UITableViewCell()
        }
        
        let type = AssetType.allCases[indexPath.section]
        let holdings = wealthService.portfolio.holdings.filter { $0.asset.type == type }
        let holding = holdings[indexPath.row]
        
        let price = wealthService.getPrice(assetId: holding.asset.id) ?? 0
        cell.configure(with: holding, currentPrice: price)
        cell.onAskTapped = { [weak self] in
            self?.askAboutAsset(holding)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let type = AssetType.allCases[section]
        let count = wealthService.portfolio.holdings.filter { $0.asset.type == type }.count
        return count > 0 ? 44 : 0
    }
}

// MARK: - Holding Cell

class HoldingCell: UITableViewCell {
    static let identifier = "HoldingCell"
    
    var onAskTapped: (() -> Void)?
    
    private let containerView = UIView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let valueLabel = UILabel()
    private let quantityLabel = UILabel()
    private let askButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemGroupedBackground
        containerView.layer.cornerRadius = 12
        contentView.addSubview(containerView)
        
        symbolLabel.font = .systemFont(ofSize: 18, weight: .bold)
        symbolLabel.textColor = .label
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = .secondaryLabel
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        quantityLabel.font = .systemFont(ofSize: 13)
        quantityLabel.textColor = .secondaryLabel
        quantityLabel.textAlignment = .right
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        askButton.setImage(UIImage(systemName: "bubble.left"), for: .normal)
        askButton.tintColor = .systemBlue
        askButton.translatesAutoresizingMaskIntoConstraints = false
        askButton.addTarget(self, action: #selector(askButtonTapped), for: .touchUpInside)
        
        containerView.addSubview(symbolLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(quantityLabel)
        containerView.addSubview(askButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            symbolLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            symbolLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: symbolLabel.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            askButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            askButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            askButton.widthAnchor.constraint(equalToConstant: 32),
            askButton.heightAnchor.constraint(equalToConstant: 32),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: askButton.leadingAnchor, constant: -12),
            
            quantityLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            quantityLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            quantityLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with holding: Holding, currentPrice: Double) {
        symbolLabel.text = holding.asset.symbol
        nameLabel.text = holding.asset.name
        
        let value = holding.quantity * currentPrice
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        valueLabel.text = formatter.string(from: NSNumber(value: value))
        quantityLabel.text = String(format: LocalizationHelper.localized("portfolio.quantity.units"), holding.quantity)
    }
    
    @objc private func askButtonTapped() {
        onAskTapped?()
    }
}
