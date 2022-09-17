//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
struct SOLJavascriptCode {
    public static func bridge() ->String {
        let bridgeJS = """
            ;(function(window) {
               if (window.WebViewJavascriptBridge) {
                   return;
               }
               window.WebViewJavascriptBridge = {
                   registerHandler: registerHandler,
                   callHandler: callHandler,
                   handleMessageFromNative: handleMessageFromNative
               };
               let messageHandlers = {};
               let responseCallbacks = {};
               let uniqueId = 1;
               function registerHandler(handlerName, handler) {
                   messageHandlers[handlerName] = handler;
               }
               function callHandler(handlerName, data, responseCallback) {
                   if (arguments.length === 2 && typeof data == 'function') {
                       responseCallback = data;
                       data = null;
                   }
                   doSend({ handlerName:handlerName, data:data }, responseCallback);
               }
               function doSend(message, responseCallback) {
                   if (responseCallback) {
                       const callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                       responseCallbacks[callbackId] = responseCallback;
                       message['callbackId'] = callbackId;
                   }
                   window.webkit.messageHandlers.normal.postMessage(JSON.stringify(message));
               }
               function handleMessageFromNative(messageJSON) {
                   const message = JSON.parse(messageJSON);
                   let responseCallback;
                   if (message.responseId) {
                       responseCallback = responseCallbacks[message.responseId];
                       if (!responseCallback) {
                           return;
                       }
                       responseCallback(message.responseData);
                       delete responseCallbacks[message.responseId];
                   } else {
                       if (message.callbackId) {
                           const callbackResponseId = message.callbackId;
                           responseCallback = function(responseData) {
                               doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
                           };
                       }
                       const handler = messageHandlers[message.handlerName];
                       if (!handler) {
                           console.log("WebViewJavascriptBridge: WARNING: no handler for message from Swift:", message);
                       } else {
                           handler(message.data, responseCallback);
                       }
                   }
               }
           })(window);
        """
        return bridgeJS
    }
    
    public static func hookConsole() ->String {
        let hookConsole = """
           ;(function(window) {
              if(window.hookConsole){
                  console.log("hook Console have already finished.");
                  return ;
              }
              let printObject = function (obj) {
                  let output = "";
                  if (typeof obj ==='object'){
                      output+="{";
                      for(let key in obj){
                          let value = obj[key];
                          output+= \"\\\"\"+key+\"\\\"\"+\":\"+\"\\\"\"+value+\"\\\"\"+\",\";
                      }
                      output = output.substr(0, output.length - 1);
                      output+="}";
                  }
                  else {
                      output = "" + obj;
                  }
                  return output;
              };
              console.log("start hook Console.");
              window.console.log = (function (oriLogFunc,printObject) {
                  window.hookConsole = 1;
                  return function (str) {
                      for (let i = 0; i < arguments.length; i++) {
                          const obj = arguments[i];
                          oriLogFunc.call(window.console, obj);
                          if (obj === null) {
                              const nullString = "null";
                              window.webkit.messageHandlers.console.postMessage(nullString);
                          }
                          else  if (typeof(obj) == "undefined") {
                              const undefinedString = "undefined";
                              window.webkit.messageHandlers.console.postMessage(undefinedString);
                          }
                          else if (obj instanceof Promise){
                              const promiseString = "This is a javascript Promise.";
                              window.webkit.messageHandlers.console.postMessage(promiseString);
                          } else if(obj instanceof Date){
                              const dateString =  obj.getTime().toString();
                              window.webkit.messageHandlers.console.postMessage(dateString);
                          } else if(obj instanceof Array){
                              let arrayString = '[' + obj.toString() + ']';
                              window.webkit.messageHandlers.console.postMessage(arrayString);
                          }
                          else {
                              const objs = printObject(obj);
                              window.webkit.messageHandlers.console.postMessage(objs);
                          }
                      }
                  }
              })(window.console.log,printObject);
              console.log("end hook Console.");
          })(window);
        """
        return hookConsole
    }
}
