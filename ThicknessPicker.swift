import SpriteKit

/// A custom picker used to select the thickness of the brush in the drawing toolbar.
public class ThicknessPicker: SideBarPlaceable {
    var width = 400
    var height = 60
    var elementSize = 40
    
    /// An event handler that’s called when selecting a thickness.
    public var onSelectedValue: ((Int) -> Void) = { _ in }
    
    /// The toolbar icon for the thickness picker.
    public var icon = Graphic.line(length: 40, thickness: 15, color: .black)
    
    /// Removes all graphics associated with the thickness picker.
    public func dismiss() {
        scene.removeGraphics(named: "ThicknessPicker")
    }
    
    public init() {
        icon.rotation = 90
    }
    
    /// Draws and sets up the thickness picker.
    public func draw(at point: Point) {
        let rect = Graphic.rectangle(width: width + 20, height: height + 10, cornerRadius: 20, color: #colorLiteral(red: 0.9214347004890442, green: 0.9214347004890442, blue: 0.9214347004890442, alpha: 1.0))
        rect.name = "ThicknessPicker"
        scene.place(rect, at: point, anchoredTo: .left)
        
        let columns = width / elementSize
        let columnDistance = Double(width) / Double(columns)
        var currentPosition = Point(x: point.x + 25, y: point.y)
        
        for i in 1...columns {
            var thickness = Double(i) * 3
            let line = Graphic.line(length: 40, thickness: Int(thickness), color: .black)
            let overlayCircle = Graphic.circle(radius: 20, color: .clear)
            overlayCircle.name = "ThicknessPicker"
            line.name = "ThicknessPicker"
            line.rotation = 90
            scene.place(line, at: currentPosition)
            scene.place(overlayCircle, at: currentPosition)
            
            overlayCircle.setOnTouchHandler { [self] _ in
                line.run(SKAction.scale(to: 1.5, duration: 0.2)) {
                    onSelectedValue(Int(thickness))
                    dismiss()
                }
            }
            
            currentPosition.x += columnDistance
        }
        
    }
}
