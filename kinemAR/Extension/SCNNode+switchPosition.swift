import ARKit

enum Position {
    case top
    case bottom
    case left
    case right
    case topLeft
    case bottomLeft
    case topRight
    case bottomRight
    case insideBottomRight
}

enum Side {
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
        case .topLeft:
            self.position.z = -Float(imageAnchor.referenceImage.physicalSize.height / 4) - gap
            self.position.x = -Float(imageAnchor.referenceImage.physicalSize.width / 2) - halfWidth - gap
        case .bottomLeft:
            self.position.z = +Float(imageAnchor.referenceImage.physicalSize.height / 4) + gap
            self.position.x = -Float(imageAnchor.referenceImage.physicalSize.width / 2) - halfWidth - gap
        case .topRight:
            self.position.z = -Float(imageAnchor.referenceImage.physicalSize.height / 4) - gap
            self.position.x = +Float(imageAnchor.referenceImage.physicalSize.width / 2) + halfWidth + gap
        case .bottomRight:
            self.position.z = +Float(imageAnchor.referenceImage.physicalSize.height / 4) + gap
            self.position.x = +Float(imageAnchor.referenceImage.physicalSize.width / 2) + halfWidth + gap
        case .insideBottomRight:
            self.position.z = +Float(imageAnchor.referenceImage.physicalSize.height / 2) - halfWidth + gap
            self.position.x = +Float(imageAnchor.referenceImage.physicalSize.width / 2) - halfWidth + gap
        }
    }
    
    func switchPosition(to position: Side, nodeReference node: SCNNode, plus gap: Float = 0) {
        let (selfMin, selfMax) = self.boundingBox
        let halfWidth = abs(selfMax.x - selfMin.x) * self.scale.x / 2
        
        let (nodeMin, nodeMax) = node.boundingBox
        let nodeHalfWidth = abs(nodeMax.x - nodeMin.x) * node.scale.x / 2
        
        switch position {
        case .left:
            self.position.z = node.position.z
            self.position.x = node.position.x - nodeHalfWidth - halfWidth - gap
        case .right:
            self.position.z = node.position.z
            self.position.x = node.position.x + nodeHalfWidth + halfWidth + gap
        }
    }
}
