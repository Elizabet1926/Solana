//
//  Solana.swift
//  Solana
//
//  Created by Elizabet on 2022/9/15.
//
import Foundation
protocol WebViewJavascriptBridgeBaseDelegate: AnyObject {
    typealias CompletionHandler = ((Any?, Error?) -> Void)?
    func evaluateJavascript(javascript: String, completion: CompletionHandler)
}

extension WebViewJavascriptBridgeBaseDelegate {
    func evaluateJavascript(javascript: String) {
        evaluateJavascript(javascript: javascript, completion: nil)
    }
}

public class SOLWebViewJavascriptBridgeBase: NSObject {
    public typealias Callback = (_ responseData: Any?) -> Void
    public typealias Handler = (_ parameters: [String: Any]?, _ callback: Callback?) -> Void
    public typealias Message = [String: Any]
    weak var delegate: WebViewJavascriptBridgeBaseDelegate?
    var responseCallbacks = [String: Callback]()
    var messageHandlers = [String: Handler]()
    var uniqueId = 0
    func reset() {
        responseCallbacks = [String: Callback]()
        uniqueId = 0
    }

    func send(handlerName: String, data: Any?, callback: Callback?) {
        var message = [String: Any]()
        message["handlerName"] = handlerName
        if data != nil {
            message["data"] = data
        }
        if callback != nil {
            uniqueId += 1
            let callbackID = "objc_cb_\(uniqueId)"
            responseCallbacks[callbackID] = callback
            message["callbackId"] = callbackID
        }
        dispatch(message: message)
    }

    func flush(messageQueueString: String) {
        guard let message = deserialize(messageJSON: messageQueueString) else {
            return
        }
        if let responseID = message["responseId"] as? String {
            guard let callback = responseCallbacks[responseID] else { return }
            callback(message["responseData"])
            responseCallbacks.removeValue(forKey: responseID)
        } else {
            var callback: Callback?
            if let callbackID = message["callbackId"] {
                callback = { (_ responseData: Any?) in
                    let msg = ["responseId": callbackID, "responseData": responseData ?? NSNull()] as Message
                    self.dispatch(message: msg)
                }
            } else {
                callback = { (_: Any?) in
                    // no logic
                    print("no logic")
                }
            }
            guard let handlerName = message["handlerName"] as? String else { return }
            guard let handler = messageHandlers[handlerName] else {
                print("NoHandlerException, No handler for message from JS: \(message)")
                return
            }
            handler(message["data"] as? [String: Any], callback)
        }
    }

    private func dispatch(message: Message) {
        guard var messageJSON = serialize(message: message, pretty: false) else { return }

        messageJSON = messageJSON.replacingOccurrences(of: "\\", with: "\\\\")
        messageJSON = messageJSON.replacingOccurrences(of: "\"", with: "\\\"")
        messageJSON = messageJSON.replacingOccurrences(of: "\'", with: "\\\'")
        messageJSON = messageJSON.replacingOccurrences(of: "\n", with: "\\n")
        messageJSON = messageJSON.replacingOccurrences(of: "\r", with: "\\r")
        messageJSON = messageJSON.replacingOccurrences(of: "\u{000C}", with: "\\f")
        messageJSON = messageJSON.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
        messageJSON = messageJSON.replacingOccurrences(of: "\u{2029}", with: "\\u2029")

        let javascriptCommand = "WebViewJavascriptBridge.handleMessageFromNative('\(messageJSON)');"
        if Thread.current.isMainThread {
            delegate?.evaluateJavascript(javascript: javascriptCommand)
        } else {
            DispatchQueue.main.async {
                self.delegate?.evaluateJavascript(javascript: javascriptCommand)
            }
        }
    }

    // MARK: - JSON

    private func serialize(message: Message, pretty: Bool) -> String? {
        var result: String?
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: pretty ? .prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0))
            result = String(data: data, encoding: .utf8)
        } catch {
            print(error)
        }
        return result
    }

    private func deserialize(messageJSON: String) -> Message? {
        var result = Message()
        guard let data = messageJSON.data(using: .utf8) else { return nil }
        do {
            result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! SOLWebViewJavascriptBridgeBase.Message
        } catch {
            print(error)
        }
        return result
    }
}
