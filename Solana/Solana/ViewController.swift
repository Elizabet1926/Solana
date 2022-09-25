//
//  ViewController.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//

import UIKit
import SnapKit
class ViewController: UIViewController {
    
    lazy var getSOLBalanceBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("getSOLBalance", for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(getSOLBalance), for: .touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var getSPLTokenBalanceBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("getSPLTokenBalance", for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(getSPLTokenBalance), for: .touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var sendSOLBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("sendSOL", for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(sendSOL), for: .touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var sendSPLTokenBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("sendSPLToken", for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(sendSPLToken), for: .touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        title = "HomePage"
        view.addSubview(getSOLBalanceBtn)
        view.addSubview(getSPLTokenBalanceBtn)
        view.addSubview(sendSOLBtn)
        view.addSubview(sendSPLTokenBtn)
        getSOLBalanceBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.top.equalTo(150)
        }
        getSPLTokenBalanceBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.top.equalTo(getSOLBalanceBtn.snp.bottom).offset(100)
        }
        sendSOLBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.top.equalTo(getSPLTokenBalanceBtn.snp.bottom).offset(100)
        }
        sendSPLTokenBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.top.equalTo(sendSOLBtn.snp.bottom).offset(100)
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
    
}

