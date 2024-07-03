//
//  ViewController.swift
//  ArtBook
//
//  Created by Mert Erciyes Çağan on 5/30/24.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   

    @IBOutlet weak var tableView: UITableView!
    var paintingsNameArray = [String]()
    var paintingsIdArray = [UUID]()
    var tappedPainting = ""
    var tappedPaintingId: UUID?
    
    override func viewDidLoad() {
        getData()

        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewPainting))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
    @objc func addNewPainting(){
        tappedPainting = ""
        performSegue(withIdentifier: "detailsSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = paintingsNameArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paintingsNameArray.count
    }
    
    @objc func getData(){
        paintingsNameArray.removeAll()
        paintingsIdArray.removeAll()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
    
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetchResponse = try context?.fetch(fetchRequest)
            if fetchResponse!.count > 0 {
                for response in fetchResponse as! [NSManagedObject] {
                    if let name = response.value(forKey: "name") as? String {
                        paintingsNameArray.append(name)
                    }
                    
                    if let id = response.value(forKey: "id") as? UUID {
                        paintingsIdArray.append(id)
                    }
                    self.tableView.reloadData()
                    
                }
            }
            
        } catch {
            print ("fetching error")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let destination = segue.destination as? DetailsViewController
            destination?.tappedPainting = tappedPainting
            destination?.tappedPaintingId = tappedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tappedPainting = paintingsNameArray[indexPath.row]
        tappedPaintingId = paintingsIdArray[indexPath.row]
        performSegue(withIdentifier: "detailsSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = paintingsIdArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try! context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == paintingsIdArray[indexPath.row] {
                                context.delete(result)
                                paintingsNameArray.remove(at: indexPath.row)
                                paintingsIdArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    print("error")
                                }
                                
                                break
                            }
                        }
                    }
                    
                }
            } catch {
                print("error")
            }
        }
    }
    


}

