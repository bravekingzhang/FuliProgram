//
//  ViewController.swift
//  FuliProgram
//
//  Created by brzhang on 16/9/4.
//  Copyright © 2016年 brzhang. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import MJRefresh

class AndriodViewController: UIViewController {
	
	let detailViewController = DetailViewController()
	
	var dataList = [AndroidData]()
	
	let pageNum = 20
	var currentPageIndex: Int = 1
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		tableView.dataSource = self
		tableView.contentInset = UIEdgeInsets.init(top: -60, left: 0, bottom: -44, right: 0)
		tableView.delegate = self
		tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
			self.currentPageIndex = 1;
			self.loadData()
		})
		tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
			self.loadData()
		})
		tableView.showsHorizontalScrollIndicator = false;
		tableView.showsVerticalScrollIndicator = false;
		loadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func loadData() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.view.makeToastActivity(.Center)
		
		firstly {
			when(NSURLSession.GET(APIUtils.ANDROID_URL.stringByReplacingOccurrencesOfString("num", withString: String(pageNum)).stringByReplacingOccurrencesOfString("pageindex", withString: String(currentPageIndex))).asDictionary())
		}.then { [unowned self] data -> Void in
			self.currentPageIndex = self.currentPageIndex + 1
			guard let error = data[0]["error"] as? Int else {
				return;
			}
			// 请求成功
			if error == 0 {
				guard let results = data[0]["results"] as? NSArray else {
					print("fetal_error")
					return;
				}
				if self.currentPageIndex == 1 {
					self.dataList.removeAll()
				}
				results.forEach({ (item) in
					if let dic = item as? NSDictionary {
						let androidData = AndroidData()
						androidData.author = dic["who"] as? String
						androidData.desc = dic["desc"] as? String
						androidData.url = dic["url"] as? String
						self.dataList.append(androidData)
					}
				})
				self.tableView.reloadData()
			}
		}.always {
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			self.tableView.mj_header.endRefreshing()
			self.tableView.mj_footer.endRefreshing()
			self.view.hideToastActivity()
		}.error { [unowned self] error in
			let alert = UIAlertController.init(title: "提示", message: "\(error)", preferredStyle: .Alert)
			self.presentViewController(alert, animated: true, completion: {
			})
		}
	}
}

extension AndriodViewController: UITableViewDelegate {
}

extension AndriodViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataList.count
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		guard let url = NSURL.init(string: dataList[indexPath.row].url!) else {
			return
		}
		detailViewController.url = url
		self.navigationController?.pushViewController(detailViewController, animated: false)
		self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("androidCell", forIndexPath: indexPath)
		cell.textLabel?.text = dataList[indexPath.row].desc
		cell.detailTextLabel?.text = dataList[indexPath.row].author
		return cell
	}
}
