import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var taskBar: TaskBar!
    
    var homePageViewController: HomePageViewController? {
        didSet {
            homePageViewController?.homeDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = String.appTitle
        taskBar.delegate = self

        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homePageViewController = segue.destination as? HomePageViewController {
            self.homePageViewController = homePageViewController
            self.homePageViewController?.homeNavItem = navigationItem
        }
    }
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
    }
}

extension HomeViewController: HomePageViewControllerDelegate {
    func homePageViewController(homePageViewController: HomeViewController, didUpdatePageCount count: Int) {
        //
    }
    
    func homePageViewController(homePageViewController: HomeViewController, didUpdatePageIndex index: Int) {
        //
    }
}

extension HomeViewController: TaskbarDelegate {
    func taskSelected(task: TaskTypes) {
        homePageViewController?.scrollToViewController(index: UIUtils.getIndexFromTask(task: task))
    }
}
