//
//  SendSOLVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb

private let LAMPORTS_PER_SOL: UInt64 = 1_000_000_000

final class SendSOLVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let secretKeyLabel = UILabel()
    private let secretKeyTextView = UITextView()
    private let secretKeyPlaceholder = UILabel()
    private let fromAddressLabel = UILabel()
    private let fromAddressTextView = UITextView()
    private let fromAddressPlaceholder = UILabel()
    private let toAddressLabel = UILabel()
    private let toAddressTextView = UITextView()
    private let toAddressPlaceholder = UILabel()
    private let amountLabel = UILabel()
    private let amountField = UITextField()
    private let estimateSectionStack = UIStackView()
    private let estimateSectionLabel = UILabel()
    private let estimateButton = UIButton(type: .system)
    private let estimateResultTextView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let resultSectionStack = UIStackView()
    private let resultSectionLabel = UILabel()
    private let resultTextView = UITextView()
    private let copyJsonButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var lastResultJson: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Send SOL"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSolanaWeb()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        secretKeyLabel.text = "Private Key (Base58)"
        secretKeyLabel.font = .preferredFont(forTextStyle: .subheadline)
        secretKeyLabel.textColor = .secondaryLabel

        secretKeyTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        secretKeyTextView.backgroundColor = UIColor.secondarySystemBackground
        secretKeyTextView.layer.cornerRadius = 8
        secretKeyTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        secretKeyTextView.delegate = self
        secretKeyTextView.text = ""
        secretKeyTextView.autocapitalizationType = .none
        secretKeyTextView.autocorrectionType = .no
        secretKeyTextView.returnKeyType = .next
        secretKeyTextView.isSecureTextEntry = true
        secretKeyPlaceholder.text = "Enter sender private key (base58)"
        secretKeyPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        secretKeyPlaceholder.textColor = .tertiaryLabel
        secretKeyPlaceholder.numberOfLines = 0

        fromAddressLabel.text = "From Address (optional)"
        fromAddressLabel.font = .preferredFont(forTextStyle: .subheadline)
        fromAddressLabel.textColor = .secondaryLabel
        fromAddressTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        fromAddressTextView.backgroundColor = UIColor.secondarySystemBackground
        fromAddressTextView.layer.cornerRadius = 8
        fromAddressTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        fromAddressTextView.delegate = self
        fromAddressTextView.text = ""
        fromAddressTextView.autocapitalizationType = .none
        fromAddressTextView.autocorrectionType = .no
        fromAddressTextView.returnKeyType = .next
        fromAddressPlaceholder.text = "Leave empty to use address from private key"
        fromAddressPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        fromAddressPlaceholder.textColor = .tertiaryLabel
        fromAddressPlaceholder.numberOfLines = 0

        toAddressLabel.text = "To Address"
        toAddressLabel.font = .preferredFont(forTextStyle: .subheadline)
        toAddressLabel.textColor = .secondaryLabel

        toAddressTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        toAddressTextView.backgroundColor = UIColor.secondarySystemBackground
        toAddressTextView.layer.cornerRadius = 8
        toAddressTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        toAddressTextView.delegate = self
        toAddressTextView.text = ""
        toAddressTextView.autocapitalizationType = .none
        toAddressTextView.autocorrectionType = .no
        toAddressTextView.returnKeyType = .next
        toAddressPlaceholder.text = "Enter recipient address (base58)"
        toAddressPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        toAddressPlaceholder.textColor = .tertiaryLabel
        toAddressPlaceholder.numberOfLines = 0

        amountLabel.text = "Amount (SOL)"
        amountLabel.font = .preferredFont(forTextStyle: .subheadline)
        amountLabel.textColor = .secondaryLabel
        amountField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        amountField.backgroundColor = UIColor.secondarySystemBackground
        amountField.layer.cornerRadius = 8
        amountField.borderStyle = .none
        amountField.keyboardType = .decimalPad
        amountField.placeholder = "0.1"
        amountField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        amountField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        amountField.leftViewMode = .always
        amountField.rightViewMode = .always

        estimateSectionStack.axis = .vertical
        estimateSectionStack.spacing = 8
        estimateSectionStack.alignment = .fill
        estimateSectionLabel.text = "Estimated Cost"
        estimateSectionLabel.font = .preferredFont(forTextStyle: .subheadline)
        estimateSectionLabel.textColor = .secondaryLabel
        estimateButton.setTitle("Estimate Fee", for: .normal)
        estimateButton.backgroundColor = .systemOrange
        estimateButton.setTitleColor(.white, for: .normal)
        estimateButton.layer.cornerRadius = 10
        estimateButton.addTarget(self, action: #selector(estimateTapped), for: .touchUpInside)
        estimateResultTextView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        estimateResultTextView.backgroundColor = UIColor.secondarySystemBackground
        estimateResultTextView.layer.cornerRadius = 8
        estimateResultTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        estimateResultTextView.isEditable = false
        estimateResultTextView.isScrollEnabled = true
        estimateResultTextView.text = ""
        estimateResultTextView.isHidden = true

        sendButton.setTitle("Send SOL", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 10
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        resultSectionStack.axis = .vertical
        resultSectionStack.spacing = 8
        resultSectionStack.alignment = .fill
        resultSectionStack.isHidden = true
        resultSectionLabel.text = "Transfer Result"
        resultSectionLabel.font = .preferredFont(forTextStyle: .subheadline)
        resultSectionLabel.textColor = .secondaryLabel
        resultTextView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        resultTextView.backgroundColor = UIColor.secondarySystemBackground
        resultTextView.layer.cornerRadius = 8
        resultTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        resultTextView.isEditable = false
        resultTextView.isScrollEnabled = true
        resultTextView.text = ""
        resultTextView.textColor = .label

        copyJsonButton.setTitle("Copy JSON", for: .normal)
        copyJsonButton.backgroundColor = .systemGreen
        copyJsonButton.setTitleColor(.white, for: .normal)
        copyJsonButton.layer.cornerRadius = 10
        copyJsonButton.addTarget(self, action: #selector(copyJsonTapped), for: .touchUpInside)
        copyJsonButton.isHidden = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(secretKeyLabel)
        contentStack.addArrangedSubview(secretKeyTextView)
        secretKeyTextView.addSubview(secretKeyPlaceholder)
        contentStack.addArrangedSubview(fromAddressLabel)
        contentStack.addArrangedSubview(fromAddressTextView)
        fromAddressTextView.addSubview(fromAddressPlaceholder)
        contentStack.addArrangedSubview(toAddressLabel)
        contentStack.addArrangedSubview(toAddressTextView)
        toAddressTextView.addSubview(toAddressPlaceholder)
        contentStack.addArrangedSubview(amountLabel)
        contentStack.addArrangedSubview(amountField)
        contentStack.addArrangedSubview(estimateSectionStack)
        estimateSectionStack.addArrangedSubview(estimateSectionLabel)
        estimateSectionStack.addArrangedSubview(estimateButton)
        estimateSectionStack.addArrangedSubview(estimateResultTextView)
        contentStack.addArrangedSubview(sendButton)
        contentStack.addArrangedSubview(resultSectionStack)
        resultSectionStack.addArrangedSubview(resultSectionLabel)
        resultSectionStack.addArrangedSubview(resultTextView)
        resultSectionStack.addArrangedSubview(copyJsonButton)
        view.addSubview(activityIndicator)
        sendButton.isEnabled = false
        estimateButton.isEnabled = false

        secretKeyPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        fromAddressPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        toAddressPlaceholder.snp.makeConstraints { make in
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
        secretKeyTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        fromAddressTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        toAddressTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        amountField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        estimateResultTextView.snp.makeConstraints { make in
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
                self?.sendButton.isEnabled = success
                self?.estimateButton.isEnabled = success
            }
        }
    }

    @objc private func estimateTapped() {
        view.endEditing(true)
        let secretKey = secretKeyTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let fromAddress = fromAddressTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let toAddress = toAddressTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let amountText = amountField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if fromAddress.isEmpty && secretKey.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter private key or from address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if toAddress.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter recipient address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let amountSOL = Double(amountText), amountSOL > 0 else {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid amount (SOL).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let endpoint = RPCConfigManager.currentEndpoint else {
            let alert = UIAlertController(title: "Error", message: "No RPC endpoint. Set one in RPC Config first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let lamports = UInt64(amountSOL * Double(LAMPORTS_PER_SOL))
        if lamports == 0 {
            let alert = UIAlertController(title: "Error", message: "Amount is too small.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        estimateResultTextView.isHidden = false
        estimateResultTextView.text = "Estimating..."
        estimateResultTextView.textColor = .secondaryLabel
        estimateButton.isEnabled = false
        activityIndicator.startAnimating()

        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                estimateButton.isEnabled = true
            }
            let fromPubkey: String
            if !fromAddress.isEmpty {
                fromPubkey = fromAddress
            } else {
                let importResponse = await solanaWeb.importAccountFromPrivateKeyAsync(privateKey: secretKey)
                guard let pub = importResponse?["publicKey"] as? String else {
                    estimateResultTextView.text = (importResponse?["error"] as? String) ?? "Failed to get sender address from private key."
                    estimateResultTextView.textColor = .systemRed
                    return
                }
                fromPubkey = pub
            }
            let response = await solanaWeb.estimatedSOLTransferCostAsync(fromPublicKey: fromPubkey, toPublicKey: toAddress, amountLamports: lamports, endpoint: endpoint)
            applyEstimateResult(response: response)
        }
    }

    private func applyEstimateResult(response: [String: Any]?) {
        if let error = response?["error"] as? String {
            estimateResultTextView.text = error
            estimateResultTextView.textColor = .systemRed
            return
        }
        var lines: [String] = []
        if let transferSol = response?["transferSol"] as? Double {
            lines.append("Transfer: \(String(format: "%.9f", transferSol)) SOL")
        }
        if let feeSol = response?["estimatedFeeSol"] as? Double {
            lines.append("Estimated fee: \(String(format: "%.9f", feeSol)) SOL")
        }
        if let needCreate = response?["needCreateAccount"] as? Bool, needCreate,
           let rentSol = response?["rentExemptMinimumSol"] as? Double {
            lines.append("Recipient account does not exist. Rent for new account: \(String(format: "%.9f", rentSol)) SOL")
        }
        if let total = response?["estimatedSOLTransferCost"] as? String {
            lines.append("Total (transfer + fee): \(total) SOL")
        }
        if let totalWithRent = response?["totalCostWithRentSol"] as? Double, (response?["needCreateAccount"] as? Bool) == true {
            lines.append("Total (including rent): \(String(format: "%.9f", totalWithRent)) SOL")
        }
        estimateResultTextView.text = lines.isEmpty ? "No estimate data." : lines.joined(separator: "\n")
        estimateResultTextView.textColor = .label
    }

    @objc private func sendTapped() {
        view.endEditing(true)
        let secretKey = secretKeyTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let toAddress = toAddressTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let amountText = amountField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if secretKey.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter private key.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if toAddress.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter recipient address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let amountSOL = Double(amountText), amountSOL > 0 else {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid amount (SOL).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let endpoint = RPCConfigManager.currentEndpoint else {
            let alert = UIAlertController(title: "Error", message: "No RPC endpoint. Set one in RPC Config first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let lamports = UInt64(amountSOL * Double(LAMPORTS_PER_SOL))
        if lamports == 0 {
            let alert = UIAlertController(title: "Error", message: "Amount is too small.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        resultSectionStack.isHidden = true
        copyJsonButton.isHidden = true
        sendButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                sendButton.isEnabled = true
            }
            let response = await solanaWeb.sendSOLAsync(secretKey: secretKey, toPublicKey: toAddress, amountLamports: lamports, endpoint: endpoint)
            applyResult(response: response)
        }
    }

    private func applyResult(response: [String: Any]?) {
        if let signature = response?["signature"] as? String {
            resultTextView.text = "Success.\n\nSignature:\n\(signature)"
            resultTextView.textColor = .label
            lastResultJson = jsonString(from: ["signature": signature])
            copyJsonButton.isHidden = false
        } else {
            let message = (response?["error"] as? String) ?? "Failed to send SOL"
            resultTextView.text = message
            resultTextView.textColor = .systemRed
            lastResultJson = jsonString(from: ["error": message])
            copyJsonButton.isHidden = false
        }
        resultSectionStack.isHidden = false
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

extension SendSOLVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === secretKeyTextView {
            secretKeyPlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        } else if textView === fromAddressTextView {
            fromAddressPlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        } else if textView === toAddressTextView {
            toAddressPlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView === secretKeyTextView {
                fromAddressTextView.becomeFirstResponder()
            } else if textView === fromAddressTextView {
                toAddressTextView.becomeFirstResponder()
            } else if textView === toAddressTextView {
                amountField.becomeFirstResponder()
            }
            return false
        }
        return true
    }
}
