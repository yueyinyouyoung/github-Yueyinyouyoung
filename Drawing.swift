import Foundation
import CoreGraphics
import UIKit

var defaultDrawingColor = UIColor(named: "drawing_default_color") ?? .black

/// Requirements for placing a graphic in the drawing toolbar.
public protocol SideBarPlaceable {
    var icon: Graphic { get set }
}

/// Requirements for a brush.
public protocol Brush: SideBarPlaceable {
    var thickness: Int { get set }
    var color: Color { get set }
    var handleTouch: ((Touch) -> Void) { get set }
}

/// Draws a series of circles to create free-form lines.
public class Pen: Brush, SideBarPlaceable {
    public var icon: Graphic = Graphic(image: #imageLiteral(resourceName: "Pen tool_@2x.png"))
    public var thickness: Int = 5
    public var handleTouch: ((Touch) -> Void) = { _ in }
    public var color: Color = defaultDrawingColor
    
    public init() {
        handleTouch = { [self] touch in
            let circle = Graphic.circle(radius: Int(self.thickness / 2), color: self.color)
            scene.place(circle, at: touch.position)
        }
    }
}

/// Draws a line from the previous touch point to the current touch point.
public class Lines: Brush, SideBarPlaceable {
    public var icon: Graphic = Graphic(image: #imageLiteral(resourceName: "Line tool_@2x.png"))
    public var thickness: Int = 5
    public var handleTouch: ((Touch) -> Void) = { _ in }
    public var color: Color = defaultDrawingColor
    public var previousTouchPoint: Point? = nil
    
    
    public init() {
        handleTouch = { [self] touch in
            if previousTouchPoint == nil {
                previousTouchPoint = touch.position
            }
            
            let line = Graphic.line(start: previousTouchPoint!, end: touch.position, thickness: self.thickness, color: self.color)
            scene.place(line)
            
            previousTouchPoint = touch.position
        }
    }
}

/// Simulates spray paint by drawing a series of variously-sized circles.
public class SprayPaint: Brush, SideBarPlaceable {
    public var icon: Graphic = Graphic(image: #imageLiteral(resourceName: "Spraypaint_@2x.png"))
    public var thickness: Int = 5
    public var handleTouch: ((Touch) -> Void) = { _ in }
    public var color: Color = defaultDrawingColor
    
    public init() {
        handleTouch = { [self] touch in
            for i in 1...Int.random(in: 10...30) {
                let randomRadius = (self.thickness / self.thickness) + Int.random(in: 0...(thickness / 2))
                let circle = Graphic.circle(radius: randomRadius, color: self.color)
                
                let randomPoint = touch.position.randomPoint(in: Double(thickness))
                guard randomPoint.x > -410 else { continue }
                scene.place(circle, at: randomPoint)
            }
        }
    }
}

/// Removes any graphic within the brush’s path.
public class Eraser: Brush, SideBarPlaceable {
    public var handleTouch: ((Touch) -> Void) = { _ in }
    public var icon: Graphic = Graphic(image: #imageLiteral(resourceName: "Eraser_@2x.png"))
    public var thickness: Int = 30
    public var color: Color = .white
    
    public init() {
        handleTouch = { [self] touch in
            let graphics = scene.getGraphics(at: touch.position, in: Size(width: self.thickness * 2, height: self.thickness * 2))
            scene.remove(graphics)
        }
    }
    
}

/// Sets up the drawing app. Contains the color picker, thickness picker, and all added brushes.
public class DrawingToolBar {
    var height: Int
    var width = 90
    var sideBarSpacing: Double = 85
    var sideRect: Graphic
    let colorPicker = ColorPicker()
    let thicknessPicker = ThicknessPicker()
    
    /// Maximum number of brushes.
    let maxBrushes = 6
    
    /// All of the brushes in the toolbar.
    var brushes: [Brush] = []
    
    /// The currently selected brush.
    var selectedBrush: Brush = Pen()
    
    /// Sets up the toolbar.
    public init(brushes: [Brush]) {
        self.brushes = brushes
        
        height = 250 + (brushes.count * 75)
        
        if let brush = brushes.first {
            selectedBrush = brush
        } else {
            selectedBrush = Pen()
        }
        
        sideRect = Graphic.rectangle(width: width, height: height, cornerRadius: 20, color: #colorLiteral(red: 0.7999293208, green: 0.8000453115, blue: 0.7999039292, alpha: 1.0))
        
        setUpSideBar()
        enableDrawing()
    }
    
    /// Enables drawing on the canvas.
    func enableDrawing() {
        scene.setOnTouchMovedHandler { touch in
            // Prevents touch events in the toolbar space.
            guard touch.position.x > -410 else { return }
            self.selectedBrush.handleTouch(touch)
        }
    }
    
    /// Disables drawing on the canvas.
    func disableDrawing() {
        scene.setOnTouchMovedHandler { touch in
            // Drawing disabled.
        }
    }
    
    /// Adds all pickers and brushes to the toolbar.
    func setUpSideBar() {
        var brushCount = 0
        scene.place(sideRect, at: Point(x: -460, y: 0))
        
        var selectorPosition = Point(x: -460, y: sideRect.location.y + Double((height/2)) - 60)
        
        for brush in brushes {
            guard brushCount < maxBrushes else { continue }
            
            if let brush = brushes.first {
                brush.icon.setImageColor(to: .systemPurple)
            }
            
            brush.icon.setOnTouchHandler {_ in
                brush.icon.pulse()
                self.selectedBrush.icon.setImageColor(to: .black)
                brush.icon.setImageColor(to: .systemPurple)
                self.selectedBrush = brush
            }
            scene.place(brush.icon, at: selectorPosition)
            selectorPosition.y -= sideBarSpacing
            brushCount += 1
        }
        
        // Adds the color picker.
        scene.place(colorPicker.icon, at: selectorPosition)
        colorPicker.icon.setOnTouchHandler { [self] _ in
            colorPicker.icon.pulse()
            colorPicker.draw(at: selectorPosition)
            disableDrawing()
            colorPicker.onSelectedColor = { color in
                colorPicker.icon.backgroundColor = color
                for var brush in brushes {
                    brush.color = color
                }
                enableDrawing()
            }
        }
        
        // Adds the thickness picker.
        selectorPosition.y -= sideBarSpacing
        let overlayCircle = Graphic.circle(radius: 20, color: .clear)
        scene.place(thicknessPicker.icon, at: selectorPosition)
        scene.place(overlayCircle, at: selectorPosition)
        overlayCircle.setOnTouchHandler { [self] _ in
            thicknessPicker.icon.pulse()
            thicknessPicker.draw(at: selectorPosition)
            disableDrawing()
            thicknessPicker.onSelectedValue = { thickness in
                for var brush in brushes {
                    brush.thickness = thickness
                }
                thicknessPicker.icon.size.height = CGFloat(thickness)
                enableDrawing()
            }
        }
        
        // Dismisses pickers when you touch outside of them.
        scene.setOnTouchHandler( { [self] touch in
            thicknessPicker.dismiss()
            colorPicker.dismiss()
            enableDrawing()
        })
    }
}
