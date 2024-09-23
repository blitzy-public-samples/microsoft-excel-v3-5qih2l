import XCTest
@testable import MicrosoftExcel
import UIKit
import MicrosoftExcel.iOS.UI
import MicrosoftExcel.iOS.ViewModels
import MicrosoftExcel.Core.Models

class iOSUITests: XCTestCase {
    var app: UIApplication!
    var window: UIWindow?
    var mainViewController: MainViewController?

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = UIApplication.shared
        window = UIWindow(frame: UIScreen.main.bounds)
        mainViewController = MainViewController()
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
    }

    override func tearDownWithError() throws {
        window?.rootViewController = nil
        mainViewController = nil
        window = nil
        try super.tearDownWithError()
    }

    func testMainViewControllerInitialization() {
        XCTAssertNotNil(mainViewController, "MainViewController should not be nil")
        XCTAssertNotNil(mainViewController?.viewModel, "MainViewController should have a ViewModel")
        XCTAssertTrue(mainViewController?.viewModel is MainViewModel, "ViewModel should be of type MainViewModel")
        XCTAssertNotNil(mainViewController?.ribbonView, "MainViewController should have a RibbonView")
        XCTAssertNotNil(mainViewController?.worksheetGridView, "MainViewController should have a WorksheetGridView")
    }

    func testRibbonView() {
        guard let ribbonView = mainViewController?.ribbonView else { XCTFail("RibbonView should exist"); return }
        XCTAssertNotNil(ribbonView.viewModel, "RibbonView should have a ViewModel")
        XCTAssertTrue(ribbonView.viewModel is RibbonViewModel, "ViewModel should be of type RibbonViewModel")
        XCTAssertEqual(ribbonView.tabSelector.numberOfSegments, 3, "RibbonView should have 3 main tabs")
        
        // Test tab switching
        ribbonView.tabSelector.selectedSegmentIndex = 1
        ribbonView.tabSelected(ribbonView.tabSelector)
        XCTAssertEqual(ribbonView.viewModel.selectedTab, "Insert", "Selected tab should be 'Insert'")
    }

    func testWorksheetGridView() {
        guard let gridView = mainViewController?.worksheetGridView else { XCTFail("WorksheetGridView should exist"); return }
        XCTAssertNotNil(gridView.viewModel, "WorksheetGridView should have a ViewModel")
        XCTAssertTrue(gridView.viewModel is WorksheetGridViewModel, "ViewModel should be of type WorksheetGridViewModel")
        XCTAssertEqual(gridView.collectionView.numberOfSections, 1000, "Grid should have 1000 rows by default")
        XCTAssertEqual(gridView.collectionView.numberOfItems(inSection: 0), 26, "Grid should have 26 columns by default")
        
        // Test cell selection
        let indexPath = IndexPath(item: 0, section: 0)
        gridView.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        gridView.collectionView(gridView.collectionView, didSelectItemAt: indexPath)
        XCTAssertEqual(gridView.viewModel.selectedCell?.row, 0, "Selected cell row should be 0")
        XCTAssertEqual(gridView.viewModel.selectedCell?.column, 0, "Selected cell column should be 0")
    }

    func testUIInteractions() {
        // Create a test workbook
        let testWorkbook = Workbook(name: "Test Workbook")
        let testWorksheet = testWorkbook.addWorksheet(name: "Sheet1")
        testWorksheet.setCellValue(row: 0, column: 0, value: "Test")

        // Load the test workbook
        mainViewController?.viewModel.loadWorkbook(testWorkbook)

        // Simulate entering data
        mainViewController?.worksheetGridView.updateCellValue(row: 1, column: 1, newValue: "New Data")
        XCTAssertEqual(testWorksheet.getCellValue(row: 1, column: 1) as? String, "New Data", "Cell value should be updated")

        // Test formula bar interaction
        mainViewController?.formulaBar.text = "=SUM(A1:B1)"
        mainViewController?.handleFormulaBarEdit("=SUM(A1:B1)")
        XCTAssertEqual(testWorksheet.getCellValue(row: 2, column: 0) as? String, "=SUM(A1:B1)", "Formula should be entered in the cell")
    }
}