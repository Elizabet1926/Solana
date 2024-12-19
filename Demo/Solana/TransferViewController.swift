//
//  TransferViewController.swift
//  Solana
//
//  Created by Elizabet on 2022/9/16.
//

import Foundation
import SafariServices
import SnapKit
import UIKit
import SolanaWeb
let margin: CGFloat = 20.0

enum TransferType: String, CaseIterable {
    case sendSOL
    case sendSPLToken
}

class TransferViewController: UIViewController {
    var transferType: TransferType = .sendSOL
    lazy var solanaWeb: SolanaWeb3_V1 = {
        let sw = SolanaWeb3_V1()
        return sw
    }()

    lazy var transferBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("transfer", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(transferAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    lazy var privateKeyTextView: UITextView = {
        let textView = UITextView()
        let p1 = "55r9gYDZPnRPyaBZfZvLnFzUTkox16bqC7byKPonJj1M7C"
        let p2 = "BXQHXhBs6duKYZGgHbrHpaSDeUrBrai3mhAGVQf8Ca"
        textView.text = p1 + p2
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var reviceAddressField: UITextField = {
        let reviceAddressField = UITextField()
        reviceAddressField.borderStyle = .line
        reviceAddressField.placeholder = "revice address input"
        reviceAddressField.text = "EgKvrWmdXZSddhW1NjfcN8nooVnr4xRLrXWyYbWJ8X93"
        return reviceAddressField
    }()
    
    lazy var SPLTokenAddressTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "SPLToken address input"
        return textField
    }()
    
    lazy var amountTextField: UITextField = {
        let amountTextField = UITextField()
        amountTextField.borderStyle = .line
        amountTextField.keyboardType = .numberPad
        amountTextField.placeholder = "amount input"
        amountTextField.text = "0.00001"
        return amountTextField
    }()
    
    lazy var hashLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Signature..."
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
        btn.setTitle("Get detail in solscan.io", for: .normal)
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
        showAlert()
        // Do any additional setup after loading the view.
    }

    deinit {
        print("\(type(of: self)) release")
    }
    
    func setupContent() {
        title = transferType.rawValue
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
        print("tap transfer")
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
        solanaWeb.solanaTransfer(privateKey: privateKey,
                                 toAddress: toAddress,
                                 amount: amount,
                                 endpoint: SolanaMainNet1) { [weak self] state, txid,error in
            guard let self = self else { return }
            print("state = \(state)")
            print("txid = \(txid)")
            if (state) {
                self.hashLabel.text = txid
            } else {
                self.hashLabel.text = error
            }
        }
    }
    
    func sendSPLToken() {
        guard let privateKey = privateKeyTextView.text,
              let toAddress = reviceAddressField.text,
              let tokenAddress = SPLTokenAddressTextField.text,
              let amount = amountTextField.text else { return }
        solanaWeb.solanaTokenTransfer(privateKey: privateKey,
                                      toAddress: toAddress,
                                      mintAuthority: tokenAddress,
                                      amount: amount,
                                      endpoint: SolanaMainNet1) { [weak self] state, txid,error in
            guard let self = self else { return }
            print("state = \(state)")
            print("txid = \(txid)")
            if (state) {
                self.hashLabel.text = txid
            } else {
                self.hashLabel.text = error
            }
        }
    }
    
    @objc func queryAction() {
        guard let hash = hashLabel.text, hash.count > 10 else { return }
        let urlString = "https://solscan.io/tx/" + hash
        showSafariVC(for: urlString)
    }
}

public extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for index in subviews {
            addSubview(index)
        }
    }
}
