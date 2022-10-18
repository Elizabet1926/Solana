//
//  Solana.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//

import Foundation
import WebKit

public let SolanaMainNet: String = "https://solana-mainnet.phantom.tech"
public let SolanaMainNet1: String = "https://solana.maiziqianbao.net"
public let SolanaMainNet2: String = "https://api.mainnet-beta.solana.com"
public let SolanaMainNet3: String = "https://solana-api.projectserum.com"
public let SolanaMainNet4: String = "https://rpc.ankr.com/solana"


public enum SPLToken: String, CaseIterable {
    case USDT = "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
    case USDC = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
}

public class SolanaWeb3_V1: NSObject {
    var webView: WKWebView!
    var bridge: SOLWebViewJavascriptBridge!
    public var isGenerateSolanaWebInstanceSuccess: Bool = false
    var onCompleted: ((Bool) -> Void)?
    var showLog: Bool = true
    override public init() {
        super.init()
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.navigationDelegate = self
        self.webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        self.bridge = SOLWebViewJavascriptBridge(webView: self.webView, isHookConsole: false)
    }

    deinit {
        print("\(type(of: self)) release")
    }

    public func setup(showLog: Bool = true, onCompleted: ((Bool) -> Void)? = nil) {
        self.onCompleted = onCompleted
        self.showLog = showLog
        if showLog {
            self.bridge.consolePipeClosure = { water in
                guard let jsConsoleLog = water else {
                    print("Javascript console.log give native is nil!")
                    return
                }
                print(jsConsoleLog)
            }
        }
        self.bridge.register(handlerName: "generateSolanaWeb3") { [weak self] _, callback in
            guard let self = self else { return }
            self.isGenerateSolanaWebInstanceSuccess = true
            self.onCompleted?(true)
            let data = ["key": "value"]
            callback?(data)
        }
        let htmlSource = self.loadBundleResource(bundleName: "SolanaWeb", sourceName: "/index.html")
        let url = URL(fileURLWithPath: htmlSource)
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
    }

    func loadBundleResource(bundleName: String, sourceName: String) -> String {
        var bundleResourcePath = Bundle.main.path(forResource: "Frameworks/\(bundleName).framework/\(bundleName)", ofType: "bundle")
        if bundleResourcePath == nil {
            bundleResourcePath = Bundle.main.path(forResource: bundleName, ofType: "bundle") ?? ""
        }
        return bundleResourcePath! + sourceName
    }

    public func getSOLBalance(address: String, endpoint: String = SolanaMainNet, onCompleted: ((Bool, String) -> Void)? = nil) {
        let params: [String: String] = ["address": address, "endpoint": endpoint]
        self.bridge.call(handlerName: "getSOLBalance", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any], let state = temp["result"] as? Bool else {
                onCompleted?(false, "error")
                return
            }
            if let balance = temp["balance"] as? String {
                onCompleted?(state, balance)
            }
        }
    }
    public func getSPLTokenBalance(address: String,
                                   SPLTokenAddress: String = SPLToken.USDT.rawValue,
                                   decimalPoints: Double = 6.0,
                                   endpoint: String = SolanaMainNet,
                                   onCompleted: ((Bool, String) -> Void)? = nil)
    {
        let params: [String: Any] = ["address": address,
                                     "endpoint": endpoint,
                                     "SPLTokenAddress": SPLTokenAddress,
                                     "decimalPoints": decimalPoints]
        self.bridge.call(handlerName: "getSPLTokenBalance", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any], let state = temp["result"] as? Bool else {
                onCompleted?(false, "error")
                return
            }
            if let balance = temp["balance"] as? String {
                onCompleted?(state, balance)
            }
        }
    }

    public func getTokenAccountsByOwner(address: String, endpoint: String = SolanaMainNet, onCompleted: ((Bool, String) -> Void)? = nil) {
        let params: [String: String] = ["address": address, "endpoint": endpoint]
        self.bridge.call(handlerName: "getTokenAccountsByOwner", data: params) { [weak self] response in
            guard let self = self else { return }
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any], let state = temp["result"] as? Bool else {
                onCompleted?(false, "")
                return
            }
            if let tokenAccountsJson = temp["tokenAccounts"] as? String {
                onCompleted?(state, tokenAccountsJson)
            } else {
                onCompleted?(false, "")
            }
        }
    }

    public func solanaTransfer(privateKey: String,
                               toAddress: String,
                               amount: String,
                               endpoint: String = SolanaMainNet,
                               onCompleted: ((Bool, String) -> Void)? = nil)
    {
        let amount = Int64(doubleValue(string: amount) * pow(10, 9))
        let params: [String: Any] = ["toPublicKey": toAddress,
                                     "amount": amount,
                                     "endpoint": endpoint,
                                     "secretKey": privateKey]
        self.bridge.call(handlerName: "solanaMainTransfer", data: params) {[weak self] response in
            guard let self = self else { return }
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any], let state = temp["result"] as? Bool, let txid = temp["txid"] as? String else {
                onCompleted?(false, "error")
                return
            }
            onCompleted?(state, txid)
        }
    }

    public func solanaTokenTransfer(privateKey: String,
                                    toAddress: String,
                                    mintAuthority: String = SPLToken.USDT.rawValue,
                                    amount: String,
                                    decimalPoints: Double = 6,
                                    endpoint: String = SolanaMainNet,
                                    onCompleted: ((Bool, String) -> Void)? = nil)
    {
        let number = Int64(doubleValue(string: amount) * pow(10, decimalPoints))
        let params: [String: Any] = ["mintAuthority": mintAuthority,
                                     "toPublicKey": toAddress,
                                     "amount": number,
                                     "endpoint": endpoint,
                                     "decimals": decimalPoints,
                                     "secretKey": privateKey]
        self.bridge.call(handlerName: "solanaTokenTransfer", data: params) { [weak self] response in
            guard let self = self else { return }
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any], let state = temp["result"] as? Bool, let txid = temp["txid"] as? String else {
                onCompleted?(false, "error")
                return
            }
            onCompleted?(state, txid)
        }
    }
}

extension SolanaWeb3_V1: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if self.showLog {
            print("WKWebView didFail---->")
            print(error)
        }
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if self.showLog {
            print("WKWebView didFailProvisionalNavigation---->")
            print(error)
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.showLog {
            print("WKWebView didFinish---->")
        }
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.showLog {
            print("WKWebView didStartProvisionalNavigation---->")
        }
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if self.showLog {
            print("WKWebView didReceive  challenge---->")
        }
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if self.showLog {
            print("WKWebView didReceive  decidePolicyFor---->")
        }
        decisionHandler(.allow)
    }
}

extension SolanaWeb3_V1 {
    private func doubleValue(string: String) -> Double {
        let decima = NSDecimalNumber(string: string.count == 0 ? "0" : string)
        let doubleValue = Double(truncating: decima as NSNumber)
        return doubleValue
    }
}
