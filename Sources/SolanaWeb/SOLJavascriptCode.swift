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
              // Serialize object to string, handle various types and circular references
              let serializeObject = function (obj, visited) {
                  visited = visited || new WeakSet();
                  
                  // Handle basic types
                  if (obj === null) {
                      return "null";
                  }
                  
                  if (obj === undefined) {
                      return "undefined";
                  }
                  
                  if (typeof obj === 'string') {
                      return obj;
                  }
                  
                  if (typeof obj === 'number' || typeof obj === 'boolean') {
                      return String(obj);
                  }
                  
                  // Prevent circular references
                  if (typeof obj === 'object' && visited.has(obj)) {
                      return "[Circular]";
                  }
                  
                  try {
                      // Handle special object types
                      if (obj instanceof Error) {
                          return "[Error: " + obj.message + (obj.stack ? "\\n" + obj.stack : "") + "]";
                      }
                      
                      if (obj instanceof Promise) {
                          return "[Promise]";
                      }
                      
                      if (obj instanceof Date) {
                          return "[Date: " + obj.toISOString() + "]";
                      }
                      
                      if (obj instanceof RegExp) {
                          return "[RegExp: " + obj.toString() + "]";
                      }
                      
                      if (typeof obj === 'function') {
                          return "[Function: " + (obj.name || 'anonymous') + "]";
                      }
                      
                      if (obj instanceof Array) {
                          if (typeof obj.length !== 'number' || obj.length === 0) {
                              return "[]";
                          }
                          visited.add(obj);
                          let items = [];
                          for (let i = 0; i < Math.min(obj.length, 100); i++) {
                              try {
                                  items.push(serializeObject(obj[i], visited));
                              } catch (e) {
                                  items.push("[Error serializing array item]");
                              }
                          }
                          if (obj.length > 100) {
                              items.push("... and " + (obj.length - 100) + " more items");
                          }
                          visited.delete(obj);
                          return "[" + items.join(", ") + "]";
                      }
                      
                      // Handle Set and Map (ES6+)
                      if (obj instanceof Set) {
                          let items = [];
                          let count = 0;
                          for (let item of obj) {
                              if (count++ >= 100) break;
                              items.push(serializeObject(item, visited));
                          }
                          if (obj.size > 100) {
                              items.push("... and " + (obj.size - 100) + " more items");
                          }
                          return "[Set: " + items.join(", ") + "]";
                      }
                      
                      if (obj instanceof Map) {
                          let items = [];
                          let count = 0;
                          for (let [key, value] of obj) {
                              if (count++ >= 100) break;
                              items.push(serializeObject(key, visited) + " => " + serializeObject(value, visited));
                          }
                          if (obj.size > 100) {
                              items.push("... and " + (obj.size - 100) + " more entries");
                          }
                          return "[Map: " + items.join(", ") + "]";
                      }
                      
                      // Handle DOM elements
                      if (obj && obj.nodeType !== undefined) {
                          return "[DOMElement: " + (obj.tagName || 'Unknown') + "]";
                      }
                      
                      // Handle plain objects
                      if (typeof obj === 'object') {
                          visited.add(obj);
                          let pairs = [];
                          let keyCount = 0;
                          
                          // Use JSON.stringify as primary method, more reliable
                          // JSON.stringify automatically detects circular references and throws errors
                          try {
                              let jsonStr = JSON.stringify(obj, function(key, value) {
                                  // Convert special types to string representation
                                  if (typeof value === 'function') {
                                      return "[Function: " + (value.name || 'anonymous') + "]";
                                  }
                                  if (value instanceof RegExp) {
                                      return value.toString();
                                  }
                                  if (value instanceof Date) {
                                      return value.toISOString();
                                  }
                                  if (value instanceof Error) {
                                      return value.toString();
                                  }
                                  // JSON.stringify automatically handles other circular reference cases
                                  return value;
                              });
                              
                              if (jsonStr && jsonStr.length < 10000) {
                                  visited.delete(obj);
                                  return jsonStr;
                              }
                          } catch (e) {
                              // JSON.stringify failed (usually circular reference or other serialization error), use fallback method
                              // Continue with manual serialization code below
                          }
                          
                          // Fallback: manual serialization
                          for (let key in obj) {
                              if (keyCount++ >= 100) {
                                  pairs.push("... and more keys");
                                  break;
                              }
                              try {
                                  if (obj.hasOwnProperty(key)) {
                                      let value = obj[key];
                                      let keyStr = String(key);
                                      let valueStr = serializeObject(value, visited);
                                      pairs.push('"' + keyStr.replace(/"/g, '\\\\"') + '": ' + valueStr);
                                  }
                              } catch (e) {
                                  pairs.push('"' + key + '": [Error serializing value]');
                              }
                          }
                          
                          visited.delete(obj);
                          return "{" + pairs.join(", ") + "}";
                      }
                      
                      // Other types, try toString
                      return String(obj);
                      
                  } catch (e) {
                      return "[Error serializing object: " + e.message + "]";
                  }
              };
              
              // Save original console.log method
              const originalConsoleLog = window.console.log.bind(window.console);
              
              // Helper function to send message to native code
              let sendToNative = function (message) {
                  try {
                      if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.console) {
                          window.webkit.messageHandlers.console.postMessage(message);
                      }
                  } catch (e) {
                      // If send fails, handle silently to avoid affecting original console.log functionality
                      originalConsoleLog("[Bridge Error]: Failed to send message to native: " + e.message);
                  }
              };
              
              console.log("start hook Console.");
              
              // Override console.log
              window.console.log = function() {
                  // Call original console.log first to ensure original functionality is not affected
                  originalConsoleLog.apply(window.console, arguments);
                  
                  // Try to serialize each argument and send to native code
                  for (let i = 0; i < arguments.length; i++) {
                      try {
                          const obj = arguments[i];
                          let serialized = serializeObject(obj);
                          
                          // Limit message length to avoid issues with overly long messages
                          if (serialized.length > 50000) {
                              serialized = serialized.substring(0, 50000) + "... [truncated]";
                          }
                          
                          sendToNative(serialized);
                      } catch (e) {
                          // If serialization fails, send error message
                          sendToNative("[Error serializing console.log argument: " + e.message + "]");
                      }
                  }
              };
              
              // Mark as hooked
              window.hookConsole = 1;
          })(window);
        """
        return hookConsole
    }

}
