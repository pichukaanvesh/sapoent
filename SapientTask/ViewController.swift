//
//  ViewController.swift
//  SapientTask
//
//  Created by Anvesh P on 10/05/19.
//  Copyright © 2019 visionetSystems. All rights reserved.
//

import UIKit
import Firebase



class ViewController: UIViewController {
   
    @IBOutlet weak var mainCV: UICollectionView!
    var carmodel = [carmodel1]()
    var ref: DatabaseReference!
    
        override func viewDidLoad() {
        super.viewDidLoad()
            self.handlepagination()
//            self.getdatafromfirebase()
        
        mainCV.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
        // Do any additional setup after loading the view, typically from a nib.
    }
    func getdatafromfirebase(){
        ref = Database.database().reference().child("result")
        
        ref.observe(DataEventType.value
            , with: {(snapshot) in
                
                if snapshot.childrenCount > 0 {
                    self.carmodel.removeAll()
                    for cars in snapshot.children.allObjects as![DataSnapshot]{
                        let carmodelobject = cars.value as? [String : String]
                        guard let modelname = carmodelobject?["name"] else {
                            return
                        }
                        guard let imageurl = carmodelobject?["imageurl"] else {
                            return
                        }
                        let carmodel = carmodel1(name: modelname, imageurl: imageurl)
                        self.carmodel.append(carmodel)
                        
                    }
                    self.mainCV.reloadData()
                }
                
        })
    }
    var startkey : String?
   
    func handlepagination(){
          let ref = Database.database().reference(withPath: "result").queryOrderedByKey()
        if startkey == nil {
        ref.queryLimited(toFirst: 8).observeSingleEvent(of: .value) { (snapshot) in
            guard let children = snapshot.children.allObjects.last as? DataSnapshot else{return}
            if snapshot.childrenCount > 0 {
                for child in snapshot.children.allObjects as! [DataSnapshot]{
                    print(child.key)
                    guard let dictionary = child.value as? NSDictionary else{return}
                   let name = dictionary.value(forKey: "name") as! String
                    let image = dictionary.value(forKey: "imageurl") as! String
                   let carmodel = carmodel1(name: name, imageurl: image)
                    self.carmodel.append(carmodel)
                    
                }
                self.mainCV.reloadData()
                
            }
        }
        }
        else{
            ref.queryStarting(atValue: self.startkey).queryLimited(toFirst: 4).observeSingleEvent(of: .value) { (snapshot) in
                guard let children = snapshot.children.allObjects.last as? DataSnapshot else {return}
                
                if snapshot.childrenCount > 0{
                    for child in snapshot.children.allObjects as! [DataSnapshot]
                    {
                        print(child.key)
                        if child.key != self.startkey
                        {
                            guard let dictionary = child.value as? NSDictionary else{return}
                            let name = dictionary.value(forKey: "name") as! String
                            let image = dictionary.value(forKey: "imageurl") as! String
                            let carmodel = carmodel1(name: name, imageurl: image)
                            self.carmodel.append(carmodel)
                        }
                        self.startkey = child.key
                        self.mainCV.reloadData()
                    }
                }
            }
    
    }
}
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentoffset = scrollView.contentOffset.y
        let maxoffset = scrollView.contentSize.height - scrollView.frame.height
        if maxoffset - currentoffset <= 40{
            self.handlepagination()
        }
    }
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carmodel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MainCVCell
       cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        DispatchQueue.global(qos: .background).async {
            let imageUrl =  self.carmodel[indexPath.row].imageurl
            let encodedString = imageUrl!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            let url = URL(string: encodedString ?? " ")
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                if let data1 = data{
                    cell.mainImageView.image = UIImage(data: data1)
                }
            }
        }

            cell.mainLabel.text = carmodel[indexPath.row].name
   
        return cell
    }
    
    
    
}
//yourCollectionView.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
//For cell use below code:
//
//cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
