//
//  AssetsViewController.swift
//  MyFA
//
//  Assets and account opening onboarding screen
//

import UIKit

class AssetsViewController: UIViewController {
    
    weak var navigationDelegate: ChatNavigationDelegate?
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var iconView: UIView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var openingCard: AccountOpeningCardView!
    private var startButton: UIButton!
    private var loginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.05, alpha: 1.0) // Dark background
        
        // Navigation bar styling
        title = LocalizationHelper.localized("assets.title")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Add notification bell icon to nav bar
        let bellButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: nil,
            action: nil
        )
        bellButton.tintColor = .white
        navigationItem.rightBarButtonItem = bellButton
        
        // Header view
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        let headerTitle = UILabel()
        headerTitle.text = LocalizationHelper.localized("assets.title")
        headerTitle.font = .systemFont(ofSize: 28, weight: .bold)
        headerTitle.textColor = .white
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let headerSubtitle = UILabel()
        headerSubtitle.text = LocalizationHelper.localized("assets.subtitle")
        headerSubtitle.font = .systemFont(ofSize: 14)
        headerSubtitle.textColor = .gray
        headerSubtitle.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(headerTitle)
        headerView.addSubview(headerSubtitle)
        
        // ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        
        // Content view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Icon view (circular with exclamation mark)
        iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = UIColor(red: 0.25, green: 0.30, blue: 0.45, alpha: 1.0)
        iconView.layer.cornerRadius = 60
        
        let exclamationIcon = UILabel()
        exclamationIcon.text = "!"
        exclamationIcon.font = .systemFont(ofSize: 48, weight: .bold)
        exclamationIcon.textColor = UIColor(red: 0.46, green: 0.65, blue: 1.00, alpha: 1.0)
        exclamationIcon.textAlignment = .center
        exclamationIcon.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(exclamationIcon)
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = LocalizationHelper.localized("assets.journey.title")
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle
        subtitleLabel = UILabel()
        subtitleLabel.text = LocalizationHelper.localized("assets.journey.subtitle")
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .lightGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Opening card
        let steps = MockAssetService.shared.getAccountOpeningSteps()
        openingCard = AccountOpeningCardView(steps: steps)
        openingCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Start button
        startButton = UIButton(type: .system)
        startButton.setTitle(LocalizationHelper.localized("assets.start.opening"), for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = UIColor(red: 0.46, green: 0.42, blue: 1.00, alpha: 1.00) // Purple gradient approximation
        startButton.layer.cornerRadius = 12
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startAccountOpening), for: .touchUpInside)
        
        // Login label
        loginLabel = UILabel()
        loginLabel.text = LocalizationHelper.localized("assets.has.account")
        loginLabel.font = .systemFont(ofSize: 14)
        loginLabel.textColor = .lightGray
        loginLabel.textAlignment = .center
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all to content view
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(openingCard)
        contentView.addSubview(startButton)
        contentView.addSubview(loginLabel)
        
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
            
            // Content view
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
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
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
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Login label
            loginLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 16),
            loginLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func startAccountOpening() {
        let message = "首先，请提供你的手机号码"
        let context: [String: Any] = [
            "type": "account_opening",
            "step": "phone_verification"
        ]
        
        navigationDelegate?.navigateToChat(message: message, context: context)
    }
}
