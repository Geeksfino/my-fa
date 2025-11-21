//
//  SettingsViewController.swift
//  MyFA
//
//  Settings screen with language switcher
//

import UIKit

class SettingsViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        title = LocalizationHelper.localized("settings.title")
        tableView.reloadData()
    }
    
    private func setupUI() {
        title = LocalizationHelper.localized("settings.title")
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showLanguageSelector() {
        let alert = UIAlertController(
            title: LocalizationHelper.localized("settings.language.change"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for language in LocalizationHelper.Language.allCases {
            let action = UIAlertAction(title: language.displayName, style: .default) { [weak self] _ in
                LocalizationHelper.setLanguage(language)
                self?.tableView.reloadData()
                self?.showLanguageChangedAlert()
            }
            
            if language == LocalizationHelper.currentLanguage {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.cancel"), style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = tableView
            popoverController.sourceRect = tableView.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func showLanguageChangedAlert() {
        let alert = UIAlertController(
            title: LocalizationHelper.localized("settings.language.change"),
            message: String(format: LocalizationHelper.localized("settings.language.current"), LocalizationHelper.currentLanguage.displayName),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.ok"), style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = LocalizationHelper.localized("settings.language")
        config.secondaryText = LocalizationHelper.currentLanguage.displayName
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showLanguageSelector()
    }
}

