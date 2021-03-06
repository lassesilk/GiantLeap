//
//  ViewController.swift
//  GiantLeap
//
//  Created by Lasse Silkoset on 19.06.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    
    private var itemArray = [ItemObject]() {
        didSet {
            searchTableView.reloadData()
            if itemArray.isEmpty == false {
                searchTableView.separatorStyle = .singleLine
            } else {
                searchTableView.separatorStyle = .none
            }
        }
    }
    //Computed var so fetching happens "as we go"
    private var SearchTextFromBar: String? {
        didSet {
            fetchItems()
        }
    }
    //private vars for loading more results with scroll
    private var page = 0
    private var size = 10
    //Making a private var for usecase prepare for segue
    private var cellForIndex: IndexPath?
    
    
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Search"
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isUserInteractionEnabled = true
        searchTableView.separatorStyle = .none
        searchBarOutlet.delegate = self
        
        
    }
    
    
    
    //PRAGMA MARK: - Tableview Funcs ********************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! SearchTableViewCell
        
        cell.nameLabel.text = itemArray[indexPath.row].name
        if let orgnr = itemArray[indexPath.row].org {
            cell.orgLabel.text = String(orgnr)
        }
        if let companyAddress = itemArray[indexPath.row].adresse {
            cell.adressLabel.text = companyAddress
        } else {
            cell.adressLabel.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellForIndex = indexPath
        performSegue(withIdentifier: "infoSegue", sender: self)
    }
    
    
    //PRAGMA MARK: - ScrollView Funcs ********************************************************
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBarOutlet.resignFirstResponder()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView == searchTableView {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                size += 10
                fetchItems()
            }
        }
    }
    
    //PRAGMA MARK: - SearchBar Funcs ********************************************************
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //if new searches, pages and size needs to be reset to starting point
        page = 0
        size = 10
        
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 1 {
            itemArray.removeAll()
            //Disabled scroll so it will not fetch more with increased size if scrolled.
            searchTableView.isScrollEnabled = false
        } else {
            searchTableView.isScrollEnabled = true
        }
        
        switch segmentedControlOutlet.selectedSegmentIndex {
        case 0:
            
            //API only supports 9 digits results on "organisasjonsnummer"
            if searchText.count > 8 {
                SearchTextFromBar = searchText
            }
        case 1, 2:
            //API filtering supports search for more than 1 char
            if searchText.count > 1 {
                let aString = searchText
                let newString = aString.replacingOccurrences(of: " ", with: "+")
                SearchTextFromBar = newString
            }
        default:
            break
        }
    }
    
    
    
    //PRAGMA MARK: - Networking Funcs ********************************************************
    
    enum Result<ItemObject> {
        case Success(ItemObject)
        case Error(String)
    }
    
    private func fetchItemsByOrg(searchName: String?, completion: @escaping (Result<[ItemObject]>) -> Void) {
        
        var tempItemArray = [ItemObject]()
        
        
            if let orgnr = searchName {
                let finalURL = "http://data.brreg.no/enhetsregisteret/enhet/\(orgnr).json"
                
                guard let itemUrl = URL(string: finalURL) else { return }
                
                let request = URLRequest(url: itemUrl, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
                
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    
                    
                    if error != nil {
                        print(error!.localizedDescription)
                        completion(.Error("Unable to retrieve data from URL"))
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        //OrgJson struct, because result has different nesting than the others
                        let item = try JSONDecoder().decode(OrgJson.self, from: data)
                       
                        tempItemArray.append(ItemObject(name: item.navn, org: item.organisasjonsnummer, adresse: item.forretningsadresse?.adresse, naering: item.naeringskode1?.beskrivelse, postnr: item.forretningsadresse?.postnummer, poststed: item.forretningsadresse?.poststed, hjemmeside: item.hjemmeside))
                        
                        DispatchQueue.main.async {
                            self.itemArray.removeAll()
                            completion(.Success(tempItemArray))
                        }
                    } catch let jsonError {
                        print(jsonError)
                    }
                }.resume()
            }
        
    }
    
    private func fetchItemsByName(searchName: String?, completion: @escaping (Result<[ItemObject]>) -> Void) {
        
        var tempItemArray = [ItemObject]()
        let tempStr = size
        let tempPage = page
        
        if let filter = searchName {
            let finalURL = "http://data.brreg.no/enhetsregisteret/enhet.json?page=\(tempPage)&size=\(tempStr)&$filter=startswith(navn,'\(filter)')"
            
            guard let itemUrl = URL(string: finalURL) else { return }
            
            let request = URLRequest(url: itemUrl, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                
                if error != nil {
                    print(error!.localizedDescription)
                    completion(.Error("Unable to retrieve data from URL"))
                }
                
                guard let data = data else { return }
                
                do {
                    let items = try JSONDecoder().decode(NameJson.self, from: data)
                    for item in items.data{
                        tempItemArray.append(ItemObject(name: item.navn, org: item.organisasjonsnummer, adresse: item.forretningsadresse?.adresse, naering: item.naeringskode1?.beskrivelse, postnr: item.forretningsadresse?.postnummer, poststed: item.forretningsadresse?.poststed, hjemmeside: item.hjemmeside))
                    }
                    
                    DispatchQueue.main.async {
                        self.itemArray.removeAll()
                        completion(.Success(tempItemArray))
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()
        }
    }
    
    private func fetchItemsByAdress(searchName: String?, completion: @escaping (Result<[ItemObject]>) -> Void) {
        
        var tempItemArray = [ItemObject]()
        let tempStr = size
        let tempPage = page
        
        
        if let address = searchName {
            let finalURL = "http://data.brreg.no/enhetsregisteret/enhet.json?page=\(tempPage)&size=\(tempStr)&$filter=startswith(forretningsadresse/adresse,'\(address)')"
            
            guard let itemUrl = URL(string: finalURL) else { return }
            
            let request = URLRequest(url: itemUrl, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    completion(.Error("Unable to retrieve data from URL"))
                }
                
                guard let data = data else { return }
                
                do {
                    let items = try JSONDecoder().decode(NameJson.self, from: data)
                    for item in items.data{
                        tempItemArray.append(ItemObject(name: item.navn, org: item.organisasjonsnummer, adresse: item.forretningsadresse?.adresse, naering: item.naeringskode1?.beskrivelse, postnr: item.forretningsadresse?.postnummer, poststed: item.forretningsadresse?.poststed, hjemmeside: item.hjemmeside))
                    }
                    
                    DispatchQueue.main.async {
                        self.itemArray.removeAll()
                        completion(.Success(tempItemArray))
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()
        }
    }
    
    
    //PRAGMA MARK: - Helper Funcs ********************************************************
    
    private func fetchItems() {
        switch segmentedControlOutlet.selectedSegmentIndex {
        case 0:
            fetchItemsByOrg(searchName: SearchTextFromBar, completion: { (result) in
                self.handlingResult(result: result)
            })
        case 1:
            fetchItemsByName(searchName: SearchTextFromBar, completion: { (result) in
                self.handlingResult(result: result)
            })
        case 2:
            fetchItemsByAdress(searchName: SearchTextFromBar, completion: { (result) in
                self.handlingResult(result: result)
            })
        default:
            break
        }
    }
    
    private func handlingResult(result: Result<[ItemObject]>) {
        switch result {
        case .Success(let item):
            self.itemArray = item
        case .Error(let error):
            print(error)
            DispatchQueue.main.async {
                self.presentAlert(error: error)
            }
            
        }
    }
    
    func presentAlert(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            if let index = cellForIndex {
                let _ = searchTableView.cellForRow(at: index)
                let destinationVC = segue.destination as? InfoViewController
                print("kom hit i prepare")
                destinationVC?.infoArray.append(itemArray[index.row])
                
            }
        }
    }
    
}

