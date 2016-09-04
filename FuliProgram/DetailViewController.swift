//
//  DetailViewController.swift
//  FuliProgram
//
//  Created by brzhang on 16/9/4.
//  Copyright © 2016年 brzhang. All rights reserved.
//

import UIKit

import Toast_Swift

class DetailViewController: UIViewController {
	var url: NSURL? {
		didSet {
			if url != nil {
				webView.loadRequest(NSURLRequest.init(URL: url!))
			}
		}
	}
	let webView = UIWebView()
	override func viewDidLoad() {
		super.viewDidLoad()
		webView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
		webView.delegate = self
		view.addSubview(webView)
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension DetailViewController: UIWebViewDelegate {
	func webViewDidStartLoad(webView: UIWebView) {
		self.view.makeToastActivity(.Center)
	}
	
	func webViewDidFinishLoad(webView: UIWebView) {
		self.view.hideToastActivity()
	}
}
