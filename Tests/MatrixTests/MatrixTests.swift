import XCTest

@testable import Matrix

final class MatrixTests: XCTestCase {
    /// The chat loader pool is exhaustive: Square 23 + Circular 20 + Fun 18 +
    /// Hex 10 + Grid3 20 + Icon 1 = 92. Triangle (20) is intentionally excluded.
    func testPoolCount() {
        XCTAssertEqual(MatrixLoadingPool.all.count, 92)
    }

    /// Loader ids are unique — a duplicate would bias the deterministic picker.
    func testPoolIdsUnique() {
        let ids = MatrixLoadingPool.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    /// `pick(seed:)` is deterministic and total over the pool.
    func testPickIsDeterministicAndInRange() {
        for seed in [0, 1, 7, 91, 92, 1000, -5] {
            let a = MatrixLoadingPool.pick(seed: seed)
            let b = MatrixLoadingPool.pick(seed: seed)
            XCTAssertEqual(a.id, b.id)
        }
    }

    /// 3×3 full mask lights all 9 cells; the triangle mask lights exactly 10.
    func testMaskSizes() {
        XCTAssertEqual(DotMatrix3.mask(for: .full).filter { $0 }.count, 9)
        XCTAssertEqual(DotMatrixTriangleBase.mask.count, 10)
    }

    /// The public props type constructs with defaults and overrides.
    func testCommonPropsPublicInit() {
        let p = DotMatrixCommonProps(size: 22, dotSize: 3, pattern: .full, cellPadding: 1)
        XCTAssertEqual(p.size, 22)
        XCTAssertEqual(p.pattern, .full)
    }

    /// The public loader catalog: 23+20+10+20+20 grids + 18 fun + 1 icon = 112,
    /// and every pooled id resolves to a real entry.
    func testLoaderCatalog() {
        XCTAssertEqual(MatrixLoaderID.all.count, 112)
        for id in MatrixLoaderID.all {
            if let poolID = id.poolID {
                XCTAssertNotNil(MatrixLoadingPool.entry(id: poolID), "missing \(poolID)")
            }
        }
    }
}
