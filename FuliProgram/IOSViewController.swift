//
//  IOSViewController.swift
//  FuliProgram
//
//  Created by brzhang on 16/9/4.
//  Copyright © 2016年 brzhang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh
import Alamofire_SwiftyJSON

class IOSViewController: UIViewController {
	
	var dataList = [IOSData]()
	
	let pageNum = 20
	var currentPageIndex: Int = 1
	
	let detailViewController = DetailViewController()
	
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		tableView.dataSource = self
		tableView.delegate = self
		tableView.contentInset = UIEdgeInsets.init(top: -60, left: 0, bottom: -44, right: 0)
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
		Alamofire.request(.GET,
			APIUtils.IOS_URL.stringByReplacingOccurrencesOfString("num", withString: String(pageNum)).stringByReplacingOccurrencesOfString("pageindex", withString: String(currentPageIndex))).responseSwiftyJSON { [unowned self](response) in
				if response.result.isSuccess {
					if response.result.value!["error"].boolValue == false {
						if let dataArr = response.result.value!["results"].array {
							dataArr.forEach({ (jsonobj) in
								let iosdata = IOSData()
								iosdata.author = jsonobj["who"].stringValue
								iosdata.desc = jsonobj["desc"].stringValue
								iosdata.url = jsonobj["url"].stringValue
								self.dataList.append(iosdata)
							})
							self.tableView.reloadData()
						}
					}
				}
				self.tableView.mj_footer.endRefreshing();
				self.tableView.mj_header.endRefreshing();
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				self.view.hideToastActivity()
		}
	}
}

extension IOSViewController: UITableViewDelegate {
}

extension IOSViewController: UITableViewDataSource {
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
		let cell = tableView.dequeueReusableCellWithIdentifier("iosCell", forIndexPath: indexPath)
		cell.textLabel?.text = dataList[indexPath.row].desc
		cell.detailTextLabel?.text = dataList[indexPath.row].author
		return cell
	}
}
