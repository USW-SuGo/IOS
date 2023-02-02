//
//  PostController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/17.
//

import UIKit

import Alamofire
import ImageSlideshow
import KeychainSwift
import SwiftyJSON

// 리펙토링

class PostController: UIViewController {

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: IBOutlets
    
  @IBOutlet weak var slideshow: ImageSlideshow!
  @IBOutlet weak var sugoButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var placeUpdateCategoryLabel: UILabel!
  @IBOutlet weak var nicknameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var contentView: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  
  //MARK: Properties
    
  var productPostId = 0
  var productContentsDetail = ProductContentsDetail()
  var alamofireSource: [AlamofireSource] = []
  var indexDelegate: MessageRoomIndex?
    
  //MARK: Functions
    
  override func viewDidLoad() {
    super.viewDidLoad()
    customBackButton()
    getPostProduct()
    getMyIndex()
    designButtons()
  }
  
  //MARK: Functions
    
  private func setSlideShow() {
    // 이미지 포지션
    slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
    slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

    let pageIndicator = UIPageControl()
    pageIndicator.currentPageIndicatorTintColor = UIColor.systemGreen
    pageIndicator.pageIndicatorTintColor = UIColor.lightGray
    slideshow.pageIndicator = pageIndicator

    // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
    slideshow.activityIndicator = DefaultActivityIndicator()
    slideshow.delegate = self

    // image input
    slideshow.setImageInputs(alamofireSource)

    // page 넘기기 이벤트
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
    slideshow.addGestureRecognizer(recognizer)
  }
    
  @objc func didTap() {
     let fullScreenController = slideshow.presentFullScreenController(from: self)
     // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
     fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium,
                                                                                 color: nil)
   }
    
  //MARK: API Functions
  
  private func getMyIndex() {
    let url = API.BASE_URL + "/user/identifier"
    guard let accessToken = KeychainSwift().get("AccessToken") else { return }
    let header: HTTPHeaders = ["Authorization" : accessToken]
    
    AF.request(url,
               method: .get,
               encoding: URLEncoding.default,
               headers: header,
               interceptor: BaseInterceptor()).validate().response { response in
      guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
      guard let data = response.data else { return }
      self.productContentsDetail.myIndex = JSON(data)["userId"].intValue
    }
  }
    
  private func getPostProduct() {
      AlamofireManager
          .shared
          .session
          .request(PostRouter.getDetailPost(productIndex: productPostId))
          .validate()
          .response { response in
            guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
            self.updatePost(json: JSON(response.data ?? "") )
    }
  }
    
    private func updatePost(json: JSON) {
      guard json != "" else {
        self.navigationController?.popViewController(animated: true)
        return }
      productContentsDetail.jsonToProductContentsDetail(json: json)
      for i in 0..<productContentsDetail.imageLink.count {
          alamofireSource.append(AlamofireSource(urlString: productContentsDetail.imageLink[i])!)
      }
      setSlideShow()
      updateDesign()
    }
    
  //MARK: Button Actions
  
  @IBAction func userInfoButtonClicked(_ sender: Any) {
    let userInfoView = UIStoryboard(name: "UserInfoView", bundle: nil)
    let userInfoController = userInfoView.instantiateViewController(withIdentifier: "userInfoVC")
    present(userInfoController, animated: true)
  }
  
  @IBAction func likeButtonClicked(_ sender: Any) {
    let url = "https://api.sugo-diger.com/like"
    let parameter = ["productPostId" : productContentsDetail.productIndex]
    guard let accessToken = KeychainSwift().get("AccessToken") else { return }
    let header: HTTPHeaders = ["Authorization" : accessToken]
    
    AF.request(url,
               method: .post,
               parameters: parameter,
               encoding: JSONEncoding.default,
               headers: header,
               interceptor: BaseInterceptor()).validate().response { response in
      guard let statusCode = response.response?.statusCode, statusCode == 200 else {
        self.customAlert(title: "자신의 게시물이에요!", message: "자신의 게시물은 좋아요할 수 없어요!")
        return }
      guard let responseData = response.data else { return }
      
      JSON(responseData)["Like"].boolValue ?
      self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal) :
      self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
  }
  
  // 서버에서 쪽지방 삭제 기능 구현 이후 테스트 가능
  @IBAction func sugoButtonClicked(_ sender: Any) {
    AlamofireManager
      .shared
      .session
      .request(MessageRouter.makeMessageRoom(opponentIndex: productContentsDetail.userIndex,
                                             productIndex: productContentsDetail.productIndex))
      .validate()
      .response { response in
        
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          print(JSON(response.data))
          return }
        guard let data = response.data else { return }
        print(JSON(data))
        // 수고하기 버튼 클릭 후 바로 쪽지방으로 연결, 쪽지 데이터 없을 경우 공지사항같은거 만들어줘야 함
        let messageRoomView = UIStoryboard(name: "MessageRoomView", bundle: nil)
        guard let messageRoomController = messageRoomView.instantiateViewController(withIdentifier: "messageRoomVC") as? MessageRoomController else { return }
        self.indexDelegate?.getIndex(roomIndex: JSON(data)["noteId"].intValue,
                                     myIndex: self.productContentsDetail.myIndex,
                                     oppositeIndex: self.productContentsDetail.userIndex)
        self.navigationController?.pushViewController(messageRoomController, animated: true)
      }
  }
  
  //MARK: Design Functions
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
    
  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }
  
  private func updateDesign() {
    titleLabel.text = productContentsDetail.title
    placeUpdateCategoryLabel.text = "\(productContentsDetail.contactPlace) | \(productContentsDetail.updatedAt) | \(productContentsDetail.category)"
    nicknameLabel.text = productContentsDetail.nickname
    priceLabel.text = productContentsDetail.price
    contentView.text = productContentsDetail.content
    productContentsDetail.userLikeStatus ?
    likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal) :
    likeButton.setImage(UIImage(systemName: "heart"),for: .normal)
  }

  private func designButtons() {
    sugoButton.layer.cornerRadius = 6.0
    sugoButton.layer.borderWidth = 1.0
    sugoButton.layer.borderColor = UIColor.white.cgColor
  }

}

extension PostController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}

