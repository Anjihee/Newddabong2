import UIKit
import SideMenu
import SwiftUI

class MyPageViewController: UIViewController {
    // MARK: - ViewModels
    private let userInfoViewModel = UserInfoViewModel()
    private let myPageViewModel = MyPageViewModel()
    
    private var sideMenu: SideMenuNavigationController?
    private let expViewModel = ExpViewModel()

    

    // MARK: - UI Components
    private let pinkBackgroundView = UIView() // 핑크 배경
    private let whiteContainerView = UIView() // 흰색 컨테이너
    private let profileImageView = UIImageView() // 프로필 이미지
    private let greetingLabel = UILabel()
    private let fortuneLabel = UILabel()
    
    private let levelLabel = UILabel()
    private let nextLevelLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let progressPercentageLabel = UILabel()

    // 경험치 현황 UI
    private let experienceContainerView = UIView() // 경험치 섹션 컨테이너
    private let experienceTitleLabel = UILabel()
    private let recentExpLabel = UILabel()
    private let recentExpContainerView = UIView() // 최근 경험치 표시 컨테이너
    private let recentExpNameLabel = UILabel() // 경험치 이름 라벨
    private let recentExpDetailLabel = UILabel() // 경험치 세부 정보 라벨
    private let recentExpPointsLabel = UILabel() // 경험치 정보 라벨
    private let questTypeLabel = UILabel() // 퀘스트 타입 라벨

    private let viewAllButton = UIButton(type: .system)
    private let thisYearExpLabel = UILabel()
    private let thisYearProgressBar = UIProgressView(progressViewStyle: .default)
    private let lastYearExpLabel = UILabel()
    private let lastYearProgressBar = UIProgressView(progressViewStyle: .default)
    private let thisYearProgressPercentageLabel = UILabel()
    private let lastYearProgressPercentageLabel = UILabel()

    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white // 배경색을 흰색으로 설정
        super.viewDidLoad()
        setupCustomHeader() // 헤더 설정
        setupUI()
        setupSideMenu()
        bindViewModels()
        fetchData()
    }

    
    private func updateProfileImage() {
        if let avartaId = userInfoViewModel.userInfo?.avartaId,
           let profileImage = UIImage.profileImage(for: avartaId) {
            profileImageView.image = profileImage
        } else {
            print("Image not found or avartaId is nil")
            profileImageView.image = UIImage(named: "avatar1") // 기본 이미지
        }
    }
   
    // MARK: - UI Setup
       private func setupCustomHeader() {
           let headerContainer = UIView()
           headerContainer.backgroundColor = .white
           view.addSubview(headerContainer)
           headerContainer.translatesAutoresizingMaskIntoConstraints = false

           let hamburgerMenu = UIButton()
           hamburgerMenu.setImage(UIImage(named: "drawer"), for: .normal)
           hamburgerMenu.tintColor = .black
           hamburgerMenu.addTarget(self, action: #selector(openSideMenu), for: .touchUpInside)
           headerContainer.addSubview(hamburgerMenu)
           hamburgerMenu.translatesAutoresizingMaskIntoConstraints = false

           let headerTitleLabel = UILabel()
           headerTitleLabel.text = "마이페이지"
           headerTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
           headerTitleLabel.textColor = .black
           headerTitleLabel.textAlignment = .center
           headerContainer.addSubview(headerTitleLabel)
           headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false

           let alertIcon = UIButton()
           alertIcon.setImage(UIImage(named: "alert"), for: .normal)
           alertIcon.addTarget(self, action: #selector(openAlarmViewController), for: .touchUpInside) // 버튼 클릭 시 동작 추가
           alertIcon.tintColor = .black
           headerContainer.addSubview(alertIcon)
           alertIcon.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               headerContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 55), // Safe Area 무시하고 5 아래로 이동
               headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               headerContainer.heightAnchor.constraint(equalToConstant: 50),

               hamburgerMenu.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
               hamburgerMenu.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
               hamburgerMenu.widthAnchor.constraint(equalToConstant: 24),
               hamburgerMenu.heightAnchor.constraint(equalToConstant: 24),

               headerTitleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
               headerTitleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

               alertIcon.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
               alertIcon.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
               alertIcon.widthAnchor.constraint(equalToConstant: 24),
               alertIcon.heightAnchor.constraint(equalToConstant: 24)
           ])
           
       }

    // MARK: - Actions
    @objc private func openAlarmViewController() {
        //        let alarmViewController = AlarmViewController() // AlarmViewController 인스턴스 생성
        //        navigationController?.pushViewController(alarmViewController, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "AlarmViewController")
        nextViewController.modalPresentationStyle = .fullScreen // 전체 화면 전환
        nextViewController.modalTransitionStyle = .coverVertical // 아래에서 위로 전환
        present(nextViewController, animated: true, completion: nil)

    }
    
    // MARK: - UI Setup
    private func setupUI() {

        recentExpContainerView.addSubview(expCircleView)
        // 탭 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRecentExpContainer))
        recentExpContainerView.addGestureRecognizer(tapGesture)
        recentExpContainerView.isUserInteractionEnabled = true // 제스처 인식 활성화
        expCircleView.isUserInteractionEnabled = false // 내부 뷰가 터치 이벤트를 막지 않도록 설정
        
        pinkBackgroundView.backgroundColor = UIColor(red: 1.0, green: 0.956, blue: 0.956, alpha: 1.0) // #FFF4F4
        pinkBackgroundView.layer.cornerRadius = 0
        view.addSubview(pinkBackgroundView)

        whiteContainerView.backgroundColor = .white
        whiteContainerView.layer.cornerRadius = 12
        whiteContainerView.layer.shadowColor = UIColor.black.cgColor
        whiteContainerView.layer.shadowOpacity = 0.1
        whiteContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        whiteContainerView.layer.shadowRadius = 4
        pinkBackgroundView.addSubview(whiteContainerView)

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        // 프로필 이미지 원형 처리
          profileImageView.layer.cornerRadius = 40 // 너비/2로 설정
          profileImageView.layer.borderWidth = 2
          profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        whiteContainerView.addSubview(profileImageView)

        greetingLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        greetingLabel.textAlignment = .right
        whiteContainerView.addSubview(greetingLabel)

        fortuneLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        fortuneLabel.textAlignment = .right
        fortuneLabel.numberOfLines = 0
        whiteContainerView.addSubview(fortuneLabel)

        levelLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        levelLabel.textAlignment = .left
        whiteContainerView.addSubview(levelLabel)

        nextLevelLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nextLevelLabel.textAlignment = .right
        whiteContainerView.addSubview(nextLevelLabel)
        
        // 경험치 정보 라벨
        recentExpPointsLabel.font = UIFont.boldSystemFont(ofSize: 14)
        recentExpPointsLabel.textColor = UIColor.black
        recentExpPointsLabel.textAlignment = .right
        recentExpContainerView.addSubview(recentExpPointsLabel)

        
        progressBar.progressTintColor = UIColor(hex: "#FF6C4A")
        progressBar.trackTintColor = UIColor(hex: "#FFB4A3")
        progressBar.layer.cornerRadius = 5
        progressBar.clipsToBounds = true

        
        whiteContainerView.addSubview(progressBar)
        progressPercentageLabel.font = UIFont.boldSystemFont(ofSize: 14)
        progressPercentageLabel.textAlignment = .center
        progressPercentageLabel.textColor = .white
        whiteContainerView.addSubview(progressPercentageLabel)

        // 경험치 컨테이너 추가
        experienceContainerView.backgroundColor = .clear
        view.addSubview(experienceContainerView)

        experienceTitleLabel.text = "경험치 현황"
        experienceTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        experienceTitleLabel.textAlignment = .left
        experienceContainerView.addSubview(experienceTitleLabel)

        recentExpLabel.text = "최근 획득 경험치"
        recentExpLabel.font = UIFont.boldSystemFont(ofSize: 15)
        recentExpLabel.textColor = UIColor(hex: "#494949") // 텍스트 색상 변경
        recentExpLabel.textAlignment = .left
        experienceContainerView.addSubview(recentExpLabel)
        
        recentExpContainerView.backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.96, alpha: 1.0)
               recentExpContainerView.layer.cornerRadius = 12
               recentExpContainerView.layer.shadowColor = UIColor.black.cgColor
               recentExpContainerView.layer.shadowOpacity = 0.1
               recentExpContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
               recentExpContainerView.layer.shadowRadius = 4
               recentExpContainerView.isUserInteractionEnabled = true

               recentExpContainerView.addGestureRecognizer(tapGesture)
               view.addSubview(recentExpContainerView)

               // 최근 경험치 라벨들
               recentExpNameLabel.font = UIFont.systemFont(ofSize: 16)
               recentExpNameLabel.textColor = .black
               recentExpContainerView.addSubview(recentExpNameLabel)

               recentExpDetailLabel.font = UIFont.systemFont(ofSize: 14)
               recentExpDetailLabel.textColor = .darkGray
               recentExpContainerView.addSubview(recentExpDetailLabel)

               recentExpPointsLabel.font = UIFont.systemFont(ofSize: 14)
               recentExpPointsLabel.textColor = .black
               recentExpContainerView.addSubview(recentExpPointsLabel)

               questTypeLabel.font = UIFont.systemFont(ofSize: 14)
               questTypeLabel.textColor = .darkGray
               recentExpContainerView.addSubview(questTypeLabel)





        thisYearExpLabel.text = "올해 획득한 경험치"
        thisYearExpLabel.font = UIFont.systemFont(ofSize: 14)
        thisYearExpLabel.textColor = UIColor(hex: "#777777")
        

        experienceContainerView.addSubview(thisYearExpLabel)

        thisYearProgressBar.progressTintColor = UIColor(hex: "#FF6C4A")
        thisYearProgressBar.trackTintColor = UIColor(hex: "#FFB4A3")
        experienceContainerView.addSubview(thisYearProgressBar)



        lastYearExpLabel.text = "작년까지 획득한 경험치"
        lastYearExpLabel.font = UIFont.systemFont(ofSize: 14)
        experienceContainerView.addSubview(lastYearExpLabel)
        lastYearExpLabel.textColor = UIColor(hex: "#777777")

        lastYearProgressBar.progressTintColor = UIColor(hex: "#FF6C4A")
        lastYearProgressBar.trackTintColor = UIColor(hex: "#FFB4A3")
        experienceContainerView.addSubview(lastYearProgressBar)
        
        // 올해 퍼센트 라벨
        thisYearProgressPercentageLabel.font = UIFont.boldSystemFont(ofSize: 14)
        thisYearProgressPercentageLabel.textColor = .white
        thisYearProgressPercentageLabel.textAlignment = .center
        experienceContainerView.addSubview(thisYearProgressPercentageLabel)

        // 작년 퍼센트 라벨
        lastYearProgressPercentageLabel.font = UIFont.boldSystemFont(ofSize: 14)
        lastYearProgressPercentageLabel.textColor = .white
        lastYearProgressPercentageLabel.textAlignment = .center
        experienceContainerView.addSubview(lastYearProgressPercentageLabel)
        thisYearProgressPercentageLabel.translatesAutoresizingMaskIntoConstraints = false
        lastYearProgressPercentageLabel.translatesAutoresizingMaskIntoConstraints = false


        // 버튼 클릭 시 ExpAllViewController로 이동
        viewAllButton.addTarget(self, action: #selector(didTapViewAllButton), for: .touchUpInside)
        setConstraints()
    }

    @objc private func didTapViewAllButton() {
        // ExpAllViewController로 이동
        print("전체보기 버튼 클릭됨") // 디버깅용 로그
        let expAllViewController = ExpAllViewController()
        navigationController?.pushViewController(expAllViewController, animated: true)
    }
    
    @objc private func didTapRecentExpContainer() {
        print("최근 경험치 컨테이너 클릭됨") // 디버깅용 로그
//        let expAllViewController = ExpAllViewController()
//        navigationController?.pushViewController(expAllViewController, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "ExpAllViewController")
        nextViewController.modalPresentationStyle = .fullScreen // 전체 화면 전환
        nextViewController.modalTransitionStyle = .coverVertical // 아래에서 위로 전환
        present(nextViewController, animated: true, completion: nil)
    }

    
    private func setConstraints() {
        pinkBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        whiteContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        fortuneLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        nextLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressPercentageLabel.translatesAutoresizingMaskIntoConstraints = false
        experienceContainerView.translatesAutoresizingMaskIntoConstraints = false
        experienceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recentExpLabel.translatesAutoresizingMaskIntoConstraints = false
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
        thisYearExpLabel.translatesAutoresizingMaskIntoConstraints = false
        thisYearProgressBar.translatesAutoresizingMaskIntoConstraints = false
        lastYearExpLabel.translatesAutoresizingMaskIntoConstraints = false
        lastYearProgressBar.translatesAutoresizingMaskIntoConstraints = false
        experienceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recentExpLabel.translatesAutoresizingMaskIntoConstraints = false
        recentExpContainerView.translatesAutoresizingMaskIntoConstraints = false
                recentExpNameLabel.translatesAutoresizingMaskIntoConstraints = false
                recentExpDetailLabel.translatesAutoresizingMaskIntoConstraints = false
                recentExpPointsLabel.translatesAutoresizingMaskIntoConstraints = false
                questTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        

        
        NSLayoutConstraint.deactivate(pinkBackgroundView.constraints)
        NSLayoutConstraint.deactivate(whiteContainerView.constraints)
        
        NSLayoutConstraint.activate([
            // 핑크 배경
               pinkBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
               pinkBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               pinkBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               pinkBackgroundView.heightAnchor.constraint(equalToConstant: 250),

               // 흰색 컨테이너
               whiteContainerView.topAnchor.constraint(equalTo: pinkBackgroundView.topAnchor, constant: 20),
               whiteContainerView.leadingAnchor.constraint(equalTo: pinkBackgroundView.leadingAnchor, constant: 16),
               whiteContainerView.trailingAnchor.constraint(equalTo: pinkBackgroundView.trailingAnchor, constant: -16),
               whiteContainerView.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 30),
               
               // 프로필 이미지
               profileImageView.topAnchor.constraint(equalTo: whiteContainerView.topAnchor, constant: 16),
               profileImageView.leadingAnchor.constraint(equalTo: whiteContainerView.leadingAnchor, constant: 16),
               profileImageView.widthAnchor.constraint(equalToConstant: 80),
               profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
               

               // 환영 인사 라벨
               greetingLabel.topAnchor.constraint(equalTo: whiteContainerView.topAnchor, constant: 16),
               greetingLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
               greetingLabel.trailingAnchor.constraint(equalTo: whiteContainerView.trailingAnchor, constant: -16),
               greetingLabel.heightAnchor.constraint(equalToConstant: 22),

               // 동그라미 위치 설정
                  expCircleView.centerYAnchor.constraint(equalTo: recentExpPointsLabel.centerYAnchor), // 텍스트와 수직 정렬
                  expCircleView.trailingAnchor.constraint(equalTo: recentExpPointsLabel.leadingAnchor, constant: -8), // 텍스트와 간격 설정
                  expCircleView.widthAnchor.constraint(equalToConstant: 12), // 동그라미 너비
                  expCircleView.heightAnchor.constraint(equalTo: expCircleView.widthAnchor), // 정사각형
               // 운세 라벨
               fortuneLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 8),
               fortuneLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
               fortuneLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
              
               // 레벨 정보
               levelLabel.topAnchor.constraint(equalTo: fortuneLabel.bottomAnchor, constant: 16),
               levelLabel.leadingAnchor.constraint(equalTo: whiteContainerView.leadingAnchor, constant: 16),

               nextLevelLabel.centerYAnchor.constraint(equalTo: levelLabel.centerYAnchor),
               nextLevelLabel.trailingAnchor.constraint(equalTo: whiteContainerView.trailingAnchor, constant: -16),

               // 진행 바
               progressBar.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8),
               progressBar.leadingAnchor.constraint(equalTo: whiteContainerView.leadingAnchor, constant: 16),
               progressBar.trailingAnchor.constraint(equalTo: whiteContainerView.trailingAnchor, constant: -16),
               progressBar.heightAnchor.constraint(equalToConstant: 20),

               // 진행 퍼센트 라벨
               progressPercentageLabel.centerXAnchor.constraint(equalTo: progressBar.centerXAnchor),
               progressPercentageLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
               
            // 경험치 현황 타이틀
            experienceTitleLabel.topAnchor.constraint(equalTo: pinkBackgroundView.bottomAnchor, constant: 24),
            experienceTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            experienceTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // 최근 획득 경험치 라벨
            recentExpLabel.topAnchor.constraint(equalTo: experienceTitleLabel.bottomAnchor, constant: 16),
            recentExpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            recentExpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // 최근 경험치 컨테이너
            recentExpContainerView.topAnchor.constraint(equalTo: recentExpLabel.bottomAnchor, constant: 16),
            recentExpContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            recentExpContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            recentExpContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            // 최근 경험치 내부 라벨들
            recentExpNameLabel.topAnchor.constraint(equalTo: recentExpContainerView.topAnchor, constant: 12),
            recentExpNameLabel.leadingAnchor.constraint(equalTo: recentExpContainerView.leadingAnchor, constant: 16),
            
            recentExpDetailLabel.topAnchor.constraint(equalTo: recentExpNameLabel.bottomAnchor, constant: 4),
            recentExpDetailLabel.leadingAnchor.constraint(equalTo: recentExpContainerView.leadingAnchor, constant: 16),
            
            questTypeLabel.bottomAnchor.constraint(equalTo: recentExpContainerView.bottomAnchor, constant: -12),
            questTypeLabel.leadingAnchor.constraint(equalTo: recentExpContainerView.leadingAnchor, constant: 16),
            
            recentExpPointsLabel.centerYAnchor.constraint(equalTo: recentExpContainerView.centerYAnchor),
            recentExpPointsLabel.trailingAnchor.constraint(equalTo: recentExpContainerView.trailingAnchor, constant: -16),
            
            // 올해 획득한 경험치
            thisYearExpLabel.topAnchor.constraint(equalTo: recentExpContainerView.bottomAnchor, constant: 32),
            thisYearExpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            thisYearExpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            thisYearProgressBar.topAnchor.constraint(equalTo: thisYearExpLabel.bottomAnchor, constant: 8),
            thisYearProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            thisYearProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            thisYearProgressBar.heightAnchor.constraint(equalToConstant: 20),
            
            thisYearProgressPercentageLabel.centerXAnchor.constraint(equalTo: thisYearProgressBar.centerXAnchor),
            thisYearProgressPercentageLabel.centerYAnchor.constraint(equalTo: thisYearProgressBar.centerYAnchor),
            
            // 작년까지 획득한 경험치
            lastYearExpLabel.topAnchor.constraint(equalTo: thisYearProgressBar.bottomAnchor, constant: 32),
            lastYearExpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            lastYearExpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            lastYearProgressBar.topAnchor.constraint(equalTo: lastYearExpLabel.bottomAnchor, constant: 8),
            lastYearProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            lastYearProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            lastYearProgressBar.heightAnchor.constraint(equalToConstant: 20),
            
            lastYearProgressPercentageLabel.centerXAnchor.constraint(equalTo: lastYearProgressBar.centerXAnchor),
            lastYearProgressPercentageLabel.centerYAnchor.constraint(equalTo: lastYearProgressBar.centerYAnchor)
        ])

    }

    private func setupCustomTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "마이페이지"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = UIColor.black
        navigationItem.titleView = titleLabel
    }

    private func setupSideMenu() {
        let menuViewController = MenuViewController()
        sideMenu = SideMenuNavigationController(rootViewController: menuViewController)
        sideMenu?.leftSide = true
        sideMenu?.menuWidth = 300
        sideMenu?.presentationStyle = .menuSlideIn
    }

    // MARK: - ViewModel Binding
    private func bindViewModels() {
        myPageViewModel.onMyPageFetchSuccess = { [weak self] in
            guard let self = self, let data = self.myPageViewModel.myPageData else { return }
            DispatchQueue.main.async {
                self.updateUI(with: data)
            }
        }
        myPageViewModel.onMyPageFetchFailure = { errorMessage in
            print("Error fetching MyPage data: \(errorMessage)")
        }
    }

    private func fetchData() {
        userInfoViewModel.fetchUserInfo()
        myPageViewModel.fetchMyPageData()
        expViewModel.fetchAllExps(page: 0, size: 1) { [weak self] in
               DispatchQueue.main.async {
                   self?.updateLatestExp()
               }
           }
    }
    
    // MARK: - 동그라미 뷰 추가
    private let expCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#FF6C4A") // 원의 색상
        view.layer.cornerRadius = 6 // 반지름 설정 (정사각형 -> 원)
        view.clipsToBounds = true
        return view
    }()
    
    private func updateLatestExp() {
           guard let latestExp = expViewModel.getLatestExp() else {
               recentExpNameLabel.text = "최근 완료된 퀘스트 없음"
               recentExpDetailLabel.text = "데이터를 확인해주세요."
               recentExpPointsLabel.text = ""
               questTypeLabel.text = ""
               return
           }

           let title: String
           switch latestExp.questType {
           case "hr": title = "인사평가"
           case "job": title = "직무별 퀘스트"
           case "leader": title = "리더부여 퀘스트"
           default: title = "전사 프로젝트"
           }

           recentExpNameLabel.text = latestExp.name
           //recentExpDetailLabel.text = "\(latestExp.questType)"
           //recentExpDetailLabel.text = "\(latestExp.questType)"
           recentExpPointsLabel.text = "\(latestExp.expAmount) D"
           questTypeLabel.text = title
       }

    private func updateUI(with data: MyPageResponseDto) {
        greetingLabel.text = "\(userInfoViewModel.userInfo?.name ?? "")님, 안녕하세요!"
        
        // 날짜 변환 (n월 n일 형식)
        let formattedDate = formatToMonthDay(data.fortune.date)
        let firstPart = "\(formattedDate) 오늘의 운세"
        let secondPart = "\(data.fortune.contents)"
        
        // 전체 텍스트 생성
        let fullText = "\(firstPart)\n\(secondPart)"

        // NSMutableAttributedString으로 스타일 지정
        let attributedText = NSMutableAttributedString(string: fullText)

        // 첫 번째 부분 스타일 설정 (세미볼드, 글씨 크기 15)
        if let range = fullText.range(of: firstPart) {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: nsRange)
        }

        // 두 번째 부분 스타일 설정 (글씨 크기 13, 색상 777777)
        if let range = fullText.range(of: secondPart) {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: nsRange)
            attributedText.addAttribute(.foregroundColor, value: UIColor(hex: "#777777"), range: nsRange)
        }

        // 설정한 스타일을 레이블에 적용
        fortuneLabel.attributedText = attributedText

        
        
        // 텍스트 분리
        let levelText = "\(data.levelRate.currentLevel)"
        let expText = "\(data.levelRate.currentExp)"

        // 공백 텍스트 생성 (크기 13)
        let spaceText = "\n"

        // 전체 텍스트 생성
        let fullText2 = "\(spaceText)\(levelText) \(expText)"

        // NSMutableAttributedString으로 스타일 지정
        let attributedText2 = NSMutableAttributedString(string: fullText2)

        // 첫 번째 부분 스타일 설정 (볼드)
        if let range = fullText2.range(of: levelText) {
            let nsRange = NSRange(range, in: fullText2)
            attributedText2.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: nsRange)
            attributedText2.addAttribute(.foregroundColor, value: UIColor(hex: "#FF704F"), range: nsRange)
        }

        // 공백 텍스트 스타일 설정 (크기 13)
        if let range = fullText2.range(of: spaceText) {
            let nsRange = NSRange(range, in: fullText2)
            attributedText2.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: nsRange)
            attributedText2.addAttribute(.foregroundColor, value: UIColor.clear, range: nsRange) // 투명색으로 설정
        }

        // 두 번째 부분 스타일 설정 (세미볼드)
        if let range = fullText2.range(of: expText) {
            let nsRange = NSRange(range, in: fullText2)
            attributedText2.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: nsRange)
            attributedText2.addAttribute(.foregroundColor, value: UIColor(hex: "#FF704F"), range: nsRange)
        }

        // 설정한 스타일을 레이블에 적용
        levelLabel.numberOfLines = 0 // 멀티라인 활성화
        levelLabel.attributedText = attributedText2


        
        
        // 텍스트 분리
        let titleText = "내년도 예상 레벨\n"
        let nextLevelText = "\(data.levelRate.nextLevel) 승급까지 "
        let leftExpText = "\(data.levelRate.leftExp)D"

        // 전체 텍스트 생성
        let fullText3 = "\(titleText)\(nextLevelText)\(leftExpText)"

        // NSMutableAttributedString으로 스타일 지정
        let attributedText3 = NSMutableAttributedString(string: fullText3)

        // 첫 번째 줄 스타일 설정 ("내년도 예상 레벨")
        if let range = fullText3.range(of: titleText) {
            let nsRange = NSRange(range, in: fullText3)
            attributedText3.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13), range: nsRange)
            attributedText3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#777777"), range: nsRange)
        }

        // 두 번째 줄 스타일 설정 ("nextLevel 승급까지")
        if let range = fullText3.range(of: nextLevelText) {
            let nsRange = NSRange(range, in: fullText3)
            attributedText3.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: nsRange) // 볼드 처리
            attributedText3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#FF704F"), range: nsRange)
        }

        // 세 번째 줄 스타일 설정 ("leftExp D")
        if let range = fullText3.range(of: leftExpText) {
            let nsRange = NSRange(range, in: fullText3)
            attributedText3.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: nsRange) // 볼드 처리
            attributedText3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#FF704F"), range: nsRange)
        }

        // 설정한 스타일을 레이블에 적용
        nextLevelLabel.numberOfLines = 2
        nextLevelLabel.attributedText = attributedText3

        // 설정한 스타일을 레이블에 적용
        nextLevelLabel.numberOfLines = 2
        nextLevelLabel.attributedText = attributedText3


        let progressValue = Float(data.levelRate.percent) / 100.0
        progressBar.progress = progressValue
        progressPercentageLabel.text = "\(data.levelRate.percent)%"

        thisYearExpLabel.text = "올해 획득한 경험치 \(data.thisYearExp.expAmount)"
        thisYearProgressBar.progress = Float(data.thisYearExp.percent) / 100.0
        thisYearProgressBar.layer.cornerRadius = 5
        thisYearProgressBar.clipsToBounds = true

        lastYearExpLabel.text = "작년까지 획득한 경험치 \(data.lastYearExp.expAmount)"
        lastYearProgressBar.progress = Float(data.lastYearExp.percent) / 100.0
        lastYearProgressBar.layer.cornerRadius = 5
        lastYearProgressBar.clipsToBounds = true

        recentExpLabel.text = "최근 획득 경험치"
        thisYearProgressPercentageLabel.text = "\(data.thisYearExp.percent)%"
        lastYearProgressPercentageLabel.text = "\(data.lastYearExp.percent)%"

    }

    private func formatToMonthDay(_ isoDateString: String) -> String {
        // 입력 형식: "yyyy-MM-dd"
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일
        inputFormatter.dateFormat = "yyyy-MM-dd" // 서버 제공 형식에 맞춤

        // 입력 문자열을 Date로 변환
        guard let date = inputFormatter.date(from: isoDateString) else {
            return "날짜 형식 오류"
        }

        // 출력 형식: "MM월 dd일"
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일
        outputFormatter.dateFormat = "MM월 dd일" // 예: "01월 13일"

        return outputFormatter.string(from: date)
    }

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
        fetchData() // 데이터를 갱신
        
        // 사용자 정보 및 UI 업데이트
               userInfoViewModel.fetchUserInfo()
               userInfoViewModel.onUserInfoFetchSuccess = { [weak self] in
                   DispatchQueue.main.async {
                       self?.updateProfileImage()
                   }
               }

        
           // 레이아웃 갱신 방지
           navigationController?.navigationBar.isHidden = true
       }

    
    //사이드뷰
    @objc private func openSideMenu() {
        guard let sideMenu = sideMenu else { return }
        present(sideMenu, animated: true, completion: nil)
    }
    
    
   

}
