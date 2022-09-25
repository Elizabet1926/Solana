//
//  GetBalanceViewController.swift
//  Solana
//
//  Created by Charles on 2022/9/26.
//

import Foundation
import SnapKit

enum GetBalanceType: String, CaseIterable {
    case getSOLBalance
    case getSPLTokenBalance
}

class GetBalanceViewController: UIViewController {
    var getBalanceType: GetBalanceType = .getSOLBalance
    lazy var solanaWeb: SolanaWeb = {
        let sw = SolanaWeb()
        return sw
    }()

    lazy var getBalanceBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("餘額查詢", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(getBalanceAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()

    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "等待查詢餘額…"
        return label
    }()

    lazy var addressField: UITextField = {
        let addressField = UITextField()
        addressField.borderStyle = .line
        addressField.placeholder = "査詢地址輸入框"
        addressField.text = "Enx3p7cLUrt4CZeXNvc2hovjir51nN9yn1f81mwVkX7r"
        return addressField
    }()

    lazy var splTokenAddressTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "請輸入SPLToken地址"
        return textField
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
        title = "獲取餘額"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(getBalanceBtn, addressField, splTokenAddressTextField, balanceLabel)
        getBalanceBtn.snp.makeConstraints { make in
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
        balanceLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(getBalanceBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
        splTokenAddressTextField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(addressField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }

        splTokenAddressTextField.isHidden = getBalanceType == .getSOLBalance
        splTokenAddressTextField.text = SPLToken.USDT.rawValue
    }

    func getSOLBalance(_ address: String) {
        solanaWeb.getSOLBalance(address: address) { [weak self] state, balance in
            guard let self = self else { return }
            self.getBalanceBtn.isEnabled = true
            if state {
                let title = self.getBalanceType == .getSOLBalance ? "SOL餘額：" :"SPLToken餘額："
                self.balanceLabel.text = title + balance
            } else {}
        }
    }

    func getSPLTokenBalance(_ address: String, _ splTokenAddress: String) {
        solanaWeb.getSPLTokenBalance(address: address,SPLTokenAddress: splTokenAddress) { [weak self] state, balance in
            guard let self = self else { return }
            self.getBalanceBtn.isEnabled = true
            if state {
                let title = self.getBalanceType == .getSOLBalance ? "SOL餘額：" :"SPLToken餘額："
                self.balanceLabel.text = title + balance
            } else {}
        }
    }

    @objc func getBalanceAction() {
        getBalanceBtn.isEnabled = false
        balanceLabel.text = "正在查詢餘額…"
        guard let address = addressField.text, let splTokenAddress = splTokenAddressTextField.text else { return }

        if solanaWeb.isGenerateSolanaWebInstanceSuccess {
            getBalanceType == .getSOLBalance ? getSOLBalance(address) : getSPLTokenBalance(address, splTokenAddress)
        } else {
            solanaWeb.setup(showLog: true) { [weak self] _ in
                guard let self = self else { return }
                self.getBalanceType == .getSOLBalance ? self.getSOLBalance(address) : self.getSPLTokenBalance(address, splTokenAddress)
            }
        }
    }
}