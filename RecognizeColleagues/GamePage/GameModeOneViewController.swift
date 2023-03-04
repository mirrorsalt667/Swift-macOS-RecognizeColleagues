//
//  GameModeOneViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/11/23.
//

import Cocoa

// 預計4人8題，隨機選擇
/// 示範題目
/// １ 取得資料
/// ２ 用中文名字
/// ３ 隨機抽四個人，顯示其中一個名字為答案，四個人到用完為止都不重複
/// 要２個陣列，一個存答案，一個存出過的題目
/// 答錯的再次出現
/// ４ 準備兩種樣式，答對或答錯
/// ５ 計分？輪流回答
/// ６ 三人進階成四人

final class GameModeOneViewController: NSViewController {
    // MARK: - Properties
    
    @IBOutlet private var viewTitle: NSTextField!
    @IBOutlet private var questionLabel: NSTextField!
    @IBOutlet private var questionIndexLabel: NSTextField!
    @IBOutlet private var selection_AButton: NSButton!
    @IBOutlet private var selection_AStackView: NSStackView!
    @IBOutlet private var selection_BButton: NSButton!
    @IBOutlet private var selection_BStackView: NSStackView!
    @IBOutlet private var selection_CButton: NSButton!
    @IBOutlet private var selection_CStackView: NSStackView!
    @IBOutlet private var selection_DButton: NSButton!
    @IBOutlet private var selection_DStackView: NSStackView!
    
    private let mCoreData = CoreDataClass()
    private var mColleagueDetails = [Colleagues]() {
        didSet {
            // 1 選出第一題
            if let theFirstQuestion = choosePeople(people: mColleagueDetails) {
                // 2 選出答案
                var dynamicArray = theFirstQuestion
                let answerIndex = fourChooseOneBeTheAnswer()
                let _ = dynamicArray.remove(at: answerIndex)
                putInEachArray(answer: theFirstQuestion[answerIndex], others: dynamicArray)
                // 3 記錄答案
                answerUUID = theFirstQuestion[answerIndex].uuid!
                mAnswerStr = theFirstQuestion[answerIndex].chineseName!
                // 4 記錄題目
                mNowQuestionColleagues = theFirstQuestion
                // 5 展示在畫面
                DispatchQueue.main.async {
                    self.showQuestionOnTheView(all: theFirstQuestion, answer: answerIndex)
                }
            }
        }
    }
    // 現在的題號
    private var mNowQuestionNumber = 1
    private let mTotalQuestionAmount = 8
    // 問句
    private let mQuestionFrontSentence = "以下哪個選項是"
    // 答案
    private var mAnswerStr = ""
    // 正確答案的uuid
    private var answerUUID: UUID?
    // 現在題目的四個選項
    private var mNowQuestionColleagues = [Colleagues]()
    // 現在的選擇
    private var mSelectedItem: Int? // button tag
    
    // 出過的陣列
    private var mShowOutColleagues = [Colleagues]()
    // 是答案的陣列
    private var mIsTheAnswerColleagues = [Colleagues]()
    //是題目但不是答案的陣列
    private var mShowOutButNotAnswerColleagues = [Colleagues]()
    // 剩下的陣列
    private var mNotShowOutYetColleagues = [Colleagues]()
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionIndexLabel.stringValue = "進行中題目"
        changeWindowSize()
        setupComponents()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // 1 取得所有資料
        mCoreData.loadDataBase { details in
            self.mColleagueDetails = details
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        viewStyle()
    }
}

// MARK: - Action

extension GameModeOneViewController {
    @IBAction private func confirmSelectItemAction(_: NSButton) {
        confirmTheSelectedItem()
    }
    @IBAction private func selection_AAction(sender: NSButton) {
        print("有觸發Ａ")
        redBorderWhenSelect(selectButton: sender)
    }
    @IBAction private func selection_BAction(sender: NSButton) {
        print("有觸發Ｂ")
        redBorderWhenSelect(selectButton: sender)
    }
    @IBAction private func selection_CAction(sender: NSButton) {
        print("有觸發Ｃ")
        redBorderWhenSelect(selectButton: sender)
    }
    @IBAction private func selection_DAction(sender: NSButton) {
        print("有觸發Ｄ")
        redBorderWhenSelect(selectButton: sender)
    }
    @IBAction private func stopAndBackToFrontAction(_: Any) {
        overAlert {
            self.backToFrontPage()
        }
    }
}

// MARK: - Methods

extension GameModeOneViewController {
    // 選擇語言
//    private func chooseNameLanguage() -> LanguageEnum {
//        let random = Int.random(in: 0...1)
//        switch random {
//        case 0: return LanguageEnum.chinese
//        default: return LanguageEnum.english
//        }
//    }
    // 選出人
    /// 隨機選出這個題目需要的人
    /// - Parameters:
    ///   - people: 還沒當過題目的人
    private func choosePeople(people: [Colleagues]) -> [Colleagues]? {
        var newArray = people.shuffled()
        if newArray.count >= 4 {
            let firstFour = [newArray[0], newArray[1], newArray[2], newArray[3]]
            for k in 0...3 {
                // 出過的題目
                mShowOutColleagues.append(firstFour[k])
                newArray.removeFirst()
            }
            // 還沒出過的題目
            mNotShowOutYetColleagues = newArray
            return firstFour
        } else {
            // 都用完了，加入以前不是答案的人
            let randomTheArray = mShowOutButNotAnswerColleagues.shuffled()
            // 清空不是答案的陣列，重新再放入
            mShowOutButNotAnswerColleagues = []
            // 新的魚池
            var renewArray = newArray + randomTheArray
            if renewArray.count >= 4 {
                let firstFour = [renewArray[0], renewArray[1], renewArray[2], renewArray[3]]
                // 出過的題目重置
                mShowOutColleagues = []
                for k in 0...3 {
                    // 出過的題目
                    mShowOutColleagues.append(firstFour[k])
                    renewArray.removeFirst()
                }
                // 還沒出過的題目變成空的
                mNotShowOutYetColleagues = renewArray
                return firstFour
            }
        }
        return nil
    }
    
    // 0-3隨機選一個數字當答案
    private func fourChooseOneBeTheAnswer() -> Int {
        let chooseIndex = Int.random(in: 0...3)
        return chooseIndex
    }
    
    // 將陣列紀錄下來
    private func putInEachArray(answer: Colleagues, others: [Colleagues]) {
        // 答案
        mIsTheAnswerColleagues.append(answer)
        for k in 0...2 {
            // 不是答案
            mShowOutButNotAnswerColleagues.append(others[k])
        }
    }
    
    // 秀出題目
    private func showQuestionOnTheView(all: [Colleagues], answer: Int) {
        selection_AButton.image = NSImage(contentsOfFile: all[0].photo!)
        selection_BButton.image = NSImage(contentsOfFile: all[1].photo!)
        selection_CButton.image = NSImage(contentsOfFile: all[2].photo!)
        selection_DButton.image = NSImage(contentsOfFile: all[3].photo!)
        questionLabel.stringValue = mQuestionFrontSentence + " " + mAnswerStr + " ？"
        questionIndexLabel.stringValue = "\(mNowQuestionNumber)/\(mTotalQuestionAmount)"
    }
    
    // 按下確定
    private func confirmTheSelectedItem() {
        // 1 檢查有沒有選擇東西
        if let selectedItem = mSelectedItem {
            if mNowQuestionColleagues[selectedItem].uuid! == answerUUID! {
                // 答對了
                // 1 洗掉選擇的項目
                mSelectedItem = nil
                // 2 跳出答對的提醒
                // 是不是最後？
                if mNowQuestionNumber == mTotalQuestionAmount {
                    rightAnswerAlert(message: "終於結束了🙄") {
                        let storyboard = NSStoryboard(name: "Main", bundle: nil)
                        if let front = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController {
                            self.view.window?.contentViewController = front
                        }
                    }
                } else {
                    rightAnswerAlert(message: "太簡單了吧😆") {
                        // 3 準備下一題
                        //   -- 1 選出第一題
                        if let theQuestion = self.choosePeople(people: self.mNotShowOutYetColleagues) {
                            //   -- 2 選出答案
                            var dynamicArray = theQuestion
                            let answerIndex = self.fourChooseOneBeTheAnswer()
                            let _ = dynamicArray.remove(at: answerIndex)
                            self.putInEachArray(answer: theQuestion[answerIndex], others: dynamicArray)
                            //   -- 3 重置資料
                            self.renewVariable()
                            //   -- 4 記錄答案
                            self.answerUUID = theQuestion[answerIndex].uuid!
                            self.mAnswerStr = theQuestion[answerIndex].chineseName!
                            //   -- 5 記錄題目
                            self.mNowQuestionColleagues = theQuestion
                            DispatchQueue.main.async {
                                // -- 6 重置畫面
                                self.renewView()
                                // -- 7 展示畫面
                                self.showQuestionOnTheView(all: theQuestion, answer: answerIndex)
                            }
                        }
                    }
                }
            } else {
                // 答錯了
                // 1 洗掉選擇的項目
                mSelectedItem = nil
                // 2 鎖住該按鈕
                DispatchQueue.main.async {
                    self.wrongItem(tag: selectedItem)
                    // 3 跳出答錯提醒
                    self.wrongAnswerAlert().runModal()
                }
            }
        }
    }
    
    // 答錯的按鈕狀態
    private func wrongItem(tag: Int) {
        switch tag {
        case selection_AButton.tag:
            selection_AButton.isEnabled = false
            selection_AStackView.layer?.borderColor = .clear
        case selection_BButton.tag:
            selection_BButton.isEnabled = false
            selection_BStackView.layer?.borderColor = .clear
        case selection_CButton.tag:
            selection_CButton.isEnabled = false
            selection_CStackView.layer?.borderColor = .clear
        case selection_DButton.tag:
            selection_DButton.isEnabled = false
            selection_DStackView.layer?.borderColor = .clear
        default: break
        }
    }
    
    // 重置畫面設定
    private func renewView() {
        selection_AButton.isEnabled = true
        selection_BButton.isEnabled = true
        selection_CButton.isEnabled = true
        selection_DButton.isEnabled = true
        selection_AStackView.layer?.borderColor = .clear
        selection_BStackView.layer?.borderColor = .clear
        selection_CStackView.layer?.borderColor = .clear
        selection_DStackView.layer?.borderColor = .clear
    }
    
    private func renewVariable() {
        // 現在的題號
        mNowQuestionNumber += 1
        // 答案
        mAnswerStr = ""
        // 正確答案的uuid
        answerUUID = nil
        // 現在題目的四個選項
        mNowQuestionColleagues = []
        // 現在的選擇
        mSelectedItem = nil
    }
    
    // 選取時出現框線
    private func redBorderWhenSelect(selectButton: NSButton) {
        selection_AStackView.layer?.borderColor = .clear
        selection_BStackView.layer?.borderColor = .clear
        selection_CStackView.layer?.borderColor = .clear
        selection_DStackView.layer?.borderColor = .clear
        let tag = selectButton.tag
        // 紀錄選擇的tag
        mSelectedItem = tag
        switch tag{
        case 0:
            selection_AStackView.layer?.borderColor = NSColor(red: 0.734, green: 0.3, blue: 0.3, alpha: 1).cgColor
            selection_AStackView.layer?.borderWidth = 4
        case 1:
            selection_BStackView.layer?.borderColor = NSColor(red: 0.734, green: 0.3, blue: 0.3, alpha: 1).cgColor
            selection_BStackView.layer?.borderWidth = 4
        case 2:
            selection_CStackView.layer?.borderColor = NSColor(red: 0.734, green: 0.3, blue: 0.3, alpha: 1).cgColor
            selection_CStackView.layer?.borderWidth = 4
        case 3:
            selection_DStackView.layer?.borderColor = NSColor(red: 0.734, green: 0.3, blue: 0.3, alpha: 1).cgColor
            selection_DStackView.layer?.borderWidth = 4
        default: break
        }
    }
    
    // 畫面樣式
    private func viewStyle() {
        selection_AStackView.layer?.cornerRadius = 5
        selection_BStackView.layer?.cornerRadius = 5
        selection_CStackView.layer?.cornerRadius = 5
        selection_DStackView.layer?.cornerRadius = 5
    }
    
    // 警告提示框
    private func rightAnswerAlert(message: String, afterConfirm: @escaping () -> (Void)) {
        guard let window = self.view.window else { return }
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "person.fill.checkmark", accessibilityDescription: nil)
        alert.addButton(withTitle: "確認")
        alert.messageText = message
        alert.beginSheetModal(for: window) { [unowned self] (response) in
            afterConfirm()
        }
    }
    
    private func wrongAnswerAlert() -> NSAlert {
        // 黃色的警告圖示
        let message = "答錯囉～❌"
        let userInfo = [NSLocalizedDescriptionKey: "答錯"]
        let error = NSError(domain: NSOSStatusErrorDomain, code: 0, userInfo: userInfo)
        let alertController = NSAlert(error: error)
        alertController.icon = NSImage(systemSymbolName: "xmark", accessibilityDescription: nil)
        alertController.addButton(withTitle: "BBQ了")
        alertController.messageText = message
        return alertController
    }
    
    private func overAlert(afterConfirm: @escaping () -> (Void)) {
        guard let window = self.view.window else { return }
        let alert = NSAlert()
        alert.icon = NSImage(systemSymbolName: "exclamationmark.octagon", accessibilityDescription: nil)
        alert.addButton(withTitle: "確認")
        alert.addButton(withTitle: "取消")
        alert.messageText = "確定中斷遊戲？"
        alert.beginSheetModal(for: window) { [unowned self] (response) in
            if response.rawValue == 1000 {
                afterConfirm()
            } else {
                print(response.rawValue)
            }
        }
    }
    
    // 依螢幕大小改變視窗大小
    private func changeWindowSize() {
        // 外接螢幕也可以判斷螢幕解析度
        guard let screenFrame = NSScreen.main?.frame else {
            print("無法取得螢幕大小")
            return
        }
        print("螢幕大小：", screenFrame)
        DispatchQueue.main.async {
            self.view.window!.setFrame(screenFrame, display: true)
        }
    }

    // 依畫面大小排列UI
    private func setupComponents() {
        guard let screenFrame = NSScreen.main?.frame else {
            print("無法取得螢幕大小")
            return
        }
        let imageWidth = screenFrame.size.height / 3
        print("圖片長度：", imageWidth)
        selection_AButton.translatesAutoresizingMaskIntoConstraints = false
        selection_BButton.translatesAutoresizingMaskIntoConstraints = false
        selection_CButton.translatesAutoresizingMaskIntoConstraints = false
        selection_DButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selection_AButton.widthAnchor.constraint(equalToConstant: imageWidth),
            selection_AButton.heightAnchor.constraint(equalToConstant: imageWidth),
            selection_BButton.widthAnchor.constraint(equalToConstant: imageWidth),
            selection_BButton.heightAnchor.constraint(equalToConstant: imageWidth),
            selection_CButton.widthAnchor.constraint(equalToConstant: imageWidth),
            selection_CButton.heightAnchor.constraint(equalToConstant: imageWidth),
            selection_DButton.widthAnchor.constraint(equalToConstant: imageWidth),
            selection_DButton.heightAnchor.constraint(equalToConstant: imageWidth),
        ])
        let topLeftHeight: CGFloat = imageWidth / 2 - 40
        let viewTitleHeight = viewTitle.frame.size.height
        let questionHeight = questionLabel.frame.size.height
        let labelsGap = (topLeftHeight - viewTitleHeight - questionHeight) / 3
        viewTitle.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: (labelsGap > 0) ? labelsGap:0),
            questionIndexLabel.leadingAnchor.constraint(equalTo: selection_AStackView.leadingAnchor),
            questionIndexLabel.bottomAnchor.constraint(equalTo: selection_AStackView.topAnchor, constant: (labelsGap > 0) ? -labelsGap : 0),
            questionLabel.leadingAnchor.constraint(equalTo: questionIndexLabel.trailingAnchor, constant: 5),
            questionLabel.bottomAnchor.constraint(equalTo: questionIndexLabel.bottomAnchor),
        ])
    }
    
    // 回到首頁
    private func backToFrontPage() {
        let story = NSStoryboard(name: "Main", bundle: nil)
        if let frontPage = story.instantiateController(withIdentifier: "ViewController") as? ViewController {
            self.view.window?.contentViewController = frontPage
        }
    }
}
