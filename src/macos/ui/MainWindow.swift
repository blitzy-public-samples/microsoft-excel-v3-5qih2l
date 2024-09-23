import AppKit
import SwiftUI
import MicrosoftExcel.Core.Calculation
import MicrosoftExcel.Core.DataStorage
import MicrosoftExcel.Core.Collaboration
import MicrosoftExcel.MacOS.Services
import MicrosoftExcel.MacOS.ViewModels

class MainWindow: NSWindowController {
    var viewModel: MainWindowViewModel
    var toolbar: NSToolbar?
    var contentView: NSView?
    
    init() {
        // Create a new NSWindow instance with appropriate size and style
        let window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 1024, height: 768),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered,
                              defer: false)
        
        // Initialize the windowController with the new window
        super.init(window: window)
        
        // Create and assign a new instance of MainWindowViewModel to viewModel property
        self.viewModel = MainWindowViewModel()
        
        setupToolbar()
        setupContentView()
        setupRibbonControl()
        setupWorksheetGrid()
        
        // Configure window properties
        window.title = "Microsoft Excel"
        window.minSize = NSSize(width: 800, height: 600)
        
        // Set up event handlers for window interactions
        window.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupToolbar() {
        // Create a new NSToolbar instance
        let toolbar = NSToolbar(identifier: "MainToolbar")
        
        // Set the toolbar delegate to self
        toolbar.delegate = self
        
        // Configure toolbar properties
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.displayMode = .iconAndLabel
        
        // Add toolbar items for common actions
        let newItem = NSToolbarItem(itemIdentifier: .init("NewDocument"))
        newItem.label = "New"
        newItem.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: "New Document")
        newItem.target = self
        newItem.action = #selector(newDocument)
        
        let openItem = NSToolbarItem(itemIdentifier: .init("OpenDocument"))
        openItem.label = "Open"
        openItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: "Open Document")
        openItem.target = self
        openItem.action = #selector(openDocument)
        
        let saveItem = NSToolbarItem(itemIdentifier: .init("SaveDocument"))
        saveItem.label = "Save"
        saveItem.image = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: "Save Document")
        saveItem.target = self
        saveItem.action = #selector(saveDocument)
        
        toolbar.insertItem(withItemIdentifier: newItem.itemIdentifier, at: 0)
        toolbar.insertItem(withItemIdentifier: openItem.itemIdentifier, at: 1)
        toolbar.insertItem(withItemIdentifier: saveItem.itemIdentifier, at: 2)
        
        // Set the window's toolbar to the newly created toolbar
        self.window?.toolbar = toolbar
        self.toolbar = toolbar
    }
    
    func setupContentView() {
        // Create a new NSView instance for the content view
        let contentView = NSView(frame: (window?.contentView?.bounds)!)
        
        // Set up auto layout constraints for the content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the window's content view to the newly created view
        window?.contentView = contentView
        self.contentView = contentView
    }
    
    func setupRibbonControl() {
        // Create an instance of RibbonControl
        let ribbonControl = RibbonControl(frame: NSRect(x: 0, y: 0, width: contentView!.bounds.width, height: 100))
        
        // Configure ribbon tabs and groups
        ribbonControl.configureTabs()
        
        // Add ribbon controls to the content view
        contentView?.addSubview(ribbonControl)
        
        // Set up bindings between ribbon controls and view model commands
        ribbonControl.bindToViewModel(viewModel)
    }
    
    func setupWorksheetGrid() {
        // Create an instance of WorksheetGridView
        let worksheetGrid = WorksheetGridView(frame: NSRect(x: 0, y: 100, width: contentView!.bounds.width, height: contentView!.bounds.height - 100))
        
        // Configure grid properties
        worksheetGrid.rowCount = 1000
        worksheetGrid.columnCount = 26
        
        // Add the worksheet grid to the content view
        contentView?.addSubview(worksheetGrid)
        
        // Set up bindings between the grid and view model data
        worksheetGrid.bindToViewModel(viewModel)
    }
    
    @objc func newDocument() {
        // Implement new document creation
    }
    
    @objc func openDocument() {
        // Implement document opening
    }
    
    @objc func saveDocument() {
        // Implement document saving
    }
}

extension MainWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Check for unsaved changes
        if viewModel.hasUnsavedChanges {
            // If there are unsaved changes, prompt the user to save
            let alert = NSAlert()
            alert.messageText = "Do you want to save changes to your document?"
            alert.informativeText = "Your changes will be lost if you don't save them."
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Don't Save")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn:
                // Handle saving
                saveDocument()
            case .alertSecondButtonReturn:
                // Don't save, continue closing
                break
            case .alertThirdButtonReturn:
                // Cancel closing
                return
            default:
                break
            }
        }
        
        // Perform any necessary cleanup operations
        viewModel.cleanup()
        
        // Notify the application delegate about window closure
        NSApp.delegate?.applicationShouldTerminate?(NSApp)
    }
}

extension MainWindow: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        // Implement toolbar item creation based on identifiers
        return nil
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        // Return default toolbar item identifiers
        return []
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        // Return allowed toolbar item identifiers
        return []
    }
}