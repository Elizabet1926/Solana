//
//  ViewController.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//

import UIKit
import SnapKit
import SafariServices



class ViewController: UIViewController {
    
    let operationTypes = ["creatWallet",
                          "importAccountFromMnemonic",
                          "importAccountFromPrivateKey",
                          "getSOLBalance",
                          "getSPLTokenBalance",
                          "getTokenAccountsByOwner",
                          "estimatedSOLTransferCost",
                          "estimatedSPLTokenTransferCost",
                          "sendSOL",
                          "sendSPLToken"];
  
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        title = "SolanaWeb"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    @objc func creatWallet() {
        print("creatWallet")
        let vc = CreateWalletViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func importAccountFromMnemonic() {
        print("importAccountFromMnemonic")
        let vc = ImportAccountFromMnemonicViewController()
        navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func importAccountFromPrivateKey() {
        print("importAccountFromPrivateKey")
        let vc = ImportAccountFromPrivateKeyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func sendSOL() {
        let vc = TransferViewController()
        vc.transferType = .sendSOL
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func sendSPLToken() {
        let vc = TransferViewController()
        vc.transferType = .sendSPLToken
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func getSOLBalance() {
        let vc = GetBalanceViewController()
        vc.getBalanceType = .getSOLBalance
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func estimatedSOLTransferCost() {
        let vc = EstimateCostViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func estimatedSPLTokenTransferCost() {
        let vc = EstimateSPLTokenCostViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func getSPLTokenBalance() {
        let vc = GetBalanceViewController()
        vc.getBalanceType = .getSPLTokenBalance
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func getTokenAccountsByOwner() {
        let vc = GetTokenAccountsByOwner()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = operationTypes[indexPath.row]
        let sel = NSSelectorFromString(title)
        self.perform(sel)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operationTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        let title = operationTypes[indexPath.row]
        cell.textLabel?.text = title
        return cell
    }
}
extension UIViewController {
    
    func showAlert() {
        
        let title = "Friendly Reminder"
        let message = "Some Solana endpoints may respond slowly and unreliably. Please purchase a paid node on QuickNode to ensure fast and stable responses; otherwise, you may frequently encounter \"Load failed\" messages."
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Let me see", style: .default) { (_) in
            self.showSafariVC(for: "https://www.quicknode.com/")
        }
        let defaultAction01 = UIAlertAction(title: "Buy later", style: .default) { (_) in
            
        }
        alertController.addAction(defaultAction)
        alertController.addAction(defaultAction01)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}
