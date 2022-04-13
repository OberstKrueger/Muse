import MediaPlayer

extension MPMediaPlaylist {
    var nameComponents: (category: String, name: String)? {
        if let title = self.name {
            let elements = title.components(separatedBy: " - ")

            if elements.count == 2 {
                return (elements[0], elements[1])
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
