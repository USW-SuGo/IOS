//
//  ViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/08.
//

import UIKit

class HomeController: UIViewController {

    //MARK: IBOutlet
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    
    var testList = ["미래", "종강", "IT", "글경", "체대", "인문"]
    
    //MARK: Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        addNavigationBar()
        customRightBarButtons()
    
    }
    
    // 이 후 페이지 생성 시 함수 생성 진행 예정
    @objc func testButtonAction() {
        print("button clicked")
    }
    
    //MARK: Button Action
    
    //MARK: Design
    
    private func customRightBarButtons() {
        let messageButton = self.navigationItem.makeSFSymbolButton(self,
                                               action: #selector(testButtonAction),
                                               symbolName: "message")
        
        let postButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(testButtonAction),
                                                                symbolName: "plus")
        
        let findButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(testButtonAction),
                                                                symbolName: "magnifyingglass")
        
//        let test = self.navi
        
        
        self.navigationItem.rightBarButtonItems = [messageButton, postButton, findButton]
    }
    
    private func customNaviagtionBar() {
    }
    
    private func addNavigationBar() {
        
        // Get Safe Area
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0

        // navigationBar
        let naviBar = UINavigationBar(frame: .init(x: 0,
                                                   y: statusBarHeight,
                                                   width: view.frame.width,
                                                   height: statusBarHeight))
        naviBar.isTranslucent = false
        naviBar.backgroundColor = .systemBackground

        let naviItem = UINavigationItem(title: "SUGO")
        naviItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                      target: self,
                                                      action: nil)
        naviBar.items = [naviItem]
        
        view.addSubview(naviBar)
         
    }

}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell",
                                                      for: indexPath) as! HomeCollectionViewCell
        
        cell.backgroundColor = .white
        cell.placeLabel.text = "장소 : \(testList[indexPath.row])"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postViewStoryboard = UIStoryboard(name: "PostView", bundle: nil)
        let nextViewController =
        postViewStoryboard.instantiateViewController(withIdentifier: "postVC") as! PostController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}

extension HomeController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 2 - 2
        
        let size = CGSize(width: width, height: width + 100)
        return size
        
    }
    
    
}
class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeLabel: UILabel!
    
}

