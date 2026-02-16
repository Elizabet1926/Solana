//
//  TokenListVC.swift
//  Solana
//

import UIKit
import SnapKit

/// One token account row from getTokenAccountsByOwner (mint, ata, amount, decimals, uiAmount).
struct TokenAccountItem {
    let mint: String
    let ata: String
    let amount: String
    let decimals: Int
    let uiAmount: Double?
}

final class TokenListVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let addressLabel = UILabel()
    private let addressTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let queryButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultLabel = UILabel()
    private let copyJsonButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var items: [TokenAccountItem] = []
    private var lastResultJson: String?
    private var errorMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Token Account List"
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
        placeholderLabel.text = "Enter owner address (base58)"
        placeholderLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.numberOfLines = 0

        queryButton.setTitle("Query Token Accounts", for: .normal)
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

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isHidden = true

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
        resultStack.addArrangedSubview(copyJsonButton)
        contentStack.addArrangedSubview(tableView)
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
        tableView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(120)
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
        tableView.isHidden = true
        queryButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                queryButton.isEnabled = true
            }
            let response = await solanaWeb.getTokenAccountsByOwnerAsync(address: address, endpoint: endpoint)
            applyResult(response: response)
        }
    }

    private func applyResult(response: [String: Any]?) {
        errorMessage = nil
        items = []
        if let jsonString = response?["tokenAccounts"] as? String,
           let data = jsonString.data(using: .utf8),
           let raw = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] {
            for dict in raw {
                let mint = dict["mint"] as? String ?? ""
                let ata = dict["ata"] as? String ?? ""
                let amount = dict["amount"] as? String ?? "0"
                let decimals = dict["decimals"] as? Int ?? 0
                let uiAmount = dict["uiAmount"] as? Double
                items.append(TokenAccountItem(mint: mint, ata: ata, amount: amount, decimals: decimals, uiAmount: uiAmount))
            }
            resultLabel.text = items.isEmpty ? "No token accounts." : "\(items.count) token account(s)."
            resultLabel.textColor = .label
            lastResultJson = jsonString
            copyJsonButton.isHidden = false
            resultStack.isHidden = false
            tableView.isHidden = items.isEmpty
            tableView.reloadData()
        } else {
            errorMessage = (response?["error"] as? String) ?? "Failed to get token accounts"
            resultLabel.text = errorMessage
            resultLabel.textColor = .systemRed
            lastResultJson = nil
            copyJsonButton.isHidden = true
            resultStack.isHidden = false
            tableView.isHidden = true
        }
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

extension TokenListVC: UITextViewDelegate {
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

extension TokenListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        let balanceStr: String
        if let u = item.uiAmount {
            balanceStr = String(format: "%.6f", u)
        } else {
            let div = pow(10.0, Double(item.decimals))
            balanceStr = String(format: "%.6f", (Double(item.amount) ?? 0) / div)
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        cell.textLabel?.text = "Mint: \(item.mint)\nATA: \(item.ata)\nBalance: \(balanceStr)"
        cell.selectionStyle = .none
        return cell
    }
}
