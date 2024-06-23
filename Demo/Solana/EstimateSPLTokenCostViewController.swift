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

class EstimateSPLTokenCostViewController: UIViewController {
    lazy var solanaWeb: SolanaWeb3_V1 = {
        let sw = SolanaWeb3_V1()
        return sw
    }()
    
    lazy var estimatedBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Estimate Cost", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(estimatedAction), for: .touchUpInside)
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
        reviceAddressField.text = "Enx3p7cLUrt4CZeXNvc2hovjir51nN9yn1f81mwVkX7r"
        return reviceAddressField
    }()
    
    lazy var SPLTokenAddressTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.text = SPLToken.USDT.rawValue
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
    
    lazy var estimatedCostLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Waiting for estimate ..."
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.textColor = .blue
        label.backgroundColor = .lightGray
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
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
        title = "SPLToken Estimate Cost"
        view.backgroundColor = .white
        view.addSubviews(estimatedBtn, privateKeyTextView, reviceAddressField, amountTextField, SPLTokenAddressTextField, estimatedCostLabel)
        estimatedBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        estimatedCostLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(estimatedBtn.snp.top).offset(-20)
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func estimatedAction() {
        print("tap estimated")
        if solanaWeb.isGenerateSolanaWebInstanceSuccess {
            estimatedSPLTokenTransferCost()
        } else {
            solanaWeb.setup(showLog: true) { [weak self] _ in
                guard let self = self else { return }
                self.estimatedSPLTokenTransferCost()
            }
        }
    }
    
    func estimatedSPLTokenTransferCost() {
        guard let privateKey = privateKeyTextView.text,
              let toAddress = reviceAddressField.text,
              let tokenAddress = SPLTokenAddressTextField.text,
              let amount = amountTextField.text else { return }
        solanaWeb.estimatedSPLTokenTransferCost(privateKey: privateKey,
                                                toAddress: toAddress,
                                                mintAddress: tokenAddress,
                                                amount: amount) { [weak self] state, cost,error in
            guard let self = self else { return }
            if (state) {
                self.estimatedCostLabel.text = "sendSPLToken estimated cost \(cost) SOL "
            } else {
                self.estimatedCostLabel.text = error
            }
        }
    }
    
}
