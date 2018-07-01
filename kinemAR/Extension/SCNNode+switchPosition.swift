import ARKit

enum Position {
    case top
    case bottom
    case left
    case right
}

extension SCNNode {
    func switchPosition(to position: Position, imageAnchor: ARImageAnchor, plus gap: Float = 0) {
        let (min, max) = self.boundingBox
        let halfHeight = abs(max.z - min.z) * self.scale.z / 2
        let halfWidth = abs(max.x - min.x) * self.scale.x / 2
        
        switch position {
        case .top:
            self.position.z = -Float(imageAnchor.referenceImage.physicalSize.height / 2) - halfHeight - gap
        case .bottom:
            self.position.z = +Float(imageAnchor.referenceImage.physicalSize.height / 2) + halfHeight + gap
        case .left:
            self.position.x = -Float(imageAnchor.referenceImage.physicalSize.width / 2) - halfWidth - gap
        case .right:
            self.position.x = +Float(imageAnchor.referenceImage.physicalSize.width / 2) + halfWidth + gap
        }
    }
}
