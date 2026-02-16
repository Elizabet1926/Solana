//
//  SignMessageVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb

final class SignMessageVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let privateKeyLabel = UILabel()
    private let privateKeyTextView = UITextView()
    private let privateKeyPlaceholder = UILabel()
    private let messageLabel = UILabel()
    private let messageTextView = UITextView()
    private let messagePlaceholder = UILabel()
    private let encodingLabel = UILabel()
    private let encodingSegment = UISegmentedControl(items: ["UTF-8", "Base58", "Auto"])
    private let signButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultLabel = UILabel()
    private let resultTextView = UITextView()
    private let copyJsonButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var lastResultJson: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign Message"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSolanaWeb()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        privateKeyLabel.text = "Private Key (Base58)"
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
        privateKeyTextView.returnKeyType = .next
        privateKeyTextView.isSecureTextEntry = true
        privateKeyPlaceholder.text = "Enter private key (base58)"
        privateKeyPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        privateKeyPlaceholder.textColor = .tertiaryLabel
        privateKeyPlaceholder.numberOfLines = 0

        messageLabel.text = "Message"
        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.textColor = .secondaryLabel
        messageTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        messageTextView.backgroundColor = UIColor.secondarySystemBackground
        messageTextView.layer.cornerRadius = 8
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        messageTextView.delegate = self
        messageTextView.text = ""
        messageTextView.autocapitalizationType = .none
        messageTextView.autocorrectionType = .no
        messagePlaceholder.text = "Enter message to sign (UTF-8 or Base58)"
        messagePlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        messagePlaceholder.textColor = .tertiaryLabel
        messagePlaceholder.numberOfLines = 0

        encodingLabel.text = "Message encoding"
        encodingLabel.font = .preferredFont(forTextStyle: .subheadline)
        encodingLabel.textColor = .secondaryLabel
        encodingSegment.selectedSegmentIndex = 2 // Auto

        signButton.setTitle("Sign Message", for: .normal)
        signButton.backgroundColor = .systemBlue
        signButton.setTitleColor(.white, for: .normal)
        signButton.layer.cornerRadius = 10
        signButton.addTarget(self, action: #selector(signTapped), for: .touchUpInside)

        resultStack.axis = .vertical
        resultStack.spacing = 8
        resultStack.alignment = .fill
        resultStack.isHidden = true
        resultLabel.text = "Result"
        resultLabel.font = .preferredFont(forTextStyle: .subheadline)
        resultLabel.textColor = .secondaryLabel
        resultTextView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        resultTextView.backgroundColor = UIColor.secondarySystemBackground
        resultTextView.layer.cornerRadius = 8
        resultTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        resultTextView.isEditable = false
        resultTextView.isScrollEnabled = true
        resultTextView.text = ""
        copyJsonButton.setTitle("Copy JSON", for: .normal)
        copyJsonButton.backgroundColor = .systemGreen
        copyJsonButton.setTitleColor(.white, for: .normal)
        copyJsonButton.layer.cornerRadius = 10
        copyJsonButton.addTarget(self, action: #selector(copyJsonTapped), for: .touchUpInside)
        copyJsonButton.isHidden = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(privateKeyLabel)
        contentStack.addArrangedSubview(privateKeyTextView)
        privateKeyTextView.addSubview(privateKeyPlaceholder)
        contentStack.addArrangedSubview(messageLabel)
        contentStack.addArrangedSubview(messageTextView)
        messageTextView.addSubview(messagePlaceholder)
        contentStack.addArrangedSubview(encodingLabel)
        contentStack.addArrangedSubview(encodingSegment)
        contentStack.addArrangedSubview(signButton)
        contentStack.addArrangedSubview(resultStack)
        resultStack.addArrangedSubview(resultLabel)
        resultStack.addArrangedSubview(resultTextView)
        resultStack.addArrangedSubview(copyJsonButton)
        view.addSubview(activityIndicator)
        signButton.isEnabled = false

        privateKeyPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        messagePlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide).offset(-20)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        privateKeyTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        messageTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }
        resultTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in
                self?.signButton.isEnabled = success
            }
        }
    }

    private var encodingParam: String {
        switch encodingSegment.selectedSegmentIndex {
        case 0: return "utf8"
        case 1: return "base58"
        default: return "auto"
        }
    }

    @objc private func signTapped() {
        view.endEditing(true)
        let privateKey = privateKeyTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let message = messageTextView.text ?? ""
        if privateKey.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter private key.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if message.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter message.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        resultStack.isHidden = true
        copyJsonButton.isHidden = true
        signButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                signButton.isEnabled = true
            }
            let response = await solanaWeb.signMessageAsync(privateKey: privateKey, message: message, encoding: encodingParam)
            applyResult(response: response)
        }
    }

    private func applyResult(response: [String: Any]?) {
        if let signature = response?["signature"] as? String, let publicKey = response?["publicKey"] as? String {
            resultTextView.text = "Signature:\n\(signature)\n\nPublic Key:\n\(publicKey)"
            resultTextView.textColor = .label
            lastResultJson = jsonString(from: ["signature": signature, "publicKey": publicKey])
            copyJsonButton.isHidden = false
        } else {
            let msg = (response?["error"] as? String) ?? "Failed to sign message"
            resultTextView.text = msg
            resultTextView.textColor = .systemRed
            lastResultJson = jsonString(from: ["error": msg])
            copyJsonButton.isHidden = false
        }
        resultStack.isHidden = false
    }

    private func jsonString(from dict: [String: String]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let s = String(data: data, encoding: .utf8) else { return nil }
        return s
    }

    @objc private func copyJsonTapped() {
        if let json = lastResultJson {
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

extension SignMessageVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === privateKeyTextView {
            privateKeyPlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        } else {
            messagePlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView === privateKeyTextView {
                messageTextView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
            return false
        }
        return true
    }
}
