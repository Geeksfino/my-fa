//
//  StrategiesViewController.swift
//  MyFA
//
//  Strategies discovery screen with scrolling strategy list
//

import UIKit

class StrategiesViewController: UIViewController {
    
    weak var navigationDelegate: ChatNavigationDelegate?
    
    private let strategies = MockStrategyService.shared.getStrategies()
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStrategies()
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
        // Update title
        title = LocalizationHelper.localized("strategies.title")
        
        // Reload strategies to refresh UI
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        loadStrategies()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.05, alpha: 1.0) // Dark background
        
        // Navigation bar styling
        navigationController?.navigationBar.prefersLargeTitles = false
        title = LocalizationHelper.localized("strategies.title")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Header view
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        let headerTitle = UILabel()
        headerTitle.text = LocalizationHelper.localized("strategies.title")
        headerTitle.font = .systemFont(ofSize: 28, weight: .bold)
        headerTitle.textColor = .white
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let headerSubtitle = UILabel()
        headerSubtitle.text = LocalizationHelper.localized("strategies.subtitle")
        headerSubtitle.font = .systemFont(ofSize: 14)
        headerSubtitle.textColor = .gray
        headerSubtitle.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(headerTitle)
        headerView.addSubview(headerSubtitle)
        
        // ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = true
        
        // Content stack
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentStackView)
        view.addSubview(headerView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            headerTitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            headerTitle.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            
            headerSubtitle.leadingAnchor.constraint(equalTo: headerTitle.leadingAnchor),
            headerSubtitle.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 4),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content stack
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func loadStrategies() {
        for strategy in strategies {
            let cardView = StrategyCardView(strategy: strategy)
            cardView.delegate = self
            cardView.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(cardView)
        }
        
        // Add bottom padding
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        contentStackView.addArrangedSubview(spacer)
    }
}

// MARK: - StrategyCardDelegate
extension StrategiesViewController: StrategyCardDelegate {
    func strategyCardDidTapTakeToChat(_ card: StrategyCardView, strategy: Strategy) {
        let message = LocalizationHelper.localized("strategies.discuss", strategy.title)
        let context: [String: Any] = [
            "type": "strategy",
            "strategyId": strategy.id,
            "strategyTitle": strategy.title
        ]
        
        navigationDelegate?.navigateToChat(message: message, context: context)
    }
}
