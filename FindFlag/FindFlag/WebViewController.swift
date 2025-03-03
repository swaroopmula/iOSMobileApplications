//
//  WebViewController.swift
//  HW8
//
//  Created by Swaroop Mula on 3/5/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var urlString: String?
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
