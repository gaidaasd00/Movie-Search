//
//  ViewController.swift
//  Movie Search
//
//  Created by Alexey Gaidykov on 19.12.2022.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBOutlet
    @IBOutlet var table: UITableView!
    @IBOutlet var textField: UITextField!
    
    //array
    var movies = [Movie]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //register
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.id)
        
        table.delegate = self
        table.dataSource = self
        textField.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        return true
    }
    //settings fields
    func searchMovies() {
        textField.resignFirstResponder()
        
        guard let textField = textField.text, !textField.isEmpty else  { return }
        
        let query = textField.replacingOccurrences(of: " ", with: "%20")
        
        movies.removeAll()
        
        URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=3aea79ac&s=\(query)&type=movie")!,
                                   completionHandler: { data, response, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            // Convert
            var result: MovieResult?
            do {
                result = try JSONDecoder().decode(MovieResult.self, from: data)
            }
            catch {
                print("error")
            }
            
            guard let finalResult = result else {
                return
            }
            // Update our movies array
            let newMovies = finalResult.Search
            self.movies.append(contentsOf: newMovies)
            
            // Refresh our table
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            
        }).resume()
    }
    
    //settings table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.id, for: indexPath) as! MovieTableViewCell
        cell.configure(white: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //movie details
    
}

