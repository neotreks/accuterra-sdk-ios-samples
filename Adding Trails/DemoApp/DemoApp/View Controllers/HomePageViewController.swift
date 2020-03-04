//
//  HomeViewController.swift
//  DemoApp
//
//  Created by Brian Elliott on 2/20/20.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import UIKit
import AccuTerraSDK

class HomePageViewController: UIPageViewController {

    weak var homeDelegate: HomePageViewControllerDelegate?
    weak var homeNavItem: UINavigationItem?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.newViewController("Community"),
            self.newViewController("Activities"),
            self.newViewController("Discover"),
            self.newViewController("Profile")
            ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        // Checking if DB is initialized is here just for the DEMO purpose.
        // You should not check this in real APK but call the `SdkManager.configureSdkAsync`
        // and monitor the progress and result. The TRAIL DB will be downloaded automatically
        // during the SDK initialization.
        if !SdkManager.shared.isTrailDbInitialized {
            // Init the SDK. Since DB was not downloaded yet, it will be downloaded
            // during SDK initialization.
            self.goToDownload()
        } else {
            // Init the SDK. Since DB was downloaded already there will be no download now.
            self.initSdk()
        }
        
        self.isPagingEnabled = false
    }
    
    private func initSdk() {
        guard let clientToken = Bundle.main.infoDictionary?["AccuTerraClientToken"] as? String,
            let serviceUrl = Bundle.main.infoDictionary?["AccuTerraServiceUrl"] as? String else {
                fatalError("AccuTerraClientToken and AccuTerraServiceUrl is missing in info.plist")
        }
        SdkManager.shared.initSdkAsync(config: SdkConfig(clientToken: clientToken, wsUrl: serviceUrl), delegate: self)
    }
    
    private func goToDownload() {
        let taskBar = (homeDelegate as? HomeViewController)?.taskBar
        if let downloadViewController = self.newViewController("Download") as? DownloadViewController {
            downloadViewController.delegate = self
            taskBar?.isUserInteractionEnabled = false
            self.scrollToViewController(viewController: downloadViewController)
        }
    }
    
    func goToTrailsDiscovery() {
        EnumUtil.cacheEnums()
        let initialViewController = orderedViewControllers[UIUtils.getIndexFromTask(task: .discover)]
        scrollToViewController(viewController: initialViewController)
    }

    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
                let nextViewController = orderedViewControllers[newIndex]
                scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        (homeDelegate as? HomeViewController)?.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func newViewController(_ name: String) -> UIViewController {
        if let vc = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: name) as? BaseViewController {
            vc.homeNavItem = self.homeNavItem
            return vc
        }
        return UIStoryboard(name: "Main", bundle: nil) .
        instantiateViewController(withIdentifier: name)
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
            direction: direction,
            animated: true,
            completion: { (finished) -> Void in
                // Setting the view controller programmatically does not fire
                // any delegate methods, so we have to manually notify the
                // 'tutorialDelegate' of the new index.
                self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifyTutorialDelegateOfNewIndex() {
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    private func displaySdkInitError(_ error: Error?) {
        let alert = UIAlertController(title: "Error", message: "AccuTerra SDK initialization has failed because of:|\n\(String(describing: error))|\nDo not use the SDK in case of initialization failure!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
}

extension HomePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
                return orderedViewControllers.last
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                return orderedViewControllers.first
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
}

extension HomePageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

protocol HomePageViewControllerDelegate: class {
    
    /**
     The number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func homePageViewController(homePageViewController: HomeViewController,
        didUpdatePageCount count: Int)
    
    /**
     The current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func homePageViewController(homePageViewController: HomeViewController,
        didUpdatePageIndex index: Int)
    
}


extension HomePageViewController : SdkInitDelegate, DownloadViewControllerDelegate {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool) {
        self.present(viewControllerToPresent, animated: flag, completion: nil)
    }
    
    func onProgressChanged(progress: Int) {
        // no action needed here
    }
    
    func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
        DispatchQueue.main.sync {
            let taskBar = (self.homeDelegate as? HomeViewController)?.taskBar
            switch state {
            case .COMPLETED:
                taskBar?.isUserInteractionEnabled = true
                self.goToTrailsDiscovery()
            case .FAILED(let error):
                taskBar?.isUserInteractionEnabled = true
                self.displaySdkInitError(error)
            case .IN_PROGRESS:
                taskBar?.isUserInteractionEnabled = false
            default:
                // no action needed here
                break
            }
        }
    }
}
