//
//  Solana.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//

import Foundation
import WebKit
enum PipeType: String {
    case normal
    case console
}

public typealias ConsolePipeClosure = (Any?) -> Void

public class SOLWebViewJavascriptBridge: NSObject {
    private weak var webView: WKWebView?
    private var base: SOLWebViewJavascriptBridgeBase!
    public var consolePipeClosure: ConsolePipeClosure?
    public init(webView: WKWebView, _ otherJSCode: String = "", isHookConsole: Bool = true,injectionTime: WKUserScriptInjectionTime = .atDocumentStart) {
        super.init()
        self.webView = webView
        base = SOLWebViewJavascriptBridgeBase()
        base.delegate = self
        addScriptMessageHandlers()
        injectJavascriptFile(otherJSCode, isHookConsole: isHookConsole,injectionTime: injectionTime)
    }

    deinit {
        print("\(type(of: self)) release")
        removeScriptMessageHandlers()
    }

    // MARK: - Public Funcs

    public func reset() {
        base.reset()
    }

    public func register(handlerName: String, handler: @escaping SOLWebViewJavascriptBridgeBase.Handler) {
        base.messageHandlers[handlerName] = handler
    }

    public func remove(handlerName: String) -> SOLWebViewJavascriptBridgeBase.Handler? {
        return base.messageHandlers.removeValue(forKey: handlerName)
    }

    public func call(handlerName: String, data: Any? = nil, callback: SOLWebViewJavascriptBridgeBase.Callback? = nil) {
        base.send(handlerName: handlerName, data: data, callback: callback)
    }

    private func injectJavascriptFile(_ otherJSCode: String = "", isHookConsole: Bool ,injectionTime: WKUserScriptInjectionTime = .atDocumentStart) {
        let bridgeJS = SOLJavascriptCode.bridge()
        let hookConsoleJS = isHookConsole ? SOLJavascriptCode.hookConsole() : ""
        let finalJS = "\(bridgeJS)" + "\(hookConsoleJS)"
        let userScript = WKUserScript(source: finalJS, injectionTime: injectionTime, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(userScript)
        if !otherJSCode.isEmpty {
            let otherScript = WKUserScript(source: otherJSCode, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            webView?.configuration.userContentController.addUserScript(otherScript)
        }
    }

    private func addScriptMessageHandlers() {
        webView?.configuration.userContentController.add(LeakAvoider(delegate: self), name: PipeType.normal.rawValue)
        webView?.configuration.userContentController.add(LeakAvoider(delegate: self), name: PipeType.console.rawValue)
    }

    private func removeScriptMessageHandlers() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: PipeType.normal.rawValue)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: PipeType.console.rawValue)
    }
}

extension SOLWebViewJavascriptBridge: WebViewJavascriptBridgeBaseDelegate {
    func evaluateJavascript(javascript: String, completion: CompletionHandler) {
        webView?.evaluateJavaScript(javascript, completionHandler: completion)
    }
}

extension SOLWebViewJavascriptBridge: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == PipeType.console.rawValue {
            consolePipeClosure?(message.body)
        } else if message.name == PipeType.normal.rawValue {
            let body = message.body as? String
            guard let resultStr = body else { return }
            base.flush(messageQueueString: resultStr)
        }
    }
}

private class LeakAvoider: NSObject {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) {
        super.init()
        self.delegate = delegate
    }
}

extension LeakAvoider: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
