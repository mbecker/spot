import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import Kingfisher

class TableAsViewController: ASViewController<ASDisplayNode> {
    
    private var shadowImageView: UIImageView?
    
    /**
     * AsyncDisplayKit
     */
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    /**
     * Firebase
     */
    let ref         :   FIRDatabaseReference
    
    let page: Int
    let parkSection: ParkSection
    let park: Park
    var items2: [ParkItem2] = [ParkItem2]()
    weak var delegate:ParkASCellNodeDelegate?
    
    /**
     * Data
     */
    
    init(page: Int, park: Park, parkSection: ParkSection) {
        self.ref            = FIRDatabase.database().reference()
        self.page           = page
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
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.view.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
        
        self.view.backgroundColor = UIColor.white
        
        // Listen for added snapshots
        self.ref.child(self.parkSection.path).observe(.childAdded, with: { (snapshot) -> Void in
            // let item = ParkItem2(snapshot: snapshot)
            let item2 = ParkItem2(snapshot: snapshot, park: self.park)
            OperationQueue.main.addOperation({
                // self.items.insert(item, at: 0)
                self.items2.insert(item2, at: 0)
                let indexPath = IndexPath(item: 0, section: 0)
                self.tableNode.insertRows(at: [indexPath], with: .top)
                self.tableNode.reloadRows(at: [indexPath], with: .none)
            })
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
        let node = ASTextCellNode()
        let name = self.items2[indexPath.row].name
        node.text = "Page: \(self.page) - Node: \(indexPath.row) - Name: \(name)"
        node.backgroundColor = UIColor.white
        return ItemASCellNode(parkItem: self.items2[indexPath.row])
    }
}

extension TableAsViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 186), max: CGSize(width: 0, height: 186))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
        self.delegate?.didSelectPark(self.items2[indexPath.row])
    }
}
