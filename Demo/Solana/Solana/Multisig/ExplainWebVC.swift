//
//  ExplainWebVC.swift
//  Solana
//

import UIKit
import WebKit
import SnapKit

final class ExplainWebVC: UIViewController {

    private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multisig Guide"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        if let url = SolanaResourceLoader.url(name: "explain", ext: "html", subdirectory: "SolanaWeb.bundle") {
            let dir = url.deletingLastPathComponent()
            webView.loadFileURL(url, allowingReadAccessTo: dir)
        } else {
            let fallback = """
            <html><body style="font-family: system-ui; padding: 16px;">
            <p>Guide not found. Ensure explain.html is in SolanaWeb.bundle.</p>
            </body></html>
            """
            webView.loadHTMLString(fallback, baseURL: nil)
        }
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}
