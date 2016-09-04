//
//  MeiZiViewController.swift
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
import RxSwift
import RxCocoa
import SDWebImage
import MWPhotoBrowser

class MeiZiViewController: UIViewController {
	
	let indentifer = "meiziCell"
	
	var dataList = [MeiZiData]()
	var photos = [MWPhoto]()
	
	let pageNum = 20
	var currentPageIndex: Int = 1
	
	@IBOutlet weak var collectionView: UICollectionView!
	let detailViewController = DetailViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		collectionView.dataSource = self
		collectionView.delegate = self
		
		collectionView.backgroundColor = UIColor.whiteColor()
		collectionView.contentInset = UIEdgeInsets.init(top: -60, left: 0, bottom: -44, right: 0)
		collectionView.registerNib(UINib.init(nibName: String(MeiZiCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: indentifer)
		// collectionView.registerClass(MeiZiCollectionViewCell.self, forCellWithReuseIdentifier: indentifer)
		collectionView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
			self.currentPageIndex = 1;
			self.loadData()
		})
		collectionView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
			self.loadData()
		})
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.showsVerticalScrollIndicator = false;
		loadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
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
		
		// NSThread.sleepForTimeInterval(3)
		
		// if you want to cancel request after 3 seconds have passed just call
		// cancelRequest.dispose()
	}
	
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
}

extension MeiZiViewController: UICollectionViewDelegate {
}

extension MeiZiViewController: UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		showImageDetail(indexPath.row)
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataList.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(indentifer, forIndexPath: indexPath) as! MeiZiCollectionViewCell
		if dataList[indexPath.row].url == nil {
			return cell
		}
		print(dataList[indexPath.row].url);
		cell.imageView.sd_setImageWithURL(NSURL.init(string: dataList[indexPath.row].url!), placeholderImage: UIImage.init(named: "jt.jpg"))
		return cell
	}
}
extension MeiZiViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSizeMake(self.collectionView.frame.width / 2 - 2, self.collectionView.frame.width / 2 - 2)
	}
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(1.5, 0, 1.5, 0)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 1.0
	}
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 1.0
	}
}

extension MeiZiViewController: MWPhotoBrowserDelegate {
	func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
		return UInt.init(photos.count)
	}
	
	func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
		if index < UInt.init(self.photos.count) {
			return self.photos[Int(index)]
		}
		return nil
	}
}
