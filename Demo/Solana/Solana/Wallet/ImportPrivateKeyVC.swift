//
//  ImportPrivateKeyVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb

final class ImportPrivateKeyVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let privateKeyLabel = UILabel()
    private let privateKeyTextView = UITextView()
    private let importButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultTextView = UITextView()
    private let copyJsonButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var lastImportJson: String?
    private let placeholderLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Import Account (Private Key)"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSolanaWeb()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        privateKeyLabel.text = "Private key (Base58)"
        privateKeyLabel.font = .preferredFont(forTextStyle: .subheadline)
        privateKeyLabel.textColor = .secondaryLabel

        privateKeyTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        privateKeyTextView.backgroundColor = UIColor.secondarySystemBackground
        privateKeyTextView.layer.cornerRadius = 8
        privateKeyTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        privateKeyTextView.delegate = self
        privateKeyTextView.text = ""
        privateKeyTextView.autocapitalizationType = .none
        privateKeyTextView.autocorrectionType = .no
        privateKeyTextView.returnKeyType = .done
        placeholderLabel.text = "Enter Base58 private key"
        placeholderLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.numberOfLines = 0

        importButton.setTitle("Import Account", for: .normal)
        importButton.backgroundColor = .systemBlue
        importButton.setTitleColor(.white, for: .normal)
        importButton.layer.cornerRadius = 10
        importButton.addTarget(self, action: #selector(importTapped), for: .touchUpInside)

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
        contentStack.addArrangedSubview(privateKeyLabel)
        contentStack.addArrangedSubview(privateKeyTextView)
        privateKeyTextView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        contentStack.addArrangedSubview(importButton)
        contentStack.addArrangedSubview(resultStack)
        view.addSubview(activityIndicator)
        importButton.isEnabled = false

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
        privateKeyTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }
        resultTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(120)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in
                self?.importButton.isEnabled = success
            }
        }
    }

    @objc private func importTapped() {
        view.endEditing(true)
        let privateKey = privateKeyTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        if privateKey.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter your private key.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        resultStack.isHidden = true
        importButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                importButton.isEnabled = true
            }
            let response = await solanaWeb.importAccountFromPrivateKeyAsync(privateKey: privateKey)
            if let res = response, res["state"] as? Bool == true {
                let jsonData: [String: Any] = [
                    "publicKey": res["publicKey"] as? String ?? "",
                    "privateKey": res["privateKey"] as? String ?? "",
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                    resultTextView.text = str
                    lastImportJson = str
                }
                resultStack.isHidden = false
            } else {
                let message = (response?["error"] as? String) ?? "Failed to import account"
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }

    @objc private func copyJsonTapped() {
        if let json = lastImportJson {
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

extension ImportPrivateKeyVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
