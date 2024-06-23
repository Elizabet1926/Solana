

import SolanaWeb
import UIKit

class CreateWalletViewController: UIViewController {
    lazy var solanaWeb: SolanaWeb3_V1 = {
        let sw = SolanaWeb3_V1()
        return sw
    }()

    lazy var createWalletBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("createWallet", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(createWalletAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()

    lazy var walletDetailTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()

    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "wait for create Wallet"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }

    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = "Create Wallet"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(createWalletBtn, walletDetailTextView, tipLabel)
        createWalletBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        walletDetailTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(300)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(createWalletBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc func createWalletAction() {
        createWalletBtn.isEnabled = false
        tipLabel.text = "creating ..."
        
        if solanaWeb.isGenerateSolanaWebInstanceSuccess {
            createWallet()
            
        } else {
            solanaWeb.setup(showLog: true) { [weak self] _ in
                guard let self = self else { return }
                self.createWallet()
            }
        }
    }

    func createWallet() {
        solanaWeb.createWallet() { [weak self] state, address, privateKey, mnemonic,error in
            guard let self = self else { return }
            self.createWalletBtn.isEnabled = true
            tipLabel.text = "create finished."
            if state {
                let text =
                    "address: " + address + "\n\n" +
                    "mnemonic: " + mnemonic + "\n\n" +
                    "privateKey: " + privateKey
                walletDetailTextView.text = text
            } else {
                walletDetailTextView.text = error
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) release")
    }
}
