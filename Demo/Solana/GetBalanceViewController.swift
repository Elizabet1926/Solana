//
//  GetBalanceViewController.swift
//  Solana
//
//  Created by Elizabet on 2022/9/26.
//

import Foundation
import SnapKit
import SolanaWeb
enum GetBalanceType: String, CaseIterable {
    case getSOLBalance
    case getSPLTokenBalance
}

class GetBalanceViewController: UIViewController {
    var getBalanceType: GetBalanceType = .getSOLBalance
    lazy var solanaWeb: SolanaWeb3_V1 = {
        let sw = SolanaWeb3_V1()
        return sw
    }()

    lazy var getBalanceBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("getBalance", for: .normal)
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
        label.text = "waiting for get balance..."
        return label
    }()

    lazy var addressField: UITextField = {
        let addressField = UITextField()
        addressField.borderStyle = .line
        addressField.placeholder = "address input"
        addressField.text = "5tzFkiKscXHK5ZXCGbXZxdw7gTjjD1mBwuoFbhUvuAi9"
        return addressField
    }()

    lazy var splTokenAddressTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "SPLToken address input"
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        showAlert()
    }

    deinit {
        print("\(type(of: self)) release")
    }

    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = "get balance"
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
        solanaWeb.getSOLBalance(address: address,endpoint: SolanaMainNet1) { [weak self] state, balance,error in
            guard let self = self else { return }
            self.getBalanceBtn.isEnabled = true
            if state {
                let title = self.getBalanceType == .getSOLBalance ? "SOL Balance: " : "SPLToken Balance: "
                self.balanceLabel.text = title + balance
            } else {
                self.balanceLabel.text = error
            }
        }
    }

    func getSPLTokenBalance(_ address: String, _ splTokenAddress: String) {
        solanaWeb.getSPLTokenBalance(address: address, SPLTokenAddress: splTokenAddress,endpoint: SolanaMainNet1) { [weak self] state, balance,error in
            guard let self = self else { return }
            self.getBalanceBtn.isEnabled = true
            if state {
                let title = self.getBalanceType == .getSOLBalance ? "SOL Balance: " : "SPLToken Balance: "
                self.balanceLabel.text = title + balance
            } else {
                self.balanceLabel.text = error
            }
        }
    }

    @objc func getBalanceAction() {
        getBalanceBtn.isEnabled = false
        balanceLabel.text = "fetching balance ..."
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
