//
//  TokenBalanceVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb
final class TokenBalanceVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let addressLabel = UILabel()
    private let addressTextView = UITextView()
    private let addressPlaceholder = UILabel()
    private let mintLabel = UILabel()
    private let mintTextView = UITextView()
    private let mintPlaceholder = UILabel()
    private let decimalsLabel = UILabel()
    private let decimalsField = UITextField()
    private let queryButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultLabel = UILabel()
    private let copyJsonButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var lastResultJson: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SPL Token Balance"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSolanaWeb()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        addressLabel.text = "Owner Address"
        addressLabel.font = .preferredFont(forTextStyle: .subheadline)
        addressLabel.textColor = .secondaryLabel

        addressTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        addressTextView.backgroundColor = UIColor.secondarySystemBackground
        addressTextView.layer.cornerRadius = 8
        addressTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        addressTextView.delegate = self
        addressTextView.text = ""
        addressTextView.autocapitalizationType = .none
        addressTextView.autocorrectionType = .no
        addressTextView.returnKeyType = .next
        addressPlaceholder.text = "Enter owner address (base58)"
        addressPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        addressPlaceholder.textColor = .tertiaryLabel
        addressPlaceholder.numberOfLines = 0

        mintLabel.text = "Token Mint Address"
        mintLabel.font = .preferredFont(forTextStyle: .subheadline)
        mintLabel.textColor = .secondaryLabel

        mintTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        mintTextView.backgroundColor = UIColor.secondarySystemBackground
        mintTextView.layer.cornerRadius = 8
        mintTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        mintTextView.delegate = self
        mintTextView.text = ""
        mintTextView.autocapitalizationType = .none
        mintTextView.autocorrectionType = .no
        mintTextView.returnKeyType = .next
        mintPlaceholder.text = "Enter SPL token mint (base58)"
        mintPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        mintPlaceholder.textColor = .tertiaryLabel
        mintPlaceholder.numberOfLines = 0

        decimalsLabel.text = "Decimals (optional)"
        decimalsLabel.font = .preferredFont(forTextStyle: .subheadline)
        decimalsLabel.textColor = .secondaryLabel
        decimalsField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        decimalsField.backgroundColor = UIColor.secondarySystemBackground
        decimalsField.layer.cornerRadius = 8
        decimalsField.borderStyle = .none
        decimalsField.keyboardType = .numberPad
        decimalsField.placeholder = "6"
        decimalsField.text = "6"
        decimalsField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        decimalsField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        decimalsField.leftViewMode = .always
        decimalsField.rightViewMode = .always

        queryButton.setTitle("Query Balance", for: .normal)
        queryButton.backgroundColor = .systemBlue
        queryButton.setTitleColor(.white, for: .normal)
        queryButton.layer.cornerRadius = 10
        queryButton.addTarget(self, action: #selector(queryTapped), for: .touchUpInside)

        resultStack.axis = .vertical
        resultStack.spacing = 8
        resultStack.alignment = .fill
        resultStack.isHidden = true
        resultLabel.font = .preferredFont(forTextStyle: .body)
        resultLabel.numberOfLines = 0
        resultLabel.textColor = .label

        copyJsonButton.setTitle("Copy JSON", for: .normal)
        copyJsonButton.backgroundColor = .systemGreen
        copyJsonButton.setTitleColor(.white, for: .normal)
        copyJsonButton.layer.cornerRadius = 10
        copyJsonButton.addTarget(self, action: #selector(copyJsonTapped), for: .touchUpInside)
        copyJsonButton.isHidden = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(addressLabel)
        contentStack.addArrangedSubview(addressTextView)
        addressTextView.addSubview(addressPlaceholder)
        contentStack.addArrangedSubview(mintLabel)
        contentStack.addArrangedSubview(mintTextView)
        mintTextView.addSubview(mintPlaceholder)
        contentStack.addArrangedSubview(decimalsLabel)
        contentStack.addArrangedSubview(decimalsField)
        contentStack.addArrangedSubview(queryButton)
        contentStack.addArrangedSubview(resultStack)
        resultStack.addArrangedSubview(resultLabel)
        resultStack.addArrangedSubview(copyJsonButton)
        view.addSubview(activityIndicator)
        queryButton.isEnabled = false

        addressPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        mintPlaceholder.snp.makeConstraints { make in
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
        addressTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        mintTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        decimalsField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in
                self?.queryButton.isEnabled = success
            }
        }
    }

    @objc private func queryTapped() {
        view.endEditing(true)
        let address = addressTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        let mint = mintTextView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "") ?? ""
        if address.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter owner address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if mint.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter token mint address.", preferredStyle: .alert)
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
        let decimalPoints = Int(decimalsField.text ?? "6") ?? 6

        resultStack.isHidden = true
        copyJsonButton.isHidden = true
        queryButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                queryButton.isEnabled = true
            }
            let response = await solanaWeb.getSPLTokenBalanceAsync(address: address, mint: mint, endpoint: endpoint, decimalPoints: decimalPoints)
            applyResult(response: response)
        }
    }

    private func applyResult(response: [String: Any]?) {
        if let balance = response?["balance"] as? String {
            resultLabel.text = "Balance: \(balance)"
            resultLabel.textColor = .label
            lastResultJson = jsonString(from: ["balance": balance])
            copyJsonButton.isHidden = false
        } else {
            let message = (response?["error"] as? String) ?? "Failed to get token balance"
            resultLabel.text = message
            resultLabel.textColor = .systemRed
            lastResultJson = jsonString(from: ["error": message])
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

extension TokenBalanceVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === addressTextView {
            addressPlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        } else {
            mintPlaceholder.isHidden = !(textView.text?.isEmpty ?? true)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView === addressTextView {
                mintTextView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
            return false
        }
        return true
    }
}
