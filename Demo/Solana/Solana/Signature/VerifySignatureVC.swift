//
//  VerifySignatureVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb

final class VerifySignatureVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let publicKeyLabel = UILabel()
    private let publicKeyTextView = UITextView()
    private let publicKeyPlaceholder = UILabel()
    private let messageLabel = UILabel()
    private let messageTextView = UITextView()
    private let messagePlaceholder = UILabel()
    private let signatureLabel = UILabel()
    private let signatureTextView = UITextView()
    private let signaturePlaceholder = UILabel()
    private let encodingLabel = UILabel()
    private let encodingSegment = UISegmentedControl(items: ["UTF-8", "Base58", "Auto"])
    private let verifyButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultLabel = UILabel()
    private let resultTextView = UITextView()
    private let copyJsonButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var lastResultJson: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verify Signature"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSolanaWeb()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        publicKeyLabel.text = "Public Key (Base58)"
        publicKeyLabel.font = .preferredFont(forTextStyle: .subheadline)
        publicKeyLabel.textColor = .secondaryLabel
        publicKeyTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        publicKeyTextView.backgroundColor = UIColor.secondarySystemBackground
        publicKeyTextView.layer.cornerRadius = 8
        publicKeyTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        publicKeyTextView.delegate = self
        publicKeyTextView.text = ""
        publicKeyTextView.autocapitalizationType = .none
        publicKeyTextView.autocorrectionType = .no
        publicKeyTextView.returnKeyType = .next
        publicKeyPlaceholder.text = "Enter signer public key (base58)"
        publicKeyPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        publicKeyPlaceholder.textColor = .tertiaryLabel
        publicKeyPlaceholder.numberOfLines = 0

        messageLabel.text = "Original Message"
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
        messagePlaceholder.text = "Enter original message"
        messagePlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        messagePlaceholder.textColor = .tertiaryLabel
        messagePlaceholder.numberOfLines = 0

        signatureLabel.text = "Signature (Base58)"
        signatureLabel.font = .preferredFont(forTextStyle: .subheadline)
        signatureLabel.textColor = .secondaryLabel
        signatureTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        signatureTextView.backgroundColor = UIColor.secondarySystemBackground
        signatureTextView.layer.cornerRadius = 8
        signatureTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        signatureTextView.delegate = self
        signatureTextView.text = ""
        signatureTextView.autocapitalizationType = .none
        signatureTextView.autocorrectionType = .no
        signaturePlaceholder.text = "Enter signature (base58)"
        signaturePlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        signaturePlaceholder.textColor = .tertiaryLabel
        signaturePlaceholder.numberOfLines = 0

        encodingLabel.text = "Message encoding"
        encodingLabel.font = .preferredFont(forTextStyle: .subheadline)
        encodingLabel.textColor = .secondaryLabel
        encodingSegment.selectedSegmentIndex = 2 // Auto

        verifyButton.setTitle("Verify Signature", for: .normal)
        verifyButton.backgroundColor = .systemBlue
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 10
        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)

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
        contentStack.addArrangedSubview(publicKeyLabel)
        contentStack.addArrangedSubview(publicKeyTextView)
        publicKeyTextView.addSubview(publicKeyPlaceholder)
        contentStack.addArrangedSubview(messageLabel)
        contentStack.addArrangedSubview(messageTextView)
        messageTextView.addSubview(messagePlaceholder)
        contentStack.addArrangedSubview(signatureLabel)
        contentStack.addArrangedSubview(signatureTextView)
        signatureTextView.addSubview(signaturePlaceholder)
        contentStack.addArrangedSubview(encodingLabel)
        contentStack.addArrangedSubview(encodingSegment)
        contentStack.addArrangedSubview(verifyButton)
        contentStack.addArrangedSubview(resultStack)
        resultStack.addArrangedSubview(resultLabel)
        resultStack.addArrangedSubview(resultTextView)
        resultStack.addArrangedSubview(copyJsonButton)
        view.addSubview(activityIndicator)
        verifyButton.isEnabled = false

        publicKeyPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        messagePlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        signaturePlaceholder.snp.makeConstraints { make in
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
        publicKeyTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        messageTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        signatureTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        resultTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(60)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in
                self?.verifyButton.isEnabled = success
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

    @objc private func verifyTapped() {
        view.endEditing(true)
        let publicKey = publicKeyTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let message = messageTextView.text ?? ""
        let signature = signatureTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        if publicKey.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter public key.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if message.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter original message.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if signature.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter signature.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        resultStack.isHidden = true
        copyJsonButton.isHidden = true
        verifyButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                verifyButton.isEnabled = true
            }
            let response = await solanaWeb.verifySignatureAsync(publicKey: publicKey, message: message, signature: signature, encoding: encodingParam)
            applyResult(response: response)
        }
    }

    private func applyResult(response: [String: Any]?) {
        if let isValid = response?["isValid"] as? Bool {
            if isValid {
                resultTextView.text = "Signature is valid.\n\nThe message was signed by the provided public key."
                resultTextView.textColor = .label
                lastResultJson = jsonString(from: ["isValid": "true"])
            } else {
                resultTextView.text = "Signature is invalid.\n\nThe message was not signed by the provided public key."
                resultTextView.textColor = .systemOrange
                lastResultJson = jsonString(from: ["isValid": "false"])
            }
            copyJsonButton.isHidden = false
        } else {
            let msg = (response?["error"] as? String) ?? "Failed to verify signature"
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

extension VerifySignatureVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === publicKeyTextView {
            publicKeyPlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        } else if textView === messageTextView {
            messagePlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        } else if textView === signatureTextView {
            signaturePlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView === publicKeyTextView {
                messageTextView.becomeFirstResponder()
            } else if textView === messageTextView {
                signatureTextView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
            return false
        }
        return true
    }
}
