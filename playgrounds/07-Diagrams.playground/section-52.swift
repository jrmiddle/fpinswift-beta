class Draw : NSView {
    let diagram: Diagram

    init(frame frameRect: NSRect, diagram: Diagram) {
        self.diagram = diagram
        super.init(frame:frameRect)
    }

    override func drawRect(dirtyRect: NSRect) {
        draw(NSGraphicsContext.currentContext().cgContext, self.bounds, diagram)
    }
}