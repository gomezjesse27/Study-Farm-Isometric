//
//  Grid.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/22/23.
//

import Foundation
import SceneKit
struct Grid {
    let size: Int
    private var cells: [[Bool]]

    init(size: Int) {
        self.size = size
        self.cells = Array(repeating: Array(repeating: false, count: size), count: size)
    }

    func isCellFree(x: Int, y: Int) -> Bool {
        guard x >= 0, x < size, y >= 0, y < size else { return false }
        return cells[y][x]
    }
    func gridToWorld(x: Int, y: Int) -> (x: Float, y: Float) {
        return (Float(x) - Float(size)/2 + 0.5, Float(y) - Float(size)/2 + 0.5)
    }

    func worldToGrid(x: Float, y: Float) -> (x: Int, y: Int) {
        return (Int(x + Float(size)/2 - 0.5), Int(y + Float(size)/2 - 0.5))
    }

    mutating func occupyCell(x: Int, y: Int) {
        guard x >= 0, x < size, y >= 0, y < size else { return }
        cells[y][x] = true
    }

    mutating func freeCell(x: Int, y: Int) {
        guard x >= 0, x < size, y >= 0, y < size else { return }
        cells[y][x] = false
    }

    func randomFreeCell() -> (x: Int, y: Int)? {
        let freeCells = cells.enumerated().flatMap { (y, row) in
            row.enumerated().compactMap { (x, isOccupied) in
                isOccupied ? nil : (x, y)
            }
        }
        return freeCells.randomElement()
    }
}
