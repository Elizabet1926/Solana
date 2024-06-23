//
//  GetTokenAccountsByOwner.swift
//  Solana
//
//  Created by Elizabet on 2022/9/26.
//

import Foundation
import UIKit
import SolanaWeb
class GetTokenAccountsByOwner: UIViewController {
    lazy var solanaWeb: SolanaWeb3_V1 = {
        let sw = SolanaWeb3_V1()
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
        addressField.placeholder = "address input"
        addressField.text = "5tzFkiKscXHK5ZXCGbXZxdw7gTjjD1mBwuoFbhUvuAi9"
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
        showAlert()
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
        solanaWeb.getTokenAccountsByOwner(address: address) { [weak self] state, tokenAccountsJson,error in
            guard let self = self else { return }
            self.getTokenAccountsByOwnerBtn.isEnabled = true
            if state {
                self.detailTextView.text = tokenAccountsJson
            } else {
                self.detailTextView.text = error
            }
        }
    }

    @objc func btnAction() {
        detailTextView.text = "fetching..."
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
