//
//  Container1ViewController.swift
//  Ddabong2
//
//  Created by 이윤주 on 1/11/25.
//

import Foundation
import UIKit
import Alamofire

class Container1ViewController:UIViewController{
    @IBOutlet weak var bg1: UILabel!
    @IBOutlet weak var bg2: UILabel!
    @IBOutlet weak var bg0: UILabel!
    
    @IBOutlet weak var imgNoExp: UIImageView!
    @IBOutlet weak var lblLongestWeek: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var lblWeeksCnt: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var uiView3: UIView!
    
    @IBOutlet weak var lblTitle3: UILabel!
    var expHistory: [String: Int] = [:]
    var resultList: [String] = []
    var historySize:Int = 0
    
    
    @IBOutlet weak var lblGraph2: UILabel!
    @IBOutlet weak var lblGraph1: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    
    // MARK: - ViewModel
    private let userInfoViewModel = UserInfoViewModel()
    private let viewModel = QuestViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // user 이름 설정
        fetchUserInfo()
        
        // 데이터 바인딩 설정
        setupBindings()
        
        // 정렬된 키와 값
        let sortedKeys = self.expHistory.keys.sorted(by: <)
        let sortedValues = sortedKeys.map { expHistory[$0]! }
//        
//        let sortedKeys = ["2023", "2022", "2021", "2020"]
//        let sortedValues = [12000, 10000, 7000, 7000]
        
        view.backgroundColor = UIColor(hex: "fff8f8")
        // 테두리 및 corner radius 설정
        bg1.layer.borderWidth = 1.0 // 테두리 두께
        bg1.backgroundColor = .white
        bg1.layer.borderColor = UIColor(hex: "eaeaea").cgColor // 테두리 색상
        bg1.layer.cornerRadius = 40.0 // 테두리의 둥글기
        bg1.layer.masksToBounds = true // corner radius가 적용되도록 설정
        
        // 테두리 및 corner radius 설정
        bg2.layer.borderWidth = 1.0 // 테두리 두께
        bg2.backgroundColor = .white
        bg2.layer.borderColor = UIColor(hex: "eaeaea").cgColor // 테두리 색상
        bg2.layer.cornerRadius = 40.0 // 테두리의 둥글기
        bg2.layer.masksToBounds = true // corner radius가 적용되도록 설정
        
        // 테두리 및 corner radius 설정
        bg0.layer.borderWidth = 1.0 // 테두리 두께
        bg0.backgroundColor = .white
        bg0.layer.borderColor = UIColor(hex: "eaeaea").cgColor // 테두리 색상
        bg0.layer.cornerRadius = 40.0 // 테두리의 둥글기
        bg0.layer.masksToBounds = true // corner radius가 적용되도록 설정
        
        let graphView = BarGraphView()
        graphView.img = imgNoExp
        graphView.data = sortedValues // sortedValues
        graphView.labels = sortedKeys// sortedKeys
        graphView.lbl1 = lblGraph1
        graphView.lbl2 = lblGraph2
        graphView.backgroundColor = .clear
        graphView.frame = CGRect(x:40, y: 100, width: uiView3.frame.width-100, height: 230)
        graphView.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃 설정을 활성화
        
        uiView3.addSubview(graphView)
        
//        // 오토레이아웃 제약조건 설정
        NSLayoutConstraint.activate([
//            graphView.centerXAnchor.constraint(equalTo: uiView3.centerXAnchor), // uiView3의 가로 중앙에 맞춤
               graphView.widthAnchor.constraint(equalTo: uiView3.widthAnchor, multiplier: 0.83), // uiView3의 너비의 80%로 설정
               graphView.topAnchor.constraint(equalTo: lblTitle3.bottomAnchor, constant: 10), // 적절한 상단 여백
            graphView.heightAnchor.constraint(equalToConstant: 200), // 높이 설정
               graphView.leadingAnchor.constraint(equalTo: uiView3.leadingAnchor, constant: 80) // 좌측 여백
           ])
        
    }
    
    // MARK: - Fetch User Info
    private func fetchUserInfo() {
        userInfoViewModel.fetchUserInfo()
        userInfoViewModel.onUserInfoFetchSuccess = { [weak self] in
            DispatchQueue.main.async {
                guard let user = self?.userInfoViewModel.userInfo else { return }
                self?.updateUI(with: user)
            }
        }
        userInfoViewModel.onUserInfoFetchFailure = { [weak self] errorMessage in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "에러", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    // 이름 설정
    private func updateUI(with user: User) {
        print("이름 설정 - ", user.name)
        lblName.text = "현재 \(user.name)님은"
    }
    
    
    private func setupBindings() {
        viewModel.fetchQuestStats()
        // 성공 시 데이터 처리
        viewModel.responseDto = { [weak self] dto in
            guard let self = self, let dto = dto else { return }
            DispatchQueue.main.async {
                self.lblWeeksCnt.text = "\(dto.challengeCount)주"
                self.lblPercent.text = "\(dto.maxCount)%"
                self.lblLongestWeek.text = "\(dto.maxCount)주🔥"
                self.expHistory = dto.expHistory
                self.resultList = dto.resultList
                self.historySize = dto.historySize
                // 이미지 뷰 배열
                let imageViews = [self.img1, self.img2, self.img3]

                  // resultList 값에 따라 이미지 설정
                  for (index, result) in self.resultList.prefix(3).enumerated() {
                      let imageName = self.getImageName(res: result)
                      imageViews[index]?.image = UIImage(named: imageName)
                  }
            }
        }
    }
    
    func getImageName(res:String)->String{
        if res == "MAX" {
            return "imgRedChecked"
        }else if res == "MED"{
            return "imgYellowChecked"
        }
        else if res == "ETC" {
            return "imgFullBlue"
            //return "imgYellowChecked"
        }else{
            return "imgGrayCircle"
        }
    }
}

class BarGraphView: UIView {
    var data: [Int] = []
    var labels: [String] = []
    var img:UIImageView = UIImageView()
    var lbl1:UILabel = UILabel()
    var lbl2:UILabel = UILabel()
    
    override func draw(_ rect: CGRect) {
        guard data.count > 0 else {
            img.isHidden = false
            lbl1.isHidden = false
            lbl2.isHidden = false
        return }
        
        let maxData = data.max() ?? 1
        let barWidth = rect.width / CGFloat(data.count) - 40
        
        for (index, value) in data.enumerated() {
            let barHeight = (CGFloat(value) / CGFloat(maxData)) * rect.height
            let x = CGFloat(index) * (barWidth + 16)
            let y = rect.height - barHeight
            
            // 막대 그리기
            let bar = UIBezierPath(rect: CGRect(x: x, y: y, width: barWidth, height: barHeight))
            UIColor(hex:"ff8b71").setFill()
            bar.fill()
            
            // 레이블 추가
            let label = UILabel(frame: CGRect(x: x, y: rect.height + 4, width: barWidth, height: 15))
            label.text = String(data[index])
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .center
            addSubview(label)
            
            // 레이블 추가
            let label2 = UILabel(frame: CGRect(x: x, y: rect.height + 20, width: barWidth+6, height: 15))
            label2.text = "\(labels[index])년"
            label2.font = .systemFont(ofSize: 12)
            label2.textAlignment = .center
            addSubview(label2)
        }
    }}
