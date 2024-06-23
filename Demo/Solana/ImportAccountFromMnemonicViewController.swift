
import UIKit
import SolanaWeb
class ImportAccountFromMnemonicViewController: UIViewController {
    lazy var solanaWeb: SolanaWeb3_V1 = {
        let sw = SolanaWeb3_V1()
        return sw
    }()

    lazy var importAccountFromMnemonicBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("import Account From Mnemonic", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(importAccountFromMnemonicAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    lazy var mnemonicTextView: UITextView = {
        let textView = UITextView()
        textView.text = "tomato sad dinosaur icon eye task move steel imitate worry brass world"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
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
        label.text = "waiting for import Account From Mnemonic"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    deinit {
        print("\(type(of: self)) release")
    }

    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = "import Account From Mnemonic"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(importAccountFromMnemonicBtn,mnemonicTextView, walletDetailTextView, tipLabel)
        importAccountFromMnemonicBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        mnemonicTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(100)
            make.height.equalTo(100)
        }
        walletDetailTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(mnemonicTextView.snp.bottom).offset(20)
            make.height.equalTo(300)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(importAccountFromMnemonicBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc func importAccountFromMnemonicAction() {
        importAccountFromMnemonicBtn.isEnabled = false
        tipLabel.text = "importing ..."
        if solanaWeb.isGenerateSolanaWebInstanceSuccess {
            importAccountFromMnemonic()
            
        } else {
            solanaWeb.setup(showLog: true) { [weak self] _ in
                guard let self = self else { return }
                self.importAccountFromMnemonic()
            }
        }
    }

    func importAccountFromMnemonic() {
        guard let mnemonic = mnemonicTextView.text else{return}
        solanaWeb.importAccountFromMnemonic (mnemonic: mnemonic){ [weak self] state, address, privateKey, publicKey, error in
            guard let self = self else { return }
            self.importAccountFromMnemonicBtn.isEnabled = true
            tipLabel.text = "import finished."
            if state {
                let text =
                    "address: " + address + "\n\n" +
                    "privateKey: " + privateKey + "\n\n" +
                    "publicKey: " + publicKey
                walletDetailTextView.text = text
            } else {
                walletDetailTextView.text = error
            }
        }
    }
    

}
