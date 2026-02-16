//
//  MultisigSendSPLTokenVC.swift
//  Solana
//

import UIKit
import SnapKit

final class MultisigSendSPLTokenVC: UIViewController {

    private let solanaWeb = SolanaWeb()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let multisigPdaLabel = UILabel()
    private let multisigPdaTextView = UITextView()
    private let creatorKeyLabel = UILabel()
    private let creatorKeyTextView = UITextView()
    private let creatorKeyPlaceholder = UILabel()
    private let mintLabel = UILabel()
    private let mintTextView = UITextView()
    private let toLabel = UILabel()
    private let toTextView = UITextView()
    private let toPlaceholder = UILabel()
    private let amountLabel = UILabel()
    private let amountField = UITextField()
    private let decimalsLabel = UILabel()
    private let decimalsField = UITextField()
    private let createAtaSwitch = UISwitch()
    private let createAtaLabel = UILabel()
    private let createButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let hintLabel = UILabel()
    private let resultTextView = UITextView()
    private let copyButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multisig - Send SPL Token (Create Proposal)"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "View Guide", style: .plain, target: self, action: #selector(showMultisigGuideTapped))
        setupUI()
        setupSolanaWeb()
    }

    @objc private func showMultisigGuideTapped() {
        let vc = ExplainWebVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        multisigPdaLabel.text = "Multisig PDA"
        multisigPdaLabel.font = .preferredFont(forTextStyle: .subheadline)
        multisigPdaLabel.textColor = .secondaryLabel
        multisigPdaTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        multisigPdaTextView.backgroundColor = UIColor.secondarySystemBackground
        multisigPdaTextView.layer.cornerRadius = 8
        multisigPdaTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        multisigPdaTextView.autocapitalizationType = .none
        multisigPdaTextView.autocorrectionType = .no

        creatorKeyLabel.text = "Creator Private Key (Base58)"
        creatorKeyLabel.font = .preferredFont(forTextStyle: .subheadline)
        creatorKeyLabel.textColor = .secondaryLabel
        creatorKeyTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        creatorKeyTextView.backgroundColor = UIColor.secondarySystemBackground
        creatorKeyTextView.layer.cornerRadius = 8
        creatorKeyTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        creatorKeyTextView.delegate = self
        creatorKeyTextView.autocapitalizationType = .none
        creatorKeyTextView.autocorrectionType = .no
        creatorKeyTextView.isSecureTextEntry = true
        creatorKeyPlaceholder.text = "Enter creator private key"
        creatorKeyPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        creatorKeyPlaceholder.textColor = .tertiaryLabel

        mintLabel.text = "Token Mint Address"
        mintLabel.font = .preferredFont(forTextStyle: .subheadline)
        mintLabel.textColor = .secondaryLabel
        mintTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        mintTextView.backgroundColor = UIColor.secondarySystemBackground
        mintTextView.layer.cornerRadius = 8
        mintTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        mintTextView.autocapitalizationType = .none
        mintTextView.autocorrectionType = .no

        toLabel.text = "To Address (recipient)"
        toLabel.font = .preferredFont(forTextStyle: .subheadline)
        toLabel.textColor = .secondaryLabel
        toTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        toTextView.backgroundColor = UIColor.secondarySystemBackground
        toTextView.layer.cornerRadius = 8
        toTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        toTextView.delegate = self
        toTextView.autocapitalizationType = .none
        toTextView.autocorrectionType = .no
        toPlaceholder.text = "Enter recipient address (base58)"
        toPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        toPlaceholder.textColor = .tertiaryLabel

        amountLabel.text = "Amount (token units, e.g. 1.5)"
        amountLabel.font = .preferredFont(forTextStyle: .subheadline)
        amountLabel.textColor = .secondaryLabel
        amountField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        amountField.backgroundColor = UIColor.secondarySystemBackground
        amountField.layer.cornerRadius = 8
        amountField.borderStyle = .none
        amountField.placeholder = "e.g. 1"
        amountField.keyboardType = .decimalPad
        amountField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        amountField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        amountField.leftViewMode = .always
        amountField.rightViewMode = .always

        decimalsLabel.text = "Token Decimals"
        decimalsLabel.font = .preferredFont(forTextStyle: .subheadline)
        decimalsLabel.textColor = .secondaryLabel
        decimalsField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        decimalsField.backgroundColor = UIColor.secondarySystemBackground
        decimalsField.layer.cornerRadius = 8
        decimalsField.borderStyle = .none
        decimalsField.placeholder = "6"
        decimalsField.keyboardType = .numberPad
        decimalsField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        decimalsField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        decimalsField.leftViewMode = .always
        decimalsField.rightViewMode = .always

        createAtaLabel.text = "Create recipient ATA if missing"
        createAtaLabel.font = .preferredFont(forTextStyle: .subheadline)
        createAtaLabel.textColor = .secondaryLabel
        createAtaSwitch.isOn = true

        createButton.setTitle("Create SPL Token Transfer Proposal", for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 10
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        resultStack.axis = .vertical
        resultStack.spacing = 12
        resultStack.alignment = .fill
        resultStack.isHidden = true
        hintLabel.text = "Next: go to Multisig - Activate and enter the Transaction Index above."
        hintLabel.font = .preferredFont(forTextStyle: .caption1)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0
        resultTextView.isEditable = false
        resultTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        resultTextView.backgroundColor = UIColor.secondarySystemBackground
        resultTextView.layer.cornerRadius = 8
        resultTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        copyButton.setTitle("Copy Result", for: .normal)
        copyButton.backgroundColor = .systemGreen
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.layer.cornerRadius = 10
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(multisigPdaLabel)
        contentStack.addArrangedSubview(multisigPdaTextView)
        contentStack.addArrangedSubview(creatorKeyLabel)
        contentStack.addArrangedSubview(creatorKeyTextView)
        contentStack.addArrangedSubview(mintLabel)
        contentStack.addArrangedSubview(mintTextView)
        contentStack.addArrangedSubview(toLabel)
        contentStack.addArrangedSubview(toTextView)
        contentStack.addArrangedSubview(amountLabel)
        contentStack.addArrangedSubview(amountField)
        contentStack.addArrangedSubview(decimalsLabel)
        contentStack.addArrangedSubview(decimalsField)
        let createAtaRow = UIStackView(arrangedSubviews: [createAtaLabel, createAtaSwitch])
        createAtaRow.axis = .horizontal
        createAtaRow.spacing = 12
        createAtaRow.alignment = .center
        contentStack.addArrangedSubview(createAtaRow)
        contentStack.addArrangedSubview(createButton)
        contentStack.addArrangedSubview(resultStack)
        resultStack.addArrangedSubview(hintLabel)
        resultStack.addArrangedSubview(resultTextView)
        resultStack.addArrangedSubview(copyButton)
        view.addSubview(activityIndicator)

        multisigPdaTextView.snp.makeConstraints { make in make.height.equalTo(56) }
        creatorKeyTextView.snp.makeConstraints { make in make.height.equalTo(56) }
        mintTextView.snp.makeConstraints { make in make.height.equalTo(56) }
        toTextView.snp.makeConstraints { make in make.height.equalTo(56) }
        amountField.snp.makeConstraints { make in make.height.equalTo(44) }
        decimalsField.snp.makeConstraints { make in make.height.equalTo(44) }
        resultTextView.snp.makeConstraints { make in make.height.greaterThanOrEqualTo(120) }
        scrollView.snp.makeConstraints { make in make.edges.equalTo(view.safeAreaLayoutGuide) }
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide).offset(-20)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        activityIndicator.snp.makeConstraints { make in make.center.equalToSuperview() }
        creatorKeyTextView.addSubview(creatorKeyPlaceholder)
        creatorKeyPlaceholder.snp.makeConstraints { make in make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 0)) }
        toTextView.addSubview(toPlaceholder)
        toPlaceholder.snp.makeConstraints { make in make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 0)) }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in self?.createButton.isEnabled = success }
        }
    }

    @objc private func createTapped() {
        let multisigPda = (multisigPdaTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let creatorKey = (creatorKeyTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let mint = (mintTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let to = (toTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let amountText = (amountField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let decimalsText = (decimalsField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let decimals = Int(decimalsText).flatMap { $0 >= 0 ? $0 : nil } ?? 6
        guard !multisigPda.isEmpty else { showAlert(title: "Error", message: "Enter Multisig PDA."); return }
        guard !creatorKey.isEmpty else { showAlert(title: "Error", message: "Enter creator private key."); return }
        guard !mint.isEmpty else { showAlert(title: "Error", message: "Enter token mint address."); return }
        guard !to.isEmpty else { showAlert(title: "Error", message: "Enter recipient address."); return }
        guard let amount = Double(amountText), amount >= 0 else { showAlert(title: "Error", message: "Enter a valid amount."); return }
        guard let endpoint = RPCConfigManager.currentEndpoint else { showAlert(title: "Error", message: "No RPC endpoint. Set one in RPC Config first."); return }

        resultStack.isHidden = true
        createButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer { activityIndicator.stopAnimating(); createButton.isEnabled = true }
            let response = await solanaWeb.multisigSendSPLTokenAsync(
                creatorPrivateKey: creatorKey,
                multisigPda: multisigPda,
                mint: mint,
                to: to,
                amount: amount,
                decimals: decimals,
                endpoint: endpoint,
                createAtaIfMissing: createAtaSwitch.isOn
            )
            if let res = response, res["state"] as? Bool == true {
                let txIndex = res["transactionIndex"] as? String ?? ""
                let vaultTxPda = res["vaultTransactionPda"] as? String ?? ""
                let proposalPda = res["proposalPda"] as? String ?? ""
                let vaultTxSig = res["vaultTransactionSignature"] as? String ?? ""
                let proposalSig = res["proposalSignature"] as? String ?? ""
                let vaultPda = res["vaultPda"] as? String ?? ""
                let fromAta = res["fromAta"] as? String ?? ""
                let toAta = res["toAta"] as? String ?? ""
                resultTextView.text = """
                transactionIndex: \(txIndex)
                vaultTransactionPda: \(vaultTxPda)
                proposalPda: \(proposalPda)
                vaultTransactionSignature: \(vaultTxSig)
                proposalSignature: \(proposalSig)
                vaultPda: \(vaultPda)
                fromAta: \(fromAta)
                toAta: \(toAta)
                """
                resultStack.isHidden = false
            } else {
                showAlert(title: "Error", message: (response?["error"] as? String) ?? "Create proposal failed.")
            }
        }
    }

    @objc private func copyTapped() {
        let text = resultTextView.text ?? ""
        if !text.isEmpty {
            UIPasteboard.general.string = text
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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MultisigSendSPLTokenVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === creatorKeyTextView { creatorKeyPlaceholder.isHidden = !(textView.text ?? "").isEmpty }
        if textView === toTextView { toPlaceholder.isHidden = !(textView.text ?? "").isEmpty }
    }
}
