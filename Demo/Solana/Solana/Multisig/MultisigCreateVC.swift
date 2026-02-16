//
//  MultisigCreateVC.swift
//  Solana
//

import UIKit
import SnapKit

final class MultisigCreateVC: UIViewController {

    private let solanaWeb = SolanaWeb()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let creatorKeyLabel = UILabel()
    private let creatorKeyTextView = UITextView()
    private let creatorKeyPlaceholder = UILabel()

    private let membersLabel = UILabel()
    private let membersTextView = UITextView()
    private let membersPlaceholder = UILabel()

    private let thresholdLabel = UILabel()
    private let thresholdStepper = UIStepper()
    private let thresholdValueLabel = UILabel()

    private let nameLabel = UILabel()
    private let nameField = UITextField()

    private let createButton = UIButton(type: .system)

    private let resultStack = UIStackView()
    private let warningLabel = UILabel()
    private let vaultFundingWarningLabel = UILabel()
    private let memberBalanceWarningLabel = UILabel()
    private let resultTextView = UITextView()
    private let explainParamsButton = UIButton(type: .system)
    private let copyAllButton = UIButton(type: .system)

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var lastResult: (multisigPda: String, vaultPda: String, createKey: String, createKeyPrivateKey: String, signature: String)?
    private var memberCount: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multisig - Create"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "View Guide", style: .plain, target: self, action: #selector(showMultisigGuideTapped))
        setupUI()
        setupSolanaWeb()
        updateThresholdUI()
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
        creatorKeyPlaceholder.text = "Enter creator private key (base58)"
        creatorKeyPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        creatorKeyPlaceholder.textColor = .tertiaryLabel

        membersLabel.text = "Member Public Keys (one per line, ≥2)"
        membersLabel.font = .preferredFont(forTextStyle: .subheadline)
        membersLabel.textColor = .secondaryLabel
        membersTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        membersTextView.backgroundColor = UIColor.secondarySystemBackground
        membersTextView.layer.cornerRadius = 8
        membersTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        membersTextView.delegate = self
        membersTextView.autocapitalizationType = .none
        membersTextView.autocorrectionType = .no
        membersPlaceholder.text = "Public key 1\nPublic key 2\n..."
        membersPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        membersPlaceholder.textColor = .tertiaryLabel
        membersPlaceholder.numberOfLines = 0

        thresholdLabel.text = "Threshold (signatures required)"
        thresholdLabel.font = .preferredFont(forTextStyle: .subheadline)
        thresholdLabel.textColor = .secondaryLabel
        thresholdStepper.minimumValue = 1
        thresholdStepper.maximumValue = 2
        thresholdStepper.value = 2
        thresholdStepper.stepValue = 1
        thresholdStepper.addTarget(self, action: #selector(thresholdStepperChanged), for: .valueChanged)
        thresholdValueLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        thresholdValueLabel.textColor = .label

        nameLabel.text = "Name (optional)"
        nameLabel.font = .preferredFont(forTextStyle: .subheadline)
        nameLabel.textColor = .secondaryLabel
        nameField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        nameField.backgroundColor = UIColor.secondarySystemBackground
        nameField.layer.cornerRadius = 8
        nameField.borderStyle = .none
        nameField.placeholder = "e.g. Team Multisig"
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        nameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        nameField.leftViewMode = .always
        nameField.rightViewMode = .always
        nameField.autocapitalizationType = .none
        nameField.autocorrectionType = .no

        createButton.setTitle("Create Multisig", for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 10
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        resultStack.axis = .vertical
        resultStack.spacing = 12
        resultStack.alignment = .fill
        resultStack.isHidden = true
        warningLabel.text = "⚠️ Save the CreateKey Private Key for recovery only; the rest of the flow only uses multisigPda and vaultPda."
        warningLabel.font = .preferredFont(forTextStyle: .caption1)
        warningLabel.textColor = .systemOrange
        warningLabel.numberOfLines = 0
        vaultFundingWarningLabel.text = "⚠️ You must send SOL to vaultPda (address above) before any SOL transfer can be executed. Minimum: more than the rent (~0.0025 SOL). Recommended: at least twice the rent (e.g. ≥0.005 SOL) to cover rent and fees. Otherwise proposals will fail at execution."
        vaultFundingWarningLabel.font = .preferredFont(forTextStyle: .caption1)
        vaultFundingWarningLabel.textColor = .systemOrange
        vaultFundingWarningLabel.numberOfLines = 0
        memberBalanceWarningLabel.text = "⚠️ On mainnet, the creator and every member address must have some SOL (e.g. ≥0.001–0.005 SOL each). If any of these addresses has zero balance, execution will fail with \"insufficient funds for rent\"."
        memberBalanceWarningLabel.font = .preferredFont(forTextStyle: .caption1)
        memberBalanceWarningLabel.textColor = .systemOrange
        memberBalanceWarningLabel.numberOfLines = 0
        resultTextView.isEditable = false
        resultTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        resultTextView.backgroundColor = UIColor.secondarySystemBackground
        resultTextView.layer.cornerRadius = 8
        resultTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        explainParamsButton.setTitle("Explain Parameters", for: .normal)
        explainParamsButton.setTitleColor(.systemBlue, for: .normal)
        explainParamsButton.addTarget(self, action: #selector(explainParamsTapped), for: .touchUpInside)
        copyAllButton.setTitle("Copy All", for: .normal)
        copyAllButton.backgroundColor = .systemGreen
        copyAllButton.setTitleColor(.white, for: .normal)
        copyAllButton.layer.cornerRadius = 10
        copyAllButton.addTarget(self, action: #selector(copyAllTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(creatorKeyLabel)
        contentStack.addArrangedSubview(creatorKeyTextView)
        contentStack.addArrangedSubview(membersLabel)
        contentStack.addArrangedSubview(membersTextView)
        contentStack.addArrangedSubview(thresholdLabel)
        let thresholdRow = UIStackView(arrangedSubviews: [thresholdStepper, thresholdValueLabel])
        thresholdRow.axis = .horizontal
        thresholdRow.spacing = 12
        thresholdRow.alignment = .center
        contentStack.addArrangedSubview(thresholdRow)
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(nameField)
        contentStack.addArrangedSubview(createButton)
        contentStack.addArrangedSubview(resultStack)
        view.addSubview(activityIndicator)

        resultStack.addArrangedSubview(warningLabel)
        resultStack.addArrangedSubview(vaultFundingWarningLabel)
        resultStack.addArrangedSubview(memberBalanceWarningLabel)
        resultStack.addArrangedSubview(resultTextView)
        resultStack.addArrangedSubview(explainParamsButton)
        resultStack.addArrangedSubview(copyAllButton)

        creatorKeyTextView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        membersTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }
        nameField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide).offset(-20)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        resultTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(180)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        creatorKeyTextView.addSubview(creatorKeyPlaceholder)
        creatorKeyPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 0))
        }
        membersTextView.addSubview(membersPlaceholder)
        membersPlaceholder.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 0))
        }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in
                self?.createButton.isEnabled = success
            }
        }
    }

    private func updateThresholdUI() {
        let n = max(2, memberCount)
        thresholdStepper.maximumValue = Double(n)
        if Int(thresholdStepper.value) > n {
            thresholdStepper.value = Double(n)
        }
        thresholdValueLabel.text = "\(Int(thresholdStepper.value)) / \(n)"
    }

    @objc private func thresholdStepperChanged() {
        let n = max(2, memberCount)
        thresholdValueLabel.text = "\(Int(thresholdStepper.value)) / \(n)"
    }

    private func parsedMembers() -> [String] {
        let text = membersTextView.text ?? ""
        return text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    @objc private func createTapped() {
        let creatorKey = (creatorKeyTextView.text ?? "").trimmingCharacters(in: .whitespaces)
        let members = parsedMembers()
        let threshold = Int(thresholdStepper.value)
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespaces)
        if creatorKey.isEmpty {
            showAlert(title: "Error", message: "Enter creator private key.")
            return
        }
        if members.count < 2 {
            showAlert(title: "Error", message: "Enter at least 2 member public keys (one per line).")
            return
        }
        if threshold < 1 || threshold > members.count {
            showAlert(title: "Error", message: "Threshold must be between 1 and \(members.count).")
            return
        }
        guard let endpoint = RPCConfigManager.currentEndpoint else {
            showAlert(title: "Error", message: "No RPC endpoint. Set one in RPC Config first.")
            return
        }

        resultStack.isHidden = true
        createButton.isEnabled = false
        activityIndicator.startAnimating()

        Task { @MainActor in
            defer {
                activityIndicator.stopAnimating()
                createButton.isEnabled = true
            }
            let nameArg: String? = name.isEmpty ? nil : name
            let response = await solanaWeb.createMultisigAsync(
                creatorPrivateKey: creatorKey,
                members: members,
                threshold: threshold,
                endpoint: endpoint,
                name: nameArg
            )
            if let res = response, res["state"] as? Bool == true {
                let multisigPda = res["multisigPda"] as? String ?? ""
                let vaultPda = res["vaultPda"] as? String ?? ""
                let createKey = res["createKey"] as? String ?? ""
                let createKeyPrivateKey = res["createKeyPrivateKey"] as? String ?? ""
                let signature = res["signature"] as? String ?? ""
                lastResult = (multisigPda, vaultPda, createKey, createKeyPrivateKey, signature)
                let display = """
                multisigPda: \(multisigPda)
                vaultPda: \(vaultPda)
                createKey: \(createKey)
                createKeyPrivateKey: \(createKeyPrivateKey)
                signature: \(signature)
                """
                resultTextView.text = display
                resultStack.isHidden = false
            } else {
                let message = (response?["error"] as? String) ?? "Failed to create multisig"
                showAlert(title: "Error", message: message)
            }
        }
    }

    @objc private func explainParamsTapped() {
        let vc = ExplainWebVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    @objc private func copyAllTapped() {
        if lastResult != nil {
            let text = resultTextView.text ?? ""
            UIPasteboard.general.string = text
            showCopiedToast()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

extension MultisigCreateVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === membersTextView {
            memberCount = parsedMembers().count
            if memberCount < 2 { memberCount = 2 }
            updateThresholdUI()
        }
        if textView === creatorKeyTextView {
            creatorKeyPlaceholder.isHidden = !(textView.text ?? "").isEmpty
        } else if textView === membersTextView {
            membersPlaceholder.isHidden = !(textView.text ?? "").isEmpty
        }
    }
}
