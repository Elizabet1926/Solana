# SolanaWeb
**SolanaWeb** is an iOS toolbelt for interaction with the Solana network.

![language](https://img.shields.io/badge/Language-Swift-green)
[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-FB7DEC.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![CocoaPods](https://img.shields.io/badge/support-Cocoapods-green)](https://cocoapods.org/pods/SolanaWeb)
[![CocoaPods](https://img.shields.io/badge/support-SwiftPackageManagr-green)](https://www.swift.org/getting-started/#using-the-package-manager)

![](Resource/Demo01.png)

For more specific usage, please refer to the [demo](https://github.com/Elizabet1926/Solana/tree/master/Demo)

###  CocoaPods

```ruby
pod 'SolanaWeb', '~> 1.0.6'
```

### Swift Package Manager

```ruby
dependencies: [
    .package(url: "https://github.com/Elizabet1926/Solana.git", .upToNextMajor(from: "1.0.7"))
]
```

### Example usage

```swift
import SolanaWeb
```

##### Setup SolanaWeb
```swift
let solanaWeb = SolanaWeb3_V1()
if solanaWeb.isGenerateSolanaWebInstanceSuccess {
   transferType == .sendSOL ? sendSOL() : sendSPLToken()
} else {
   solanaWeb.setup(showLog: true) { [weak self] _ in
      guard let self = self else { return }
      self.transferType == .sendSOL ? self.sendSOL() : self.sendSPLToken()
   }
}
```

##### Create Wallet
```swift
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
```

##### Import Account From Mnemonic
```swift
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
```
##### Import Account From PrivateKey
```swift
guard let privateKey = privateKeyTextView.text else{return}
solanaWeb.importAccountFromPrivateKey(privateKey: privateKey){ [weak self] state, address, privateKey,error in
    guard let self = self else { return }
    self.importAccountFromPrivateKeyBtn.isEnabled = true
    tipLabel.text = "import finished."
    if state {
        let text =
            "address: " + address + "\n\n" +
            "privateKey: " + privateKey
        walletDetailTextView.text = text
    } else {
        walletDetailTextView.text = error
    }
}
```

##### Estimate Cost with Send SOL
```swift
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
```

##### Send SOL
```swift
let privateKey = ""
let toAddress = ""
let amount = ""
solanaWeb.solanaTransfer(privateKey: privateKey, toAddress: toAddress, amount: amount, endpoint: SolanaMainNet) { [weak self] state, txid, error in
    guard let self = self else { return }
    print("state = \(state)")
    print("txid = \(txid)")
    if (state) {
        self.hashLabel.text = txid
     } else {
        self.hashLabel.text = error
     }
} 
```

##### Estimate Cost with Send SPLToken
```swift
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
```
##### Send SPLToken
```swift
let privateKey = ""
let toAddress = ""
let tokenAddress = ""
let amount = ""
solanaWeb.solanaTokenTransfer(privateKey: privateKey, toAddress: toAddress, mintAuthority: tokenAddress, amount: amount, endpoint: SolanaMainNet) { [weak self] state, txid, error in
    guard let self = self else { return }
    print("state = \(state)")
    print("txid = \(txid)")
    if (state) {
        self.hashLabel.text = txid
     } else {
        self.hashLabel.text = error
     }
}
```

For more specific usage, please refer to the [demo](https://github.com/Elizabet1926/Solana/tree/master/Demo)

## License

SolanaWeb is released under the MIT license. [See LICENSE](https://github.com/Elizabet1926/Solana/blob/master/LICENSE) for details.
