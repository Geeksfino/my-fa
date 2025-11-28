//
//  DisclaimerViewController.swift
//  MyFA
//
//  First-run disclaimer screen for demo app
//

import UIKit

class DisclaimerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)
        
        let iconLabel = UILabel()
        iconLabel.text = "⚠️"
        iconLabel.font = .systemFont(ofSize: 60)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = "Important: Demo Application"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let messageLabel = UILabel()
        messageLabel.text = """
        MyFA is a DEMONSTRATION APPLICATION showcasing AI chat capabilities for financial assistance.
        
        • All trades are SIMULATED
        • No real money is involved
        • Market data is MOCK data
        • For educational purposes only
        
        This app does NOT provide actual financial services, trading, or investment management.
        """
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(messageLabel)
        
        let agreeButton = UIButton(type: .system)
        agreeButton.setTitle("I Understand", for: .normal)
        agreeButton.backgroundColor = .systemBlue
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        agreeButton.layer.cornerRadius = 12
        agreeButton.translatesAutoresizingMaskIntoConstraints = false
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        container.addSubview(agreeButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            container.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32),
            container.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -64),
            
            iconLabel.topAnchor.constraint(equalTo: container.topAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            agreeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
            agreeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            agreeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            agreeButton.heightAnchor.constraint(equalToConstant: 50),
            agreeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    @objc private func agreeTapped() {
        UserDefaults.standard.set(true, forKey: "HasSeenDisclaimer")
        dismiss(animated: true)
    }
}
