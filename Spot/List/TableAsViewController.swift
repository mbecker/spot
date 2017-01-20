import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import Kingfisher
import NVActivityIndicatorView

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
        
        // Listen for added snapshots
        self.ref.child(self.parkSection.path).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
            // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
            if let item2 = ParkItem2(snapshot: snapshot, type: self.type, park: self.park), self.items2.contains(where: {$0.key == item2.key}) == false {
                OperationQueue.main.addOperation({
                    self.items2.insert(item2, at: 0)
                    self.loadingIndicatorView.removeFromSuperview()
                    let indexPath = IndexPath(item: 0, section: 0)
                    self.tableNode.insertRows(at: [indexPath], with: .none)
                    self.tableNode.reloadRows(at: [indexPath], with: .none)
                })
            }
            
        })
        // Update changed ParkItem2
        self.ref.child(self.parkSection.path).observe(.childChanged, with: { (snapshot) -> Void in
            // ParkItem2 is updated; replace item in table array
            for i in 0...self.items2.count-1 {
                if self.items2[i].key == snapshot.key, let item = ParkItem2(snapshot: snapshot, type: self.type, park: self.park) {
                    self.items2[i]  = item
                    let indexPath = IndexPath(item: i, section: 0)
                    self.tableNode.reloadRows(at: [indexPath], with: .fade)
                }
            }
            
        })

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
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
