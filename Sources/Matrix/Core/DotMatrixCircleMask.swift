import Foundation

/// 5×5 circular mask — drops the four corners. Used by all 20 circular loaders.
@inline(__always)
func isWithinCircularMask(row: Int, col: Int) -> Bool {
    !((row == 0 && col == 0)
        || (row == 0 && col == 4)
        || (row == 4 && col == 0)
        || (row == 4 && col == 4))
}
