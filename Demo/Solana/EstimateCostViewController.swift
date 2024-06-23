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

class EstimateCostViewController: UIViewController {
    lazy var solanaWeb: SolanaWeb3_V1 = {
        let sw = SolanaWeb3_V1()
        return sw
    }()

    lazy var estimateBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Estimate Cost", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(estimatedAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    lazy var sendAddressTextView: UITextView = {
        let textView = UITextView()
        textView.text = "5MJnpb13kxTY5ip9Mz1kNotDWdfG1TMnz4aA39edVYAz"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var reviceAddressField: UITextField = {
        let reviceAddressField = UITextField()
        reviceAddressField.borderStyle = .line
        reviceAddressField.placeholder = "revice address input"
        reviceAddressField.text = "Enx3p7cLUrt4CZeXNvc2hovjir51nN9yn1f81mwVkX7r"
        reviceAddressField.font = UIFont.boldSystemFont(ofSize: 14)
        return reviceAddressField
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
    }

    deinit {
        print("\(type(of: self)) release")
    }
    
    func setupContent() {
        title = "send SOL Estimate Cost"
        view.backgroundColor = .white
        view.addSubviews(estimateBtn, sendAddressTextView, reviceAddressField, amountTextField, estimatedCostLabel)
        estimateBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        estimatedCostLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(estimateBtn.snp.top).offset(-20)
            make.height.equalTo(60)
        }
        sendAddressTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(80)
        }
        
        reviceAddressField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(sendAddressTextView.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(reviceAddressField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func estimatedAction() {
        print("tap estimatedAction")
        if solanaWeb.isGenerateSolanaWebInstanceSuccess {
                estimatedSOLTransferCost()
        } else {
            solanaWeb.setup(showLog: true) { [weak self] _ in
                guard let self = self else { return }
                self.estimatedSOLTransferCost()
            }
        }
    }
    
    func estimatedSOLTransferCost() {
        guard let sendAddress = sendAddressTextView.text,
              let toAddress = reviceAddressField.text,
              let amount = amountTextField.text else { return }
        print("Estimate Cost start.")
        solanaWeb.estimatedSOLTransferCost(fromAddress: sendAddress,
                                           toAddress: toAddress,
                                           amount: amount,
                                           endpoint: SolanaMainNet) { [weak self] state, estimatedSOLTransferCost,error in
            guard let self = self else { return }
            print("Estimate Cost finised.")
            if (state) {
                self.estimatedCostLabel.text = "send SOL estimated cost \(estimatedSOLTransferCost) SOL "
            } else {
                self.estimatedCostLabel.text = error
            }
        }
    }
}
