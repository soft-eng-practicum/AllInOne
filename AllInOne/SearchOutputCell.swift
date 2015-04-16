


import UIKit

class SearchOutputCell: UITableViewCell {
    
    
    var downloadTask: NSURLSessionDownloadTask?
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zeroRect)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        
        nameLabel.text = nil
        artistNameLabel.text = nil
        artworkImageView.image = nil
        
        println("prepare for reuse!")
    }
    
    
    func configureForSearchOutput(searchOutput: SearchOutput) {
        nameLabel.text = searchOutput.name
        
        if searchOutput.artistName.isEmpty {
            artistNameLabel.text = "No idea"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", searchOutput.artistName, searchOutput.kindForDisplay())
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let url = NSURL(string: searchOutput.artworkURL60) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    
    
    
}
