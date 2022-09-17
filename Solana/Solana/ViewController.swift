//
//  ViewController.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//

import UIKit
import SnapKit
class ViewController: UIViewController {
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
        view.addSubview(sendSOLBtn)
        view.addSubview(sendSPLTokenBtn)
        sendSOLBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.top.equalTo(300)
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
}

