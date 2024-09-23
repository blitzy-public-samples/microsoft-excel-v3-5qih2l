import XCTest
@testable import MicrosoftExcel
import AppKit
import MicrosoftExcel.MacOS.UI
import MicrosoftExcel.MacOS.ViewModels
import MicrosoftExcel.Core.Models

class MacOSUITests: XCTestCase {
    var app: NSApplication!
    var mainWindow: MainWindow?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = NSApplication.shared
        mainWindow = MainWindow(contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
                                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                                backing: .buffered,
                                defer: false)
        mainWindow?.makeKeyAndOrderFront(nil)
    }
    
    override func tearDownWithError() throws {
        mainWindow?.close()
        mainWindow = nil
        try super.tearDownWithError()
    }
    
    func testMainWindowInitialization() {
        XCTAssertNotNil(mainWindow, "MainWindow should not be nil")
        XCTAssertTrue(mainWindow?.isKeyWindow ?? false, "MainWindow should be the key window")
        XCTAssertNotNil(mainWindow?.viewModel, "MainWindow should have a ViewModel")
        XCTAssertTrue(mainWindow?.viewModel is MainWindowViewModel, "ViewModel should be of type MainWindowViewModel")
    }
    
    func testRibbonView() {
        guard let ribbonView = mainWindow?.ribbonView else { XCTFail("RibbonView should exist"); return }
        XCTAssertNotNil(ribbonView.viewModel, "RibbonView should have a ViewModel")
        XCTAssertTrue(ribbonView.viewModel is RibbonViewModel, "ViewModel should be of type RibbonViewModel")
        XCTAssertEqual(ribbonView.tabsStackView.arrangedSubviews.count, 3, "RibbonView should have 3 main tabs")
        
        // Test tab switching
        ribbonView.tabSelected(ribbonView.tabsStackView.arrangedSubviews[1] as! NSButton)
        XCTAssertEqual(ribbonView.viewModel.selectedTab, "Insert", "Selected tab should be 'Insert'")
    }
    
    func testWorksheetGridView() {
        guard let gridView = mainWindow?.worksheetGridView else { XCTFail("WorksheetGridView should exist"); return }
        XCTAssertNotNil(gridView.viewModel, "WorksheetGridView should have a ViewModel")
        XCTAssertTrue(gridView.viewModel is WorksheetGridViewModel, "ViewModel should be of type WorksheetGridViewModel")
        XCTAssertEqual(gridView.tableView.numberOfRows, 1000, "Grid should have 1000 rows by default")
        XCTAssertEqual(gridView.tableView.numberOfColumns, 26, "Grid should have 26 columns by default")
        
        // Test cell selection
        gridView.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        XCTAssertEqual(gridView.viewModel.selectedCell?.row, 0, "Selected cell row should be 0")
        XCTAssertEqual(gridView.viewModel.selectedCell?.column, 0, "Selected cell column should be 0")
    }
    
    func testUIInteractions() {
        // Create a test workbook
        let testWorkbook = Workbook(name: "Test Workbook")
        let testWorksheet = testWorkbook.addWorksheet(name: "Sheet1")
        testWorksheet.setCellValue(row: 0, column: 0, value: "Test")
        
        // Load the test workbook
        mainWindow?.viewModel.loadWorkbook(testWorkbook)
        
        // Simulate entering data
        mainWindow?.worksheetGridView.setCellValue(row: 1, column: 1, value: "New Data")
        XCTAssertEqual(testWorksheet.getCellValue(row: 1, column: 1) as? String, "New Data", "Cell value should be updated")
        
        // Test formula bar interaction
        mainWindow?.formulaBar.stringValue = "=SUM(A1:B1)"
        mainWindow?.formulaBar.sendAction(#selector(NSControl.performClick(_:)), to: nil, from: nil)
        XCTAssertEqual(testWorksheet.getCellValue(row: 2, column: 0) as? String, "=SUM(A1:B1)", "Formula should be entered in the cell")
    }
}