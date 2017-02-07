import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import Kingfisher
import NVActivityIndicatorView
import EasyAnimation

class TableAsViewController: ASViewController<ASDisplayNode> {
    
    private var shadowImageView: UIImageView?
    
    /**
     * AsyncDisplayKit
     */
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    let ref         :   FIRDatabaseReference
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
    let page: Int
    let parkSection: ParkSection
    let park: Park
    let type: ItemType
    var items2: [ParkItem2] = [ParkItem2]()
    weak var delegate:ParkASCellNodeDelegate?
    
    var observerChildAdded: FIRDatabaseHandle?
    var observerChildChanged: FIRDatabaseHandle?
    let errorLabelNoItems = UILabel()
    var errorImageNoItems: UIImageView!
    var errorImageChain: EAAnimationFuture?
    
    /**
     * Data
     */
    
    init(page: Int, type: ItemType, park: Park, parkSection: ParkSection) {
        self.ref            = FIRDatabase.database().reference()
        self.page           = page
        self.type           = type
        self.park           = park
        self.parkSection    = parkSection
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    func addObserver(){
        removeObserver()
        self.toggleErrorLabelNoItems(show: false)
        // 1: .childAdded observer
        self.observerChildAdded = self.ref.child("park").child(self.park.key).child(self.parkSection.path).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
            // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
            if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, type: self.type, park: self.park), self.items2.contains(where: {$0.key == item2.key}) == false {
                if self.loadingIndicatorView.animating {
                    self.loadingIndicatorView.stopAnimating()
                }
                self.items2.insert(item2, at: 0)
                let indexPath = IndexPath(item: 0, section: 0)
                self.tableNode.insertRows(at: [indexPath], with: .none)
                self.tableNode.reloadRows(at: [indexPath], with: .none)
            }
            
        })
        
        // 2: .childChanged observer
        self.observerChildChanged = self.ref.child("park").child(self.park.key).child(self.parkSection.path).observe(.childChanged, with: { (snapshot) -> Void in
            // ParkItem2 is updated; replace item in table array
            if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject] {
                for i in 0...self.items2.count-1 {
                    if let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, type: self.type, park: self.park), self.items2[i].key == item2.key {
                        self.items2[i]  = item2
                        let indexPath = IndexPath(item: i, section: 0)
                        self.tableNode.reloadRows(at: [indexPath], with: .fade)
                    }
                }
            }
            
        })
        
        
    }
    
    func toggleErrorLabelNoItems(show: Bool) {
        if show {
            self.loadingIndicatorView.stopAnimating()
            self.view.addSubview(self.errorLabelNoItems)
            self.view.addSubview(self.errorImageNoItems)
            
            self.errorImageChain = UIView.animateAndChain(withDuration: 1.0, delay: 0.0, options: [], animations: {
                self.errorImageNoItems.frame.origin.x = self.view.center.x - 15
            }, completion: nil).animate(withDuration: 2.0, animations: {
                let degrees = 180.0
                let radians = CGFloat(degrees * Double.pi / 180)
                self.errorImageNoItems.layer.transform = CATransform3DConcat(CATransform3DMakeScale(1.4, 1.4, 1.0), CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0))
            }).animate(withDuration: 2.0, animations: {
                // self.errorImageNoItems.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
                let degrees = 360.0
                let radians = CGFloat(degrees * Double.pi / 180)
                self.errorImageNoItems.layer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
            }).animate(withDuration: 1.0, animations: {
                self.errorImageNoItems.frame.origin.x = self.view.bounds.width - 20 - 30
            }).animate(withDuration: 0.0, delay: 0.0, options: [.repeat], animations: {
                self.errorImageNoItems.frame.origin.x = 20
            }, completion: nil)
            
            
            
            
            removeObserver()
        } else {
            self.errorLabelNoItems.removeFromSuperview()
            self.errorImageNoItems.removeFromSuperview()
            self.loadingIndicatorView.startAnimating()
        }
        
    }
    
    func removeObserver(){
        if self.observerChildAdded != nil {
            self.ref.removeObserver(withHandle: self.observerChildAdded!)
        }
        if self.observerChildAdded != nil {
            self.ref.removeObserver(withHandle: self.observerChildChanged!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TableView
        self.view.backgroundColor = UIColor.white
        self.tableNode.view.showsVerticalScrollIndicator    = true
        self.tableNode.allowsSelection                      = true
        self.tableNode.view.backgroundColor                 = UIColor.white
        self.tableNode.view.separatorColor                  = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00) // Bonjour
        
        
        // Loading indicator
        self.loadingIndicatorView.frame = CGRect(x: self.view.bounds.width / 2 - 22, y: UIScreen.main.bounds.height / 2 - 22, width: 44, height: 44)
        self.loadingIndicatorView.startAnimating()
        self.view.addSubview(self.loadingIndicatorView)
        
        // Error label
        self.errorLabelNoItems.frame = self.tableNode.view.frame
        self.errorLabelNoItems.text = "No items uploaded ..."
        self.errorLabelNoItems.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
        self.errorLabelNoItems.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.00)
        self.errorLabelNoItems.textAlignment = .center
        
        self.errorImageNoItems = UIImageView(frame: CGRect(x: 20, y: self.view.bounds.height / 2 + 22, width: 30, height: 30))
        self.errorImageNoItems.image = UIImage(named:"Turtle-66")
        
        /**
         * Firebase:
         * 1. Count the items in DB
         * 2. Only attach observer if items.count > 0
         * (only attach once an observer)
         */
        self.ref.child("park").child(self.park.key).child(self.parkSection.path).child("count").observe(.value, with: { (snapshot) -> Void in
            if snapshot.exists(), let count: Int = snapshot.value as? Int, count > 0 {
                self.addObserver()
            } else {
                self.toggleErrorLabelNoItems(show: true)
            }
        })
        self.ref.child("park").child(self.park.key).child(self.parkSection.path).child("count").observe(.childChanged, with: { (snapshot) -> Void in
            if let count: Int = snapshot.value as? Int, count > 0 {
                self.addObserver()
            } else {
                self.toggleErrorLabelNoItems(show: true)
            }
        })
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if self.observerChildAdded == nil {
            toggleErrorLabelNoItems(show: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.errorImageChain?.cancelAnimationChain()
        self.errorImageNoItems.removeFromSuperview()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension TableAsViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.items2.count
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0000000000001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0000000000001
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let node = ListItemASCellNode(parkItem: self.items2[indexPath.row])
        node.selectionStyle = .blue
        // self.items2[indexPath.row].latitude)
        // self.items2[indexPath.row].longitude
        return node
    }
}

extension TableAsViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 80), max: CGSize(width: 0, height: 80))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
        self.delegate?.didSelectPark(self.items2[indexPath.row])
    }
}
