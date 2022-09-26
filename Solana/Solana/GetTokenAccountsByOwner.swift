//
//  GetTokenAccountsByOwner.swift
//  Solana
//
//  Created by Charles on 2022/9/26.
//

import Foundation
import UIKit
class GetTokenAccountsByOwner: UIViewController {
    lazy var solanaWeb: SolanaWeb = {
        let sw = SolanaWeb()
        return sw
    }()

    lazy var getTokenAccountsByOwnerBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("getTokenAccountsByOwner", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()

    lazy var detailTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderColor = UIColor.black.cgColor
        tv.layer.borderWidth = 1.0
        tv.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tv.text = "waiting…"
        return tv
    }()

    lazy var addressField: UITextField = {
        let addressField = UITextField()
        addressField.borderStyle = .line
        addressField.placeholder = "査詢地址輸入框"
        addressField.text = "Enx3p7cLUrt4CZeXNvc2hovjir51nN9yn1f81mwVkX7r"
        return addressField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    deinit {
        print("\(type(of: self)) release")
    }

    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = "TokenAccounts"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(getTokenAccountsByOwnerBtn, addressField, detailTextView)
        getTokenAccountsByOwnerBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        addressField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(40)
        }
        detailTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(addressField.snp.bottom).offset(20)
            make.height.equalTo(300)
        }
    }

    func getTokenAccountsByOwner(_ address: String) {
        solanaWeb.getTokenAccountsByOwner(address: address) { [weak self] state, tokenAccountsJson, _ in
            guard let self = self else { return }
            self.getTokenAccountsByOwnerBtn.isEnabled = true
            if state {
                self.detailTextView.text = tokenAccountsJson
            } else {}
        }
    }

    @objc func btnAction() {
        detailTextView.text = "正在查詢…"
        guard let address = addressField.text else { return }
        getTokenAccountsByOwnerBtn.isEnabled = false
        if solanaWeb.isGenerateSolanaWebInstanceSuccess {
            getTokenAccountsByOwner(address)
        } else {
            solanaWeb.setup(showLog: true) { [weak self] _ in
                guard let self = self else { return }
                self.getTokenAccountsByOwner(address)
            }
        }
    }
}
