setUpLiveView(presentation: .aspectFitMinimum)

// Sets up a drawing app using the provided set of brushes.
// Each brush’s configuration can be modified in Drawing.swift.
let pen = Pen()
let lines = Lines()
let sprayPaint = SprayPaint()
let eraser = Eraser()
let toolbar = DrawingToolBar(brushes: [pen, lines, eraser, sprayPaint])
