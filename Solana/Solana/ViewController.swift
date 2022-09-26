//
//  ViewController.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//

import UIKit
import SnapKit
class ViewController: UIViewController {
    
    let operationTypes = ["getSOLBalance",
                          "getSPLTokenBalance",
                          "getTokenAccountsByOwner",
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
        title = "HomePage"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
