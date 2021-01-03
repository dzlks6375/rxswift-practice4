//
//  ViewController.swift
//  rxswift-practice4
//
//  Created by SIU on 2021/01/03.
//

import RxSwift
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> { // 나중에생기는데이터: Observable<T>
    
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) { // 나중에오면: subscribe
        task(f)
    }
    
}

class ViewController: UIViewController {
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    // Observerble의 생명주기
    // 1. Create
    // 2. Subscribe
    // 3. onNext
    // 4. onCompleted / onError
    // 5. Disposed
    
    func downloadJson(url: String) -> 나중에생기는데이터<String?> { // 나중에생기는데이터: Observable
        
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
    
        return 나중에생기는데이터() { f in // 나중에생기는데이터: Observable.create

            DispatchQueue.global().async {

                let url = URL(string: url)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)

                DispatchQueue.main.async {
                    f(json) // f.onNext(json)
                    // f.onComplete() // 끝나서 해제된다.(순환참조 문제 해결)
                }

            }

            // return Disposable.create()
        }
    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // 2. Observable로 오는 데이터를 받아서처리하는 방법
        
        downloadJson(url: MEMBER_LIST_URL)
//            .debug()
            .나중에오면 { json in // 나중에오면:subscribe , * Promise,Bolt에서는 then, subscribe하면 event(.next, .completed, .error)가 온다, .completed나 .error가 실행되면 클로져가 해제된다(Reference Count감소)
            
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)

        }
    }
}


