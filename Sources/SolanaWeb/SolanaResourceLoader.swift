//
//  ResourceLoader.swift
//  Bitcoin
//
//  Created by Elizabet on 2026/1/17.
//


import Foundation

public enum SolanaResourceLoader {
  
    public static func url(
        name: String,
        ext: String,
        subdirectory: String? = nil
    ) -> URL? {
        #if SWIFT_PACKAGE
        return Bundle.module.url(forResource: name, withExtension: ext, subdirectory: subdirectory)
        #else
        let bundle = Bundle(for: SolanaBundleToken.self)
        return bundle.url(forResource: name, withExtension: ext, subdirectory: subdirectory)
        #endif
    }
}

private final class SolanaBundleToken {}
