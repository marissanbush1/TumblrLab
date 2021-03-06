//
//  PhotosViewController.swift
//  TumblrLab
//
//  Created by Marissa Bush on 11/16/17.
//  Copyright © 2017 Marissa Bush. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photosCell") as! PhotoCell
        
        let post = posts[indexPath.row]
        
        let photos = post["photos"] as? [[String: Any]]
        let photo = photos![0]
        let originalSize = photo["original_size"] as! [String: Any]
        let urlString = originalSize["url"] as! String
        let url = URL(string: urlString)
        cell.photoImageView.af_setImage(withURL: url!)
        return cell
    }
    
    
    
    
    
    var posts: [[String: Any]] = []
    
    @IBOutlet weak var photosTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosTableView.delegate = self
        photosTableView.dataSource = self
        photosTableView.rowHeight = 200
        
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(dataDictionary)
                
                // TODO: Get the posts and store in posts property
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                // TODO: Reload the table view
            }
            self.photosTableView.reloadData()

        }
        task.resume()

        // Do any additional setup after loading the view.
    }
    var isMoreDataLoading = false
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate:nil,
                                 delegateQueue:OperationQueue.main
        )
        let task = session.dataTask(with: url) { (data, response, error) in
            
            // Update flag
            self.isMoreDataLoading = false
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.photosTableView.reloadData()
        }
        task.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = photosTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - photosTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && photosTableView.isDragging) {
                
                isMoreDataLoading = true
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailViewController = segue.destination as! DetailViewController
        let cell = sender as! PhotoCell
        detailViewController.photo = cell.photoImageView.image
        
        
    }

}
