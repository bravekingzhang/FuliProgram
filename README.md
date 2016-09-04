# FuliProgram
swift学习项目

首先看一个gif动画：
直观的感受一下，这个项目有哪些东东

![demo](http://upload-images.jianshu.io/upload_images/1019822-63ca090fdb01367c.gif?imageMogr2/auto-orient/strip)

然后这里，你可以学到哪些东西：

####1、如何使用UITableview来展示从网络上拉去的 JsonArray数据。
####2、如何自定义一个Cell，并且使用到列表视图中去。
```swift
collectionView.registerNib(UINib.init(nibName: String(MeiZiCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: indentifer)
```
####3、Alamofire 大神级网络加载框架的使用
```swift
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
```
####4、PromiseKit的使用方式demo
```swift
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

```
####5、RxSwift使用的demo
```swift

	private func loadData() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.view.makeToastActivity(.Center)
		let request = NSURLRequest.init(URL: NSURL.init(string: APIUtils.FULI_URL.stringByReplacingOccurrencesOfString("num", withString: String(pageNum)).stringByReplacingOccurrencesOfString("pageindex", withString: String(currentPageIndex)))!)
		if currentPageIndex == 1 {
			self.dataList.removeAll()
		}
		let responseJSON = NSURLSession.sharedSession().rx_JSON(request)
		let cancelRequest = responseJSON
		// .subscribeOn(ImmediateSchedulerT)
		.observeOn(MainScheduler.instance)
			.map({ (data) -> [MeiZiData] in
				var meiziDatas = [MeiZiData]()
				let json = JSON(data)
				if json["error"].boolValue == false {
					if let dataArr = json["results"].array {
						dataArr.forEach({ (jsonobj) in
							let meiziData = MeiZiData()
							meiziData.pubTime = jsonobj["publishedAt"].stringValue
							meiziData.url = jsonobj["url"].stringValue
							meiziDatas.append(meiziData)
						})
					}
				}
				return meiziDatas
		})
			.subscribe(onNext: { [unowned self] data in
				self.dataList.appendContentsOf(data)
				self.collectionView.reloadData()
				self.currentPageIndex = self.currentPageIndex + 1
				}, onError: { (error) in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				self.view.hideToastActivity()
				self.collectionView.mj_header.endRefreshing()
				self.collectionView.mj_footer.endRefreshing()
				}, onCompleted: {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				self.view.hideToastActivity()
				self.collectionView.mj_header.endRefreshing()
				self.collectionView.mj_footer.endRefreshing()
		}) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				self.view.hideToastActivity()
				self.collectionView.mj_header.endRefreshing()
				self.collectionView.mj_footer.endRefreshing()
		}
```
####6、列表的MJRefresh上拉帅新下来加载更多
为什么要使用这么一句？
```swift
collectionView.contentInset = UIEdgeInsets.init(top: -60, left: 0, bottom: -44, right: 0)
```
####7、MWPhotoBrowser实现图片长廊的demo
```swift
private func showImageDetail(currentIndex: Int) {
		let browser = MWPhotoBrowser.init(delegate: self)
		
		photos.removeAll()
		
		dataList.forEach { (data) in
			let photo = MWPhoto.init(URL: NSURL.init(string: data.url!))
			photos.append(photo)
		}
		
		browser.displayActionButton = true; // Show action button to allow sharing, copying, etc (defaults to YES)
		browser.displayNavArrows = false; // Whether to display left and right nav arrows on toolbar (defaults to NO)
		browser.displaySelectionButtons = false; // Whether selection buttons are shown on each image (defaults to NO)
		browser.zoomPhotosToFill = true; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
		browser.alwaysShowControls = false; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
		browser.enableGrid = true; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
		browser.startOnGrid = false; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
		browser.autoPlayOnAppear = false; // Auto-play first video
		
		browser.setCurrentPhotoIndex(1)
		
		self.navigationController?.pushViewController(browser, animated: true)
		
		browser.setCurrentPhotoIndex(UInt(currentIndex))
		
		browser.showNextPhotoAnimated(true)
		browser.showPreviousPhotoAnimated(true)
		browser.setCurrentPhotoIndex(UInt(currentIndex))
	}

```
####8、如何简单的自动布局AutoLayout
####9、webView查看干货详情

