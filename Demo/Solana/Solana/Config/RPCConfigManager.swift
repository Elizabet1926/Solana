//
//  RPCConfigManager.swift
//  Solana
//

import Foundation

/// Persists RPC endpoint and provides connection check. Used by RPC Config screen and by features that need the current endpoint.
enum RPCConfigManager {

    private static let defaults = UserDefaults.standard
    private static let keyPreset = "solana.rpc.preset"
    private static let keyCustomURL = "solana.rpc.customURL"

    enum Preset: String, CaseIterable {
        case devnet
        case mainnetBeta

        var displayName: String {
            switch self {
            case .devnet: return "Devnet"
            case .mainnetBeta: return "Mainnet Beta"
            }
        }

        var endpoint: String {
            switch self {
            case .devnet: return "https://api.devnet.solana.com"
            case .mainnetBeta: return "https://api.mainnet-beta.solana.com"
            }
        }
    }

    /// 0 = Devnet, 1 = Mainnet Beta, 2 = Custom (use customURL)
    static var selectedPresetIndex: Int {
        get { defaults.integer(forKey: keyPreset) }
        set { defaults.set(newValue, forKey: keyPreset) }
    }

    static var customURL: String? {
        get {
            let s = defaults.string(forKey: keyCustomURL)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return s?.isEmpty == true ? nil : s
        }
        set { defaults.set(newValue, forKey: keyCustomURL) }
    }

    /// Current effective endpoint (preset or custom).
    static var currentEndpoint: String? {
        switch selectedPresetIndex {
        case 0: return Preset.devnet.endpoint
        case 1: return Preset.mainnetBeta.endpoint
        case 2: return customURL
        default:
            selectedPresetIndex = 0
            return Preset.devnet.endpoint
        }
    }

    /// Save preset index and optional custom URL (when preset is Custom).
    static func save(presetIndex: Int, customURL custom: String?) {
        selectedPresetIndex = presetIndex
        customURL = custom
    }

    /// Test RPC by calling getVersion. Returns version string on success, throws on failure.
    static func checkConnection(endpoint: String) async throws -> String {
        guard let url = URL(string: endpoint) else {
            throw RPCError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = """
        {"jsonrpc":"2.0","id":1,"method":"getVersion"}
        """.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw RPCError.badResponse
        }
        if http.statusCode == 403 {
            throw RPCError.forbidden
        }
        if http.statusCode != 200 {
            throw RPCError.httpStatus(http.statusCode)
        }
        struct GetVersionResult: Decodable {
            let result: ResultValue?
            let error: RPCErrorPayload?
            struct ResultValue: Decodable {
                let solanaCore: String?
                enum CodingKeys: String, CodingKey { case solanaCore = "solana-core" }
            }
        }
        struct RPCErrorPayload: Decodable {
            let message: String?
        }
        let decoded = try JSONDecoder().decode(GetVersionResult.self, from: data)
        if let err = decoded.error {
            throw RPCError.rpcError(err.message ?? "Unknown RPC error")
        }
        guard let version = decoded.result?.solanaCore else {
            throw RPCError.noVersion
        }
        return version
    }

    enum RPCError: LocalizedError {
        case invalidURL
        case badResponse
        case forbidden
        case httpStatus(Int)
        case rpcError(String)
        case noVersion

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid RPC URL"
            case .badResponse: return "Invalid response"
            case .forbidden: return "Access forbidden (403). For mainnet, use a custom RPC (e.g. Helius, QuickNode)."
            case .httpStatus(let code): return "HTTP \(code)"
            case .rpcError(let msg): return msg
            case .noVersion: return "Invalid RPC response"
            }
        }
    }
}
