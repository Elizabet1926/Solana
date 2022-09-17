//
//  Solana.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//

import Foundation
import WebKit

public let SolanaMainNet: String = "https://solana-mainnet.phantom.tech"

public enum SPLToken: String, CaseIterable {
    case USDT = "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
    case USDC = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
}

public class SolanaWeb: NSObject {
    
    var webView: WKWebView!
    var bridge: SOLWebViewJavascriptBridge!
    var isGenerateSolanaWebInstanceSuccess: Bool = false
    var onCompleted: ((Bool) -> Void)?
    var showLog: Bool = true
    override public init() {
        super.init()
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.navigationDelegate = self
        self.webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        self.bridge = SOLWebViewJavascriptBridge(webView: self.webView)
    }
    
    deinit {
        print("\(type(of: self)) release")
    }

    func setup(showLog: Bool = true,onCompleted: ((Bool) -> Void)? = nil){
        self.onCompleted = onCompleted
        self.showLog = showLog
        if showLog {
            bridge.consolePipeClosure = { water in
                guard let jsConsoleLog = water else {
                    print("Javascript console.log give native is nil!")
                    return
                }
                print(jsConsoleLog)
            }
        }
        bridge.register(handlerName: "generateSolanaWeb3") { [weak self] (parameters, callback) in
            guard let self = self else {return}
            self.isGenerateSolanaWebInstanceSuccess = true
            self.onCompleted?(true)
            let data = ["key":"value"]
            callback?(data)
        }
        let htmlSource = loadBundleResource(bundleName: "SolanaWeb", sourceName: "/index.html")
        let url = URL.init(fileURLWithPath: htmlSource)
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }

    func loadBundleResource(bundleName: String, sourceName: String) -> String {
        var bundleResourcePath = Bundle.main.path(forResource: "Frameworks/\(bundleName).framework/\(bundleName)", ofType: "bundle")
        if bundleResourcePath == nil {
            bundleResourcePath = Bundle.main.path(forResource: bundleName, ofType: "bundle") ?? ""
        }
        return bundleResourcePath! + sourceName
    }
    
    func solanaTransfer(privateKey:String,
                        toAddress:String,
                        amount:String,
                        endpoint:String = SolanaMainNet,
                        onCompleted: ((Bool, String) -> Void)? = nil) {
     
        let amount = Int64(doubleValue(string: amount) * pow(10,9))
        let params:[String:Any] = ["toPublicKey":toAddress,
                                      "amount":amount,
                                      "endpoint":endpoint,
                                      "secretKey":privateKey]
        bridge.call(handlerName: "solanaMainTransfer", data: params){ response in
            guard let temp = response as? [String: Any], let state = temp["result"] as? Bool, let txid = temp["txid"] as? String else {
                onCompleted?(false, "error")
                return
            }
            onCompleted?(state, txid)
        }
    }

    func solanaTokenTransfer(privateKey:String,
                             toAddress:String,
                             mintAuthority:String = SPLToken.USDT.rawValue,
                             amount:String,
                             decimalPoints:Double = 6,
                             endpoint:String = SolanaMainNet,
                             onCompleted: ((Bool, String) -> Void)? = nil) {
        let number = Int64(doubleValue(string: amount) * pow(10,decimalPoints))
        let params:[String:Any] = [ "mintAuthority":mintAuthority,
                                     "toPublicKey":toAddress,
                                     "amount":number,
                                     "endpoint":endpoint,
                                     "decimals":decimalPoints,
                                     "secretKey":privateKey]
        bridge.call(handlerName: "solanaTokenTransfer", data: params) { response in
            guard let temp = response as? [String: Any], let state = temp["result"] as? Bool, let txid = temp["txid"] as? String else {
                onCompleted?(false, "error")
                return
            }
            onCompleted?(state, txid)
        }
    }
}

extension SolanaWeb: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        if self.showLog {
            print("WKWebView didFail---->")
            print(error)
        }
    }
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
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

extension SolanaWeb {
    private func doubleValue (string: String)->Double {
        let decima = NSDecimalNumber(string: string.count == 0 ? "0" : string)
        let doubleValue = Double(truncating: decima as NSNumber)
        return doubleValue
    }
}
