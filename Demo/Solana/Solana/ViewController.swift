//
//  ViewController.swift
//  Solana
//

import UIKit

final class ViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return t
    }()

    /// Sections: Config / Wallet / Balance / Transfer / Multisig / Signature
    private let sections: [(sectionTitle: String, items: [(title: String, vcType: UIViewController.Type)])] = [
        ("Config", [
            ("RPC Config", RPCConfigVC.self),
        ]),
        ("Wallet", [
            ("Create Wallet", CreateWalletVC.self),
            ("Import Account (Mnemonic)", ImportMnemonicVC.self),
            ("Import Account (Private Key)", ImportPrivateKeyVC.self),
        ]),
        ("Balance", [
            ("SOL Balance", SOLBalanceVC.self),
            ("Token Account List", TokenListVC.self),
            ("SPL Token Balance", TokenBalanceVC.self),
        ]),
        ("Transfer", [
            ("Send SOL", SendSOLVC.self),
            ("Send SPL Token", SendSPLTokenVC.self),
        ]),
        ("Multisig", [
            ("Multisig - Create", MultisigCreateVC.self),
            ("Multisig - Send SOL", MultisigSendSOLVC.self),
            ("Multisig - Send SPL Token", MultisigSendSPLTokenVC.self),
            ("Multisig - Activate", MultisigActivateVC.self),
            ("Multisig - Approve", MultisigApproveVC.self),
            ("Multisig - Execute", MultisigExecuteVC.self),
            ("Multisig - Proposal Status", MultisigProposalStatusVC.self),
        ]),
        ("Signature", [
            ("Sign Message", SignMessageVC.self),
            ("Verify Signature", VerifySignatureVC.self),
        ]),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Solana Wallet"
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].sectionTitle
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcType = sections[indexPath.section].items[indexPath.row].vcType
        let vc = vcType.init()
        navigationController?.pushViewController(vc, animated: true)
    }
}
