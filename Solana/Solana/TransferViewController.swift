//
//  TransferViewController.swift
//  Solana
//
//  Created by Charles on 2022/9/16.
//

import Foundation
import SafariServices
import SnapKit
import UIKit
  
let margin: CGFloat = 20.0

enum TransferType: String, CaseIterable {
    case sendSOL
    case sendSPLToken
}

class TransferViewController: UIViewController {
    var transferType: TransferType = .sendSOL
    lazy var solanaWeb: SolanaWeb = {
        let sw = SolanaWeb()
        return sw
    }()

    lazy var transferBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("轉帳", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(transferAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var privateKeyTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var reviceAddressField: UITextField = {
        let reviceAddressField = UITextField()
        reviceAddressField.borderStyle = .line
        reviceAddressField.placeholder = "收款地址輸入框"
        reviceAddressField.text = "Enx3p7cLUrt4CZeXNvc2hovjir51nN9yn1f81mwVkX7r"
        return reviceAddressField
    }()
    
    lazy var SPLTokenAddressTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "請輸入SPLToken地址"
        return textField
    }()
    
    lazy var amountTextField: UITextField = {
        let amountTextField = UITextField()
        amountTextField.borderStyle = .line
        amountTextField.keyboardType = .numberPad
        amountTextField.placeholder = "金額輸入框"
        amountTextField.text = "0.0001"
        return amountTextField
    }()
    
    lazy var hashLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "交易hash值"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.textColor = .blue
        label.backgroundColor = .lightGray
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var detailBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("査詢交易詳情", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(queryAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        // Do any additional setup after loading the view.
    }

    deinit {
        print("\(type(of: self)) release")
    }
    
    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(transferBtn, privateKeyTextView, reviceAddressField, amountTextField, SPLTokenAddressTextField, hashLabel, detailBtn)
        transferBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        detailBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(transferBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
        hashLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(detailBtn.snp.top).offset(-20)
            make.height.equalTo(60)
        }
        privateKeyTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(80)
        }
        
        reviceAddressField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(privateKeyTextView.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(reviceAddressField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
       
        SPLTokenAddressTextField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(amountTextField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
       
        SPLTokenAddressTextField.isHidden = transferType == .sendSOL
        SPLTokenAddressTextField.text = SPLToken.USDT.rawValue
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func transferAction() {
        print("点击了转账")
        if solanaWeb.isGenerateSolanaWebInstanceSuccess {
            transferType == .sendSOL ? sendSOL() : sendSPLToken()
        } else {
            solanaWeb.setup(showLog: true) { [weak self] _ in
                guard let self = self else { return }
                self.transferType == .sendSOL ? self.sendSOL() : self.sendSPLToken()
            }
        }
    }

    func sendSOL() {
        guard let privateKey = privateKeyTextView.text,
              let toAddress = reviceAddressField.text,
              let amount = amountTextField.text else { return }
        solanaWeb.solanaTransfer(privateKey: privateKey, toAddress: toAddress, amount: amount, endpoint: SolanaMainNet) { [weak self] state, txid in
            guard let self = self else { return }
            print("state = \(state)")
            print("txid = \(txid)")
            self.hashLabel.text = txid
        }
    }
    
    func sendSPLToken() {
        guard let privateKey = privateKeyTextView.text,
              let toAddress = reviceAddressField.text,
              let tokenAddress = SPLTokenAddressTextField.text,
              let amount = amountTextField.text else { return }
        solanaWeb.solanaTokenTransfer(privateKey: privateKey, toAddress: toAddress, mintAuthority: tokenAddress, amount: amount, endpoint: SolanaMainNet) { [weak self] state, txid in
            guard let self = self else { return }
            print("state = \(state)")
            print("txid = \(txid)")
            self.hashLabel.text = txid
        }
    }
    
    @objc func queryAction() {
        guard let hash = hashLabel.text, hash.count > 10 else { return }
        let urlString = "https://solscan.io/tx/" + hash
        showSafariVC(for: urlString)
    }
    
    func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}

public extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for index in subviews {
            addSubview(index)
        }
    }
}
