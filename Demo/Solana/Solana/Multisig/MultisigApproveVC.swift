//
//  MultisigApproveVC.swift
//  Solana
//

import UIKit
import SnapKit
import SolanaWeb

final class MultisigApproveVC: UIViewController {

    private let solanaWeb = SolanaWeb()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let multisigPdaLabel = UILabel()
    private let multisigPdaTextView = UITextView()
    private let memberKeyLabel = UILabel()
    private let memberKeyTextView = UITextView()
    private let memberKeyPlaceholder = UILabel()
    private let transactionIndexLabel = UILabel()
    private let transactionIndexField = UITextField()
    private let approveButton = UIButton(type: .system)
    private let resultStack = UIStackView()
    private let resultTextView = UITextView()
    private let copyButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multisig - Approve"
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

        memberKeyLabel.text = "Member Private Key (approver, Base58)"
        memberKeyLabel.font = .preferredFont(forTextStyle: .subheadline)
        memberKeyLabel.textColor = .secondaryLabel
        memberKeyTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        memberKeyTextView.backgroundColor = UIColor.secondarySystemBackground
        memberKeyTextView.layer.cornerRadius = 8
        memberKeyTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        memberKeyTextView.delegate = self
        memberKeyTextView.autocapitalizationType = .none
        memberKeyTextView.autocorrectionType = .no
        memberKeyTextView.isSecureTextEntry = true
        memberKeyPlaceholder.text = "Enter member private key"
        memberKeyPlaceholder.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        memberKeyPlaceholder.textColor = .tertiaryLabel

        transactionIndexLabel.text = "Transaction Index"
        transactionIndexLabel.font = .preferredFont(forTextStyle: .subheadline)
        transactionIndexLabel.textColor = .secondaryLabel
        transactionIndexField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        transactionIndexField.backgroundColor = UIColor.secondarySystemBackground
        transactionIndexField.layer.cornerRadius = 8
        transactionIndexField.borderStyle = .none
        transactionIndexField.placeholder = "e.g. 1"
        transactionIndexField.keyboardType = .numberPad
        transactionIndexField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        transactionIndexField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        transactionIndexField.leftViewMode = .always
        transactionIndexField.rightViewMode = .always

        approveButton.setTitle("Approve Proposal", for: .normal)
        approveButton.backgroundColor = .systemBlue
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.layer.cornerRadius = 10
        approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)

        resultStack.axis = .vertical
        resultStack.spacing = 12
        resultStack.alignment = .fill
        resultStack.isHidden = true
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
        contentStack.addArrangedSubview(memberKeyLabel)
        contentStack.addArrangedSubview(memberKeyTextView)
        contentStack.addArrangedSubview(transactionIndexLabel)
        contentStack.addArrangedSubview(transactionIndexField)
        contentStack.addArrangedSubview(approveButton)
        contentStack.addArrangedSubview(resultStack)
        resultStack.addArrangedSubview(resultTextView)
        resultStack.addArrangedSubview(copyButton)
        view.addSubview(activityIndicator)

        multisigPdaTextView.snp.makeConstraints { make in make.height.equalTo(56) }
        memberKeyTextView.snp.makeConstraints { make in make.height.equalTo(56) }
        transactionIndexField.snp.makeConstraints { make in make.height.equalTo(44) }
        resultTextView.snp.makeConstraints { make in make.height.greaterThanOrEqualTo(80) }
        scrollView.snp.makeConstraints { make in make.edges.equalTo(view.safeAreaLayoutGuide) }
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide).offset(-20)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        activityIndicator.snp.makeConstraints { make in make.center.equalToSuperview() }
        memberKeyTextView.addSubview(memberKeyPlaceholder)
        memberKeyPlaceholder.snp.makeConstraints { make in make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 0)) }
    }

    private func setupSolanaWeb() {
        solanaWeb.setup(showLog: true) { [weak self] success in
            Task { @MainActor in self?.approveButton.isEnabled = success }
        }
    }

    @objc private func approveTapped() {
        let multisigPda = (multisigPdaTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let memberKey = (memberKeyTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let txIndexStr = (transactionIndexField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !multisigPda.isEmpty else { showAlert(title: "Error", message: "Enter Multisig PDA."); return }
        guard !memberKey.isEmpty else { showAlert(title: "Error", message: "Enter member private key."); return }
        guard let txIndex = Int(txIndexStr), txIndex >= 0 else { showAlert(title: "Error", message: "Enter a non-negative Transaction Index."); return }
        guard let endpoint = RPCConfigManager.currentEndpoint else { showAlert(title: "Error", message: "No RPC endpoint. Set one in RPC Config first."); return }

        resultStack.isHidden = true
        approveButton.isEnabled = false
        activityIndicator.startAnimating()
        Task { @MainActor in
            defer { activityIndicator.stopAnimating(); approveButton.isEnabled = true }
            let response = await solanaWeb.proposalApproveAsync(memberPrivateKey: memberKey, multisigPda: multisigPda, transactionIndex: txIndex, endpoint: endpoint)
            if let res = response, res["state"] as? Bool == true {
                let sig = res["signature"] as? String ?? ""
                let proposalPda = res["proposalPda"] as? String ?? ""
                resultTextView.text = "signature: \(sig)\nproposalPda: \(proposalPda)\n\nWhen threshold is met, execute in Multisig - Execute."
                resultStack.isHidden = false
            } else {
                showAlert(title: "Error", message: (response?["error"] as? String) ?? "Approve failed.")
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

extension MultisigApproveVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === memberKeyTextView { memberKeyPlaceholder.isHidden = !(textView.text ?? "").isEmpty }
    }
}
