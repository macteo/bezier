//: **Genesis**: how do you draw a Bézier curve?

//#-hidden-code
import UIKit
import PlaygroundSupport

PlaygroundPage.current.liveView = GenesisController()
//#-end-hidden-code

/*:
 Vector points
 Handles
 Control points
 Dotted line between control points
 Green dot between lines
 When the time goes on the 
 Triangular shape connecting the points
 Let's see how the shape moves over time
 Guideline
 Pink dots moving along the lines of the triangle
 Pink Tangent line
 Virtual pencil
 Virtual pencil moves from one side of the virtual line to the other
 
 
 State 1
 - Solo due punti
 - linea che li congiunge
 
 State 2
 - Punti
 - handles
 - sfondo della curva
 
 State 3
 - Punti
 - handles
 - linea tratteggiata che unisce le handles
 - sfondo della curva
 - bezier che viene disegnata
 
 State 4
 - Punti
 - handles
 - linea tratteggiata che unisce le handles
 - sfondo della curva
 - punti verdi che si muovono su handles e linee tratteggiate

 State 5
 - Punti
 - handles
 - linea tratteggiata che unisce le handles
 - sfondo della curva
 - segmenti verdi che si muovono su handles e linee tratteggiate

 State 6
 - Punti
 - handles
 - linea tratteggiata che unisce le handles
 - sfondo della curva
 - segmenti verdi che si muovono su handles e linee tratteggiate
 - punti viola che si muvono sui segmenti verdi
 
 State 7
 - Punti
 - handles
 - linea tratteggiata che unisce le handles
 - sfondo della curva
 - segmenti verdi che si muovono su handles e linee tratteggiate
 - punti viola che si muvono sui segmenti verdi
 - tangente viola che si muove
 
 State 8
 - Punti
 - handles
 - linea tratteggiata che unisce le handles
 - sfondo della curva
 - segmenti verdi che si muovono su handles e linee tratteggiate
 - tangente viola che si muove
 - penna virtuale che si muove sulla tangente
 - bezier che viene disegnata
 

 https://medium.com/sketch-app/mastering-the-bezier-curve-in-sketch-4da8fdf0dbbb#.sft1sc2y1
 
 */

//#-editable-code

//#-end-editable-code


//: [Next](@next)
