//
//  Solana.swift
//  Solana
//
//  Created by Elizabet 
//

import WebKit

public let SolanaMainNet1: String = "https://solana.maiziqianbao.net"
public let SolanaMainNet2: String = "https://api.mainnet-beta.solana.com"
public let SolanaMainNet3: String = "https://solana-api.projectserum.com"
public let SolanaMainNet4: String = "https://rpc.ankr.com/solana"

public enum SPLToken: String, CaseIterable {
    case USDT = "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
    case USDC = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
}
@MainActor
public class SolanaWeb: NSObject {
    var webView: WKWebView!
    var bridge: SOLWebViewJavascriptBridge!
    public var isGenerateSolanaWebInstanceSuccess: Bool = false
    var onCompleted: ((Bool) -> Void)?
    var showLog: Bool = true

    override public init() {
        super.init()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.bridge = SOLWebViewJavascriptBridge(webView: self.webView, isHookConsole: true)
    }

    deinit {
        print("\(type(of: self)) release")
    }

    public func setup(showLog: Bool = true, onCompleted: ((Bool) -> Void)? = nil) {
        self.onCompleted = onCompleted
        self.showLog = showLog
        #if !DEBUG
        self.showLog = false
        #endif
        self.bridge.register(handlerName: "generateSolanaWeb3") { [weak self] _, callback in
            guard let self = self else { return }
            self.isGenerateSolanaWebInstanceSuccess = true
            self.onCompleted?(true)
            let data = ["key": "value"]
            callback?(data)
        }
        
        if let url = SolanaResourceLoader.url(name: "index", ext: "html", subdirectory: "SolanaWeb.bundle") {
            self.webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }

    // MARK: - Wallet Management
    /// Create wallet via JS bridge (wordCount: 12/15/18/21/24, language: en/english/zh-CN/ja/...)
    public func createWallet(wordCount: Int = 12, language: String = "en", completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = ["wordCount": wordCount, "language": language]
        bridge.call(handlerName: "createWallet", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    public func createWalletAsync(wordCount: Int = 12, language: String = "en") async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.createWallet(wordCount: wordCount, language: language) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func importAccountFromMnemonic(mnemonic: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["mnemonic": mnemonic]
        self.bridge.call(handlerName: "importAccountFromMnemonic", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of importAccountFromMnemonic
    public func importAccountFromMnemonicAsync(mnemonic: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.importAccountFromMnemonic(mnemonic: mnemonic) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func importAccountFromPrivateKey(privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["privateKey": privateKey]
        self.bridge.call(handlerName: "importAccountFromPrivateKey", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Query SOL balance for address. Requires endpoint (e.g. from RPCConfigManager.currentEndpoint).
    public func getSOLBalance(address: String, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = ["address": address, "endpoint": endpoint]
        bridge.call(handlerName: "getSOLBalance", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getSOLBalance
    public func getSOLBalanceAsync(address: String, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getSOLBalance(address: address, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Query SPL token balance for owner address and mint. decimalPoints defaults to 6 if not provided.
    public func getSPLTokenBalance(address: String, mint: String, endpoint: String, decimalPoints: Int = 6, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "address": address,
            "endpoint": endpoint,
            "SPLTokenAddress": mint,
            "decimalPoints": decimalPoints
        ]
        bridge.call(handlerName: "getSPLTokenBalance", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getSPLTokenBalance
    public func getSPLTokenBalanceAsync(address: String, mint: String, endpoint: String, decimalPoints: Int = 6) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getSPLTokenBalance(address: address, mint: mint, endpoint: endpoint, decimalPoints: decimalPoints) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Get token accounts for owner address. Returns response with "tokenAccounts" (JSON string array).
    public func getTokenAccountsByOwner(address: String, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = ["address": address, "endpoint": endpoint]
        bridge.call(handlerName: "getTokenAccountsByOwner", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getTokenAccountsByOwner
    public func getTokenAccountsByOwnerAsync(address: String, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getTokenAccountsByOwner(address: address, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Estimate SOL transfer cost. fromPublicKey/toPublicKey are base58; amount is in lamports.
    /// Returns response with estimatedSOLTransferCost, transferSol, estimatedFeeSol, needCreateAccount, rentExemptMinimumSol, totalCostWithRentSol, or error.
    public func estimatedSOLTransferCost(fromPublicKey: String, toPublicKey: String, amountLamports: UInt64, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let amountForJson = amountLamports <= UInt64(Int.max) ? Int(amountLamports) : Int.max
        let params: [String: Any] = [
            "fromPublicKey": fromPublicKey,
            "toPublicKey": toPublicKey,
            "amount": amountForJson,
            "endpoint": endpoint
        ]
        bridge.call(handlerName: "estimatedSOLTransferCost", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of estimatedSOLTransferCost
    public func estimatedSOLTransferCostAsync(fromPublicKey: String, toPublicKey: String, amountLamports: UInt64, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.estimatedSOLTransferCost(fromPublicKey: fromPublicKey, toPublicKey: toPublicKey, amountLamports: amountLamports, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Send SOL from keypair (secretKey base58) to toPublicKey. amountLamports is the amount in lamports.
    /// Returns response with "signature" (txid) or "error".
    public func sendSOL(secretKey: String, toPublicKey: String, amountLamports: UInt64, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let amountForJson = amountLamports <= UInt64(Int.max) ? Int(amountLamports) : Int.max
        let params: [String: Any] = [
            "secretKey": secretKey,
            "toPublicKey": toPublicKey,
            "amount": amountForJson,
            "endpoint": endpoint
        ]
        bridge.call(handlerName: "solanaMainTransfer", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of sendSOL
    public func sendSOLAsync(secretKey: String, toPublicKey: String, amountLamports: UInt64, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.sendSOL(secretKey: secretKey, toPublicKey: toPublicKey, amountLamports: amountLamports, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Send SPL token. mint is the token mint address; amountRaw is amount in smallest unit (amountUi * 10^decimals).
    /// Returns response with "signature" (txid) or "error".
    public func sendSPLToken(secretKey: String, toPublicKey: String, mint: String, amountRaw: UInt64, decimals: Int, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let amountForJson = amountRaw <= UInt64(Int.max) ? Int(amountRaw) : Int.max
        let params: [String: Any] = [
            "secretKey": secretKey,
            "toPublicKey": toPublicKey,
            "mintAuthority": mint,
            "amount": amountForJson,
            "decimals": decimals,
            "endpoint": endpoint
        ]
        bridge.call(handlerName: "solanaTokenTransfer", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of sendSPLToken
    public func sendSPLTokenAsync(secretKey: String, toPublicKey: String, mint: String, amountRaw: UInt64, decimals: Int, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.sendSPLToken(secretKey: secretKey, toPublicKey: toPublicKey, mint: mint, amountRaw: amountRaw, decimals: decimals, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Estimate SPL token transfer cost (SOL). If fromPublicKey is non-nil, use it; else derive from secretKey. amountRaw is amount in smallest unit.
    /// Returns response with "cost" (SOL string) or "error".
    public func estimatedSPLTokenTransferCost(secretKey: String?, fromPublicKey: String?, toPublicKey: String, mint: String, amountRaw: UInt64, decimals: Int, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let amountForJson = amountRaw <= UInt64(Int.max) ? Int(amountRaw) : Int.max
        var params: [String: Any] = [
            "toPublicKey": toPublicKey,
            "mint": mint,
            "amount": amountForJson,
            "decimals": decimals,
            "endpoint": endpoint
        ]
        if let from = fromPublicKey, !from.isEmpty {
            params["fromPublicKey"] = from
        }
        if let key = secretKey, !key.isEmpty {
            params["privateKey"] = key
        }
        bridge.call(handlerName: "estimatedSPLTokenTransferCost", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of estimatedSPLTokenTransferCost
    public func estimatedSPLTokenTransferCostAsync(secretKey: String?, fromPublicKey: String?, toPublicKey: String, mint: String, amountRaw: UInt64, decimals: Int, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.estimatedSPLTokenTransferCost(secretKey: secretKey, fromPublicKey: fromPublicKey, toPublicKey: toPublicKey, mint: mint, amountRaw: amountRaw, decimals: decimals, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Sign message with private key (Base58). encoding: "utf8", "base58", or "auto". Returns signature, publicKey, message, detectedEncoding, or error.
    public func signMessage(privateKey: String, message: String, encoding: String = "auto", completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = ["privateKey": privateKey, "message": message, "encoding": encoding]
        bridge.call(handlerName: "signMessage", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Verify signature. encoding: "utf8", "base58", or "auto". Returns isValid, publicKey, message, detectedEncoding, or error.
    public func verifySignature(publicKey: String, message: String, signature: String, encoding: String = "auto", completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = ["publicKey": publicKey, "message": message, "signature": signature, "encoding": encoding]
        bridge.call(handlerName: "verifySignature", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of signMessage
    public func signMessageAsync(privateKey: String, message: String, encoding: String = "auto") async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.signMessage(privateKey: privateKey, message: message, encoding: encoding) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Async version of verifySignature
    public func verifySignatureAsync(publicKey: String, message: String, signature: String, encoding: String = "auto") async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.verifySignature(publicKey: publicKey, message: message, signature: signature, encoding: encoding) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Async version of importAccountFromPrivateKey
    public func importAccountFromPrivateKeyAsync(privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.importAccountFromPrivateKey(privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    // MARK: - Multisig

    /// Create multisig. members: array of base58 public keys (≥2). threshold: 1...N. endpoint from RPCConfigManager.currentEndpoint.
    /// Returns multisigPda, vaultPda, createKey, createKeyPrivateKey, signature; or error.
    public func createMultisig(creatorPrivateKey: String, members: [String], threshold: Int, endpoint: String, name: String?, completion: @escaping ([String: Any]?) -> Void) {
        var params: [String: Any] = [
            "creatorPrivateKey": creatorPrivateKey,
            "members": members,
            "threshold": threshold,
            "endpoint": endpoint,
        ]
        if let n = name, !n.isEmpty {
            params["name"] = n
        }
        bridge.call(handlerName: "createMultisig", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of createMultisig
    public func createMultisigAsync(creatorPrivateKey: String, members: [String], threshold: Int, endpoint: String, name: String?) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.createMultisig(creatorPrivateKey: creatorPrivateKey, members: members, threshold: threshold, endpoint: endpoint, name: name) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Create SOL transfer proposal (Draft). amountSol: amount in SOL. Returns transactionIndex, vaultTransactionPda, proposalPda, vaultTransactionSignature, proposalSignature, vaultPda.
    public func multisigSendSOL(creatorPrivateKey: String, multisigPda: String, to: String, amountSol: Double, endpoint: String, vaultIndex: Int?, transactionIndex: Int?, completion: @escaping ([String: Any]?) -> Void) {
        var params: [String: Any] = [
            "creatorPrivateKey": creatorPrivateKey,
            "multisigPda": multisigPda,
            "to": to,
            "amountSol": amountSol,
            "endpoint": endpoint,
        ]
        if let vi = vaultIndex { params["vaultIndex"] = vi }
        if let ti = transactionIndex { params["transactionIndex"] = ti }
        bridge.call(handlerName: "multisigSendSOL", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    public func multisigSendSOLAsync(creatorPrivateKey: String, multisigPda: String, to: String, amountSol: Double, endpoint: String, vaultIndex: Int? = nil, transactionIndex: Int? = nil) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.multisigSendSOL(creatorPrivateKey: creatorPrivateKey, multisigPda: multisigPda, to: to, amountSol: amountSol, endpoint: endpoint, vaultIndex: vaultIndex, transactionIndex: transactionIndex) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Create SPL token transfer proposal (Draft). amount: UI amount (e.g. 1.5). decimals: token decimals. createAtaIfMissing: default true.
    public func multisigSendSPLToken(creatorPrivateKey: String, multisigPda: String, mint: String, to: String, amount: Double, decimals: Int, endpoint: String, createAtaIfMissing: Bool, vaultIndex: Int?, transactionIndex: Int?, completion: @escaping ([String: Any]?) -> Void) {
        var params: [String: Any] = [
            "creatorPrivateKey": creatorPrivateKey,
            "multisigPda": multisigPda,
            "mint": mint,
            "to": to,
            "amount": amount,
            "decimals": decimals,
            "endpoint": endpoint,
            "createAtaIfMissing": createAtaIfMissing,
        ]
        if let vi = vaultIndex { params["vaultIndex"] = vi }
        if let ti = transactionIndex { params["transactionIndex"] = ti }
        bridge.call(handlerName: "multisigSendSPLToken", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    public func multisigSendSPLTokenAsync(creatorPrivateKey: String, multisigPda: String, mint: String, to: String, amount: Double, decimals: Int, endpoint: String, createAtaIfMissing: Bool = true, vaultIndex: Int? = nil, transactionIndex: Int? = nil) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.multisigSendSPLToken(creatorPrivateKey: creatorPrivateKey, multisigPda: multisigPda, mint: mint, to: to, amount: amount, decimals: decimals, endpoint: endpoint, createAtaIfMissing: createAtaIfMissing, vaultIndex: vaultIndex, transactionIndex: transactionIndex) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Activate proposal (Draft → Active). memberPrivateKey: member who activates; transactionIndex: proposal's transaction index.
    public func proposalActivate(memberPrivateKey: String, multisigPda: String, transactionIndex: Int, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "memberPrivateKey": memberPrivateKey,
            "multisigPda": multisigPda,
            "transactionIndex": transactionIndex,
            "endpoint": endpoint,
        ]
        bridge.call(handlerName: "proposalActivate", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    public func proposalActivateAsync(memberPrivateKey: String, multisigPda: String, transactionIndex: Int, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.proposalActivate(memberPrivateKey: memberPrivateKey, multisigPda: multisigPda, transactionIndex: transactionIndex, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Approve proposal (member votes). transactionIndex: proposal's transaction index.
    public func proposalApprove(memberPrivateKey: String, multisigPda: String, transactionIndex: Int, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "memberPrivateKey": memberPrivateKey,
            "multisigPda": multisigPda,
            "transactionIndex": transactionIndex,
            "endpoint": endpoint,
        ]
        bridge.call(handlerName: "proposalApprove", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    public func proposalApproveAsync(memberPrivateKey: String, multisigPda: String, transactionIndex: Int, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.proposalApprove(memberPrivateKey: memberPrivateKey, multisigPda: multisigPda, transactionIndex: transactionIndex, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Execute vault transaction (after threshold approvals). vaultIndex defaults to 0.
    public func vaultTransactionExecute(memberPrivateKey: String, multisigPda: String, transactionIndex: Int, endpoint: String, vaultIndex: Int?, completion: @escaping ([String: Any]?) -> Void) {
        var params: [String: Any] = [
            "memberPrivateKey": memberPrivateKey,
            "multisigPda": multisigPda,
            "transactionIndex": transactionIndex,
            "endpoint": endpoint,
        ]
        if let vi = vaultIndex {
            params["vaultIndex"] = vi
        }
        bridge.call(handlerName: "vaultTransactionExecute", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    public func vaultTransactionExecuteAsync(memberPrivateKey: String, multisigPda: String, transactionIndex: Int, endpoint: String, vaultIndex: Int? = nil) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.vaultTransactionExecute(memberPrivateKey: memberPrivateKey, multisigPda: multisigPda, transactionIndex: transactionIndex, endpoint: endpoint, vaultIndex: vaultIndex) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    /// Query proposal status (read-only, no private key). Returns status, proposalPda, approvedCount, threshold, etc.
    public func getProposalStatus(multisigPda: String, transactionIndex: Int, endpoint: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "multisigPda": multisigPda,
            "transactionIndex": transactionIndex,
            "endpoint": endpoint,
        ]
        bridge.call(handlerName: "getProposalStatus", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    public func getProposalStatusAsync(multisigPda: String, transactionIndex: Int, endpoint: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getProposalStatus(multisigPda: multisigPda, transactionIndex: transactionIndex, endpoint: endpoint) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }
}
