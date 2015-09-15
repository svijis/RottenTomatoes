//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Vijayalakshmi Subramanian on 9/13/15.
//  Copyright © 2015 Viji Subramanian. All rights reserved.
//

import UIKit

private let CELL_NAME = "com.codepath.rottentomatoes.moviecell"

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var movieTableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var movies:NSArray?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        //cell.textLabel?.text = "Row \(indexPath.row)"
        
        let movieDictionary = movies![indexPath.row] as! NSDictionary
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_NAME) as! MovieCell
        cell.movieTitleLabel.text = (movieDictionary["title"] as! String)
        cell.movieDescriptionLabel.text = (movieDictionary["synopsis"] as! String)
        
        let url = NSURL(string: movieDictionary.valueForKeyPath("posters.thumbnail") as! String)!
        cell.postersView.setImageWithURL(url)
    
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=US")!
    
        let request = NSMutableURLRequest(URL: url);
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) -> Void in
            if let dictionary = try!NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSDictionary {
            
                // jump back to main thread and execute code
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.movies = (dictionary["movies"] as! NSArray)
                    self.movieTableView.reloadData()
                }
            }else {
                
            }
        }
        task.resume()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = movieTableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row] as! NSDictionary
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        movieTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        //delay(2, closure: {
          //  self.refreshControl.endRefreshing()
        //})
        self.movieTableView.reloadData()
        self.refreshControl.endRefreshing()
        
    }

    
    
    
}
class MovieCell:UITableViewCell {
    
    @IBOutlet weak var postersView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
}

