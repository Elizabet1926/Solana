//
//  CreateWalletVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb

final class CreateWalletVC: UIViewController {

    private let wordCounts = [12, 15, 18, 21, 24]
    private let languages: [(code: String, name: String)] = [
        ("en", "English"),
        ("zh-CN", "Simplified Chinese"),
        ("zh-TW", "Traditional Chinese"),
        ("ja", "Japanese"),
        ("ko", "Korean"),
        ("fr", "French"),
        ("es", "Spanish"),
        ("it", "Italian"),
    ]
    private let solanaWeb = SolanaWeb()
    private var selectedWordCount = 12
    private var selectedLanguageCode = "en"

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let wordCountLabel = UILabel()
    private let wordCountSegment = UISegmentedControl(items: ["12", "15", "18", "21", "24"])
    private let languageLabel = UILabel()
    private let languageButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultTextView = UITextView()
    private let copyJsonButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var lastWalletJson: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Wallet"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSolanaWeb()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        wordCountLabel.text = "Word count"
        wordCountLabel.font = .preferredFont(forTextStyle: .subheadline)
        wordCountLabel.textColor = .secondaryLabel
        wordCountSegment.selectedSegmentIndex = 0
        wordCountSegment.addTarget(self, action: #selector(wordCountChanged), for: .valueChanged)

        languageLabel.text = "Mnemonic language"
        languageLabel.font = .preferredFont(forTextStyle: .subheadline)
        languageLabel.textColor = .secondaryLabel
        languageButton.setTitle("English ▼", for: .normal)
        languageButton.contentHorizontalAlignment = .left
        languageButton.addTarget(self, action: #selector(showLanguagePicker), for: .touchUpInside)

        createButton.setTitle("Create Wallet", for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 10
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        resultStack.axis = .vertical
        resultStack.spacing = 12
        resultStack.alignment = .fill
        resultStack.isHidden = true

        resultTextView.isEditable = false
        resultTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        resultTextView.backgroundColor = UIColor.secondarySystemBackground
        resultTextView.layer.cornerRadius = 8
        resultTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        copyJsonButton.setTitle("Copy JSON", for: .normal)
        copyJsonButton.backgroundColor = .systemGreen
        copyJsonButton.setTitleColor(.white, for: .normal)
        copyJsonButton.layer.cornerRadius = 10
        copyJsonButton.addTarget(self, action: #selector(copyJsonTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(wordCountLabel)
        contentStack.addArrangedSubview(wordCountSegment)
        contentStack.addArrangedSubview(languageLabel)
        contentStack.addArrangedSubview(languageButton)
        contentStack.addArrangedSubview(createButton)
        contentStack.addArrangedSubview(resultStack)
        view.addSubview(activityIndicator)
        createButton.isEnabled = false

        resultStack.addArrangedSubview(resultTextView)
        resultStack.addArrangedSubview(copyJsonButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide).offset(-20)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        resultTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(240)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in
                self?.createButton.isEnabled = success
            }
        }
    }

    @objc private func wordCountChanged() {
        selectedWordCount = wordCounts[wordCountSegment.selectedSegmentIndex]
    }

    @objc private func showLanguagePicker() {
        let alert = UIAlertController(title: "Mnemonic language", message: nil, preferredStyle: .actionSheet)
        for lang in languages {
            alert.addAction(UIAlertAction(title: lang.name, style: .default) { [weak self] _ in
                self?.selectedLanguageCode = lang.code
                self?.languageButton.setTitle("\(lang.name) ▼", for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let pop = alert.popoverPresentationController {
            pop.sourceView = languageButton
            pop.sourceRect = languageButton.bounds
        }
        present(alert, animated: true)
    }

    @objc private func createTapped() {
        resultStack.isHidden = true
        createButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                createButton.isEnabled = true
            }
            let response = await solanaWeb.createWalletAsync(wordCount: selectedWordCount, language: selectedLanguageCode)
            if let res = response, res["state"] as? Bool == true {
                let jsonData: [String: Any] = [
                    "publicKey": res["publicKey"] as? String ?? "",
                    "privateKey": res["privateKey"] as? String ?? "",
                    "mnemonic": res["mnemonic"] as? String ?? "",
                    "wordCount": res["wordCount"] as? Int ?? selectedWordCount,
                    "language": res["language"] as? String ?? selectedLanguageCode,
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                    resultTextView.text = str
                    lastWalletJson = str
                }
                resultStack.isHidden = false
            } else {
                let message = (response?["error"] as? String) ?? "Failed to create wallet"
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }

    @objc private func copyJsonTapped() {
        if let json = lastWalletJson {
            UIPasteboard.general.string = json
            showCopiedToast()
        }
    }

    private func showCopiedToast() {
        let toast = UILabel()
        toast.text = "Copied"
        toast.backgroundColor = .black.withAlphaComponent(0.7)
        toast.textColor = .white
        toast.font = .preferredFont(forTextStyle: .callout)
        toast.textAlignment = .center
        toast.layer.cornerRadius = 8
        toast.clipsToBounds = true
        toast.alpha = 0
        view.addSubview(toast)
        toast.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.greaterThanOrEqualTo(100)
            make.height.equalTo(40)
        }
        UIView.animate(withDuration: 0.2) { toast.alpha = 1 }
        UIView.animate(withDuration: 0.2, delay: 1.5) {
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}
