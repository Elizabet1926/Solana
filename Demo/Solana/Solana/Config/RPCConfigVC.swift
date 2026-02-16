//
//  RPCConfigVC.swift
//  Solana
//

import UIKit
import SnapKit

final class RPCConfigVC: UIViewController {

    private static let defaultCustomRPCURL = "https://solana.maiziqianbao.net"

    private enum PresetIndex: Int {
        case devnet = 0
        case mainnetBeta = 1
        case custom = 2
    }

    private let networkSegment: UISegmentedControl = {
        let items = ["Devnet", "Mainnet Beta", "Custom"]
        let s = UISegmentedControl(items: items)
        s.selectedSegmentIndex = 0
        return s
    }()

    private let customURLLabel: UILabel = {
        let l = UILabel()
        l.text = "Custom RPC URL"
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        return l
    }()

    private let customURLField: UITextField = {
        let t = UITextField()
        t.placeholder = "https://your-rpc.com or https://mainnet.helius-rpc.com/?api-key=KEY"
        t.borderStyle = .roundedRect
        t.autocapitalizationType = .none
        t.autocorrectionType = .no
        t.keyboardType = .URL
        t.returnKeyType = .done
        return t
    }()

    private let hintLabel: UILabel = {
        let l = UILabel()
        l.text = "For mainnet, use a custom RPC (e.g. Helius, QuickNode, Alchemy) with an API key."
        l.font = .preferredFont(forTextStyle: .caption1)
        l.textColor = .tertiaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let applyButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Apply RPC"
        config.cornerStyle = .medium
        let b = UIButton(type: .system)
        b.configuration = config
        return b
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .footnote)
        l.numberOfLines = 0
        l.text = "Status: Not connected"
        l.textColor = .secondaryLabel
        return l
    }()

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.keyboardDismissMode = .onDrag
        return s
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.alignment = .fill
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RPC Config"
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(networkSegment)
        contentStack.addArrangedSubview(customURLLabel)
        contentStack.addArrangedSubview(customURLField)
        contentStack.addArrangedSubview(hintLabel)
        contentStack.addArrangedSubview(applyButton)
        contentStack.addArrangedSubview(statusLabel)

        customURLLabel.isHidden = true
        customURLField.isHidden = true
        hintLabel.isHidden = true

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(20)
            make.leading.equalTo(scrollView.contentLayoutGuide).offset(20)
            make.trailing.equalTo(scrollView.contentLayoutGuide).offset(-20)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide).offset(-20)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }

        networkSegment.addTarget(self, action: #selector(networkSegmentChanged), for: .valueChanged)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        customURLField.delegate = self

        loadSavedConfig()
        updateStatusFromManager()
    }

    private func loadSavedConfig() {
        let idx = RPCConfigManager.selectedPresetIndex
        networkSegment.selectedSegmentIndex = min(max(idx, 0), 2)
        let saved = RPCConfigManager.customURL?.trimmingCharacters(in: .whitespacesAndNewlines)
        customURLField.text = saved?.isEmpty == false ? saved : Self.defaultCustomRPCURL
        networkSegmentChanged()
    }

    @objc private func networkSegmentChanged() {
        let isCustom = networkSegment.selectedSegmentIndex == PresetIndex.custom.rawValue
        customURLLabel.isHidden = !isCustom
        customURLField.isHidden = !isCustom
        hintLabel.isHidden = !isCustom
        if isCustom && (customURLField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            customURLField.text = Self.defaultCustomRPCURL
        }
    }

    @objc private func applyTapped() {
        view.endEditing(true)
        let presetIndex = networkSegment.selectedSegmentIndex
        let custom: String? = presetIndex == PresetIndex.custom.rawValue
            ? customURLField.text?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            : nil

        if presetIndex == PresetIndex.custom.rawValue && (custom == nil || custom?.isEmpty == true) {
            statusLabel.text = "Status: Enter a custom RPC URL"
            statusLabel.textColor = .systemOrange
            return
        }

        RPCConfigManager.save(presetIndex: presetIndex, customURL: custom)
        guard let endpoint = RPCConfigManager.currentEndpoint else {
            statusLabel.text = "Status: No endpoint"
            statusLabel.textColor = .systemRed
            return
        }

        statusLabel.text = "Status: Connecting..."
        statusLabel.textColor = .secondaryLabel
        applyButton.isEnabled = false

        Task { @MainActor in
            do {
                let version = try await RPCConfigManager.checkConnection(endpoint: endpoint)
                statusLabel.text = "Status: Connected (\(endpoint))\nVersion: \(version)"
                statusLabel.textColor = .systemGreen
            } catch {
                statusLabel.text = "Status: \(error.localizedDescription)"
                statusLabel.textColor = .systemRed
            }
            applyButton.isEnabled = true
        }
    }

    private func updateStatusFromManager() {
        guard let endpoint = RPCConfigManager.currentEndpoint else {
            statusLabel.text = "Status: Not connected"
            statusLabel.textColor = .secondaryLabel
            return
        }
        statusLabel.text = "Status: Endpoint set to \(endpoint). Tap Apply to verify."
        statusLabel.textColor = .secondaryLabel
    }
}

extension RPCConfigVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
