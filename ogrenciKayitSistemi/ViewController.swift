//
//  ViewController.swift
//  ogrenciKayitSistemi
//
//  Created by Recep Akkoyun on 9.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    var ogrAdiList = [String]()
    var ogrSoyadiList = [String]()
    var ogrIdList = [UUID]()
    
    var secilenIsim = ""
    var secilenUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        getData()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:.add, target: self, action: #selector(artiBasildiginda))
    }
    //Öbür ekrana geri dönmesi için 
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ogrAdiList.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = ogrAdiList[indexPath.row] + " " + ogrSoyadiList[indexPath.row]
        return cell
    }
    
    @objc func artiBasildiginda(){
        secilenIsim = ""
        performSegue(withIdentifier: "toDetails", sender: nil)
        
    }
    // Details sayfasında kaydedilen verileri şimdi bu sayfaya çekicez
    @objc func getData(){
        //Aynı verileri tekrardan yazdırmaması için
        ogrAdiList.removeAll(keepingCapacity: false)
        ogrIdList.removeAll(keepingCapacity: false)
        ogrSoyadiList.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Ogrenci adlı datadaki verileri request ile istiyorum
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ogrenciler") //NSFatchRequestResult u en son ekliyoruz.
        fetchRequest.returnsDistinctResults = false // bu işlem Büyük dataları daha hızlı okumasını sağlar.
        
        do{
            let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject]{
                    
                    if let name = sonuc.value(forKey: "ogrAdi") as? String{
                        ogrAdiList.append(name)
                    }
                    if let surname = sonuc.value(forKey: "ogrSoyadi") as? String{
                        ogrSoyadiList.append(surname)
                    }
                    
                    if let id = sonuc.value(forKey: "ogrId") as? UUID{
                        ogrIdList.append(id)
                    }
            }
            
            
                
                
            }
            tableView.reloadData()
            }catch
            {
                print("Hata")
            }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails"{
            let destinationCV = segue.destination as! ogrenciDetails
            destinationCV.secilenOgrId = secilenUUID
            destinationCV.secilenOgrAdi = secilenIsim
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenIsim = ogrAdiList[indexPath.row]
        secilenUUID = ogrIdList[indexPath.row]
        performSegue(withIdentifier: "toDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete{
             
             let appDelegate = UIApplication.shared.delegate as! AppDelegate
             let context = appDelegate.persistentContainer.viewContext
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ogrenciler") //NSFatchRequestResult u en son ekliyoruz.
             let ogrIdString = ogrIdList[indexPath.row].uuidString
             fetchRequest.predicate = NSPredicate(format: "ogrId = %@", ogrIdString)
             fetchRequest.returnsObjectsAsFaults = false
             
             do {
                 let sonuclar = try context.fetch(fetchRequest)
                 
                 if sonuclar.count > 0{
                     
                     for sonuc in sonuclar as! [NSManagedObject] {
                         if let id = sonuc.value(forKey: "ogrId") as? UUID {
                             if id == ogrIdList[indexPath.row]{
                                 context.delete(sonuc)
                                 ogrIdList.remove(at: indexPath.row)
                                 ogrAdiList.remove(at: indexPath.row)
                                 ogrSoyadiList.remove(at: indexPath.row)
                                 
                                 self .tableView.reloadData()
                                 
                                 do{
                                     try context.save()
                                 }catch {
                                     print("Hata")
                                 }
                                 break
                                 
                             }
                         }
                         
                     }
                 }
             }catch{
                 print("Hata")
             }
         }
     }

}

