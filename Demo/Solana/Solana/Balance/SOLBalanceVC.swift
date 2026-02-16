//
//  SOLBalanceVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb
final class SOLBalanceVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let addressLabel = UILabel()
    private let addressTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let queryButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SOL Balance"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSolanaWeb()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        addressLabel.text = "Address"
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
        addressTextView.returnKeyType = .done
        placeholderLabel.text = "Enter Solana address (base58)"
        placeholderLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.numberOfLines = 0

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

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(addressLabel)
        contentStack.addArrangedSubview(addressTextView)
        addressTextView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        contentStack.addArrangedSubview(queryButton)
        contentStack.addArrangedSubview(resultStack)
        resultStack.addArrangedSubview(resultLabel)
        view.addSubview(activityIndicator)
        queryButton.isEnabled = false

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide).offset(-20)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        addressTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(72)
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
        if address.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter an address.", preferredStyle: .alert)
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

        resultStack.isHidden = true
        queryButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                queryButton.isEnabled = true
            }
            let response = await solanaWeb.getSOLBalanceAsync(address: address, endpoint: endpoint)
            if let res = response, let balance = res["balance"] as? String {
                resultLabel.text = "Balance: \(balance) SOL"
                resultLabel.textColor = .label
                resultStack.isHidden = false
            } else {
                let message = (response?["error"] as? String) ?? "Failed to get balance"
                resultLabel.text = message
                resultLabel.textColor = .systemRed
                resultStack.isHidden = false
            }
        }
    }
}

extension SOLBalanceVC: UITextViewDelegate {
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
