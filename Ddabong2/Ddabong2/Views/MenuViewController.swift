import UIKit

class MenuViewController: UIViewController {

    // MARK: - ViewModel
    private let userInfoViewModel = UserInfoViewModel()

    // MARK: - UI Components
    private let profileBackgroundView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let userInfoStackView = UIStackView()
    private let menuTableView = UITableView()
    private let menuItems = ["프로필 수정", "비밀번호 변경", "로그아웃"]
    private let menuIcons = ["drawer_edit", "drawer_pw", "drawer_logout"]

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
        setupConstraints()
        fetchUserInfo()
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

    
    private func updateUI(with user: User) {
        // 아바타 ID로 프로필 이미지 설정
        if let profileImage = UIImage.profileImage(for: user.avartaId) {
            profileImageView.image = profileImage
        } else {
            profileImageView.image = UIImage(named: "defaultAvatar") // 기본 이미지
        }

        // 이름과 ID 설정
        nameLabel.text = user.name
        idLabel.text = user.id

        // User Info StackView 업데이트
        let userInfoItems = [
            ("사 번", "\(user.employeeNum)"),
            ("소 속", user.department),
            ("입사일", user.joinedAt),
            ("레 벨", user.level)
        ]

        userInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // 기존 정보 제거
        for (title, value) in userInfoItems {
            let label = createUserInfoLabel(title: title, value: value)
            userInfoStackView.addArrangedSubview(label)
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Profile Background View with Image
        setupBackgroundImage(for: profileBackgroundView)
        view.addSubview(profileBackgroundView)

        // Profile Image
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 40 // Circular Image
        profileImageView.layer.borderWidth = 2 // 테두리 두께
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor // 연한 회색 테두리
        profileBackgroundView.addSubview(profileImageView)

        // Name Label
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = UIColor.black
        profileBackgroundView.addSubview(nameLabel)

        // ID Label
        idLabel.font = UIFont.systemFont(ofSize: 14)
        idLabel.textColor = UIColor.gray
        profileBackgroundView.addSubview(idLabel)

        // User Info StackView
        userInfoStackView.axis = .vertical
        userInfoStackView.spacing = 8
        userInfoStackView.alignment = .leading
        userInfoStackView.distribution = .equalSpacing
        profileBackgroundView.addSubview(userInfoStackView)

        // Menu TableView
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.separatorStyle = .none
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        view.addSubview(menuTableView)
    }

    private func setupBackgroundImage(for view: UIView) {
        let backgroundImage = UIImageView(image: UIImage(named: "drawerback"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        view.addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createUserInfoLabel(title: String, value: String) -> UILabel {
        let label = UILabel()
        let fullText = "\(title) \(value)"
        let attributedText = NSMutableAttributedString(string: fullText)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: (fullText as NSString).range(of: title))
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: (fullText as NSString).range(of: value))
        label.attributedText = attributedText
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }

    // MARK: - Constraints
    private func setupConstraints() {
        profileBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        menuTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Profile Background View
            profileBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), // Safe Area 기준으로 시작
            profileBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileBackgroundView.heightAnchor.constraint(equalToConstant: 300), // Adjusted height for proper display

            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: profileBackgroundView.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: profileBackgroundView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            // Name Label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileBackgroundView.leadingAnchor, constant: 20),

            // ID Label
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: profileBackgroundView.leadingAnchor, constant: 20),

            // User Info StackView
            userInfoStackView.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 16),
            userInfoStackView.leadingAnchor.constraint(equalTo: profileBackgroundView.leadingAnchor, constant: 20),
            userInfoStackView.trailingAnchor.constraint(equalTo: profileBackgroundView.trailingAnchor, constant: -20),

            // Menu TableView
            menuTableView.topAnchor.constraint(equalTo: profileBackgroundView.bottomAnchor),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = .black
        cell.imageView?.image = UIImage(named: menuIcons[indexPath.row])
        cell.imageView?.tintColor = .black
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let changeProfileVC = ChangeProfileViewController() // ChangeProfileViewController 초기화
            navigationController?.pushViewController(changeProfileVC, animated: true) // 화면 전환
            print("프로필 수정 선택됨")

        case 1:
            let changePasswordVC = ChangePasswordViewController()
            navigationController?.pushViewController(changePasswordVC, animated: true)
            print("비밀번호 변경 선택됨")
        case 2:
            print("로그아웃 선택됨")
            showLogoutModal()
        default:
            break
        }
    }
    // MARK: - 로그아웃 모달 띄우기
       private func showLogoutModal() {
           let modalVC = LogoutModalViewController()
           modalVC.modalPresentationStyle = .overFullScreen
           modalVC.onConfirm = {
               LogoutService.shared.logoutUser { success in
                   if success {
                       // 로그아웃 성공 처리: 로그인 화면으로 이동
                       DispatchQueue.main.async {
                           let loginVC = LoginViewController()
                           loginVC.modalPresentationStyle = .fullScreen
                           self.present(loginVC, animated: true, completion: nil)
                       }
                   } else {
                       // 로그아웃 실패 처리
                       DispatchQueue.main.async {
                           let alert = UIAlertController(title: "오류", message: "로그아웃에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                           self.present(alert, animated: true, completion: nil)
                       }
                   }
               }
           }
           present(modalVC, animated: true, completion: nil)
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 사용자 정보 다시 가져오기
        fetchUserInfo()
    }

}
