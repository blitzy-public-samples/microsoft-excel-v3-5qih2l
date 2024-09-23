import AppKit
import SwiftUI
import MicrosoftExcel.MacOS.ViewModels
import MicrosoftExcel.Core.Models
import MicrosoftExcel.MacOS.Utils

class RibbonView: NSView {
    var viewModel: RibbonViewModel
    var tabsStackView: NSStackView
    var contentStackView: NSStackView
    var tabContentViews: [String: NSView]

    init(frame: NSRect, viewModel: RibbonViewModel) {
        self.viewModel = viewModel
        self.tabsStackView = NSStackView()
        self.contentStackView = NSStackView()
        self.tabContentViews = [:]
        
        super.init(frame: frame)
        
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        tabsStackView = NSStackView()
        tabsStackView.orientation = .horizontal
        tabsStackView.distribution = .fillEqually
        tabsStackView.spacing = 5
        
        contentStackView = NSStackView()
        contentStackView.orientation = .vertical
        contentStackView.distribution = .fillEqually
        
        addSubview(tabsStackView)
        addSubview(contentStackView)
        
        tabsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabsStackView.topAnchor.constraint(equalTo: topAnchor),
            tabsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabsStackView.heightAnchor.constraint(equalToConstant: 40),
            
            contentStackView.topAnchor.constraint(equalTo: tabsStackView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        createTabs()
        createTabContents()
    }
    
    private func setupBindings() {
        // Implement bindings between UI elements and view model
    }
    
    private func createTabs() {
        for tab in viewModel.tabs {
            let button = NSButton(title: tab, target: self, action: #selector(tabSelected(_:)))
            button.identifier = NSUserInterfaceItemIdentifier(tab)
            tabsStackView.addArrangedSubview(button)
        }
    }
    
    private func createTabContents() {
        for tab in viewModel.tabs {
            let contentView = createTabContent(for: tab)
            tabContentViews[tab] = contentView
            contentStackView.addArrangedSubview(contentView)
            contentView.isHidden = true
        }
        
        if let firstTab = viewModel.tabs.first {
            tabContentViews[firstTab]?.isHidden = false
        }
    }
    
    private func createTabContent(for tabIdentifier: String) -> NSView {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        switch tabIdentifier {
        case "Home":
            return createHomeTabContent()
        case "Insert":
            return createInsertTabContent()
        case "Formulas":
            return createFormulaTabContent()
        default:
            return stackView
        }
    }
    
    private func createHomeTabContent() -> NSView {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        // Clipboard group
        let clipboardGroup = createButtonGroup(title: "Clipboard", buttons: ["Cut", "Copy", "Paste"])
        stackView.addArrangedSubview(clipboardGroup)
        
        // Font group
        let fontGroup = createFontGroup()
        stackView.addArrangedSubview(fontGroup)
        
        // Alignment group
        let alignmentGroup = createButtonGroup(title: "Alignment", buttons: ["Left", "Center", "Right"])
        stackView.addArrangedSubview(alignmentGroup)
        
        // Number Format group
        let numberFormatGroup = createNumberFormatGroup()
        stackView.addArrangedSubview(numberFormatGroup)
        
        return stackView
    }
    
    private func createInsertTabContent() -> NSView {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        // Tables group
        let tablesGroup = createButtonGroup(title: "Tables", buttons: ["Table", "PivotTable"])
        stackView.addArrangedSubview(tablesGroup)
        
        // Charts group
        let chartsGroup = createButtonGroup(title: "Charts", buttons: ["Column", "Line", "Pie"])
        stackView.addArrangedSubview(chartsGroup)
        
        // Illustrations group
        let illustrationsGroup = createButtonGroup(title: "Illustrations", buttons: ["Picture", "Shapes"])
        stackView.addArrangedSubview(illustrationsGroup)
        
        return stackView
    }
    
    private func createFormulaTabContent() -> NSView {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        // Function Library group
        let functionLibraryGroup = createButtonGroup(title: "Function Library", buttons: ["Insert Function", "AutoSum", "Recently Used"])
        stackView.addArrangedSubview(functionLibraryGroup)
        
        // Defined Names group
        let definedNamesGroup = createButtonGroup(title: "Defined Names", buttons: ["Name Manager", "Define Name"])
        stackView.addArrangedSubview(definedNamesGroup)
        
        // Formula Auditing group
        let formulaAuditingGroup = createButtonGroup(title: "Formula Auditing", buttons: ["Trace Precedents", "Trace Dependents"])
        stackView.addArrangedSubview(formulaAuditingGroup)
        
        return stackView
    }
    
    private func createButtonGroup(title: String, buttons: [String]) -> NSView {
        let groupView = NSView()
        let titleLabel = NSTextField(labelWithString: title)
        let buttonsStack = NSStackView()
        
        buttonsStack.orientation = .vertical
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 5
        
        for buttonTitle in buttons {
            let button = NSButton(title: buttonTitle, target: nil, action: nil)
            buttonsStack.addArrangedSubview(button)
        }
        
        groupView.addSubview(titleLabel)
        groupView.addSubview(buttonsStack)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: groupView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            
            buttonsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            buttonsStack.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        ])
        
        return groupView
    }
    
    private func createFontGroup() -> NSView {
        let groupView = NSView()
        let titleLabel = NSTextField(labelWithString: "Font")
        let fontPopUp = NSPopUpButton()
        let sizePopUp = NSPopUpButton()
        let buttonsStack = NSStackView()
        
        buttonsStack.orientation = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 5
        
        let boldButton = NSButton(title: "B", target: nil, action: nil)
        let italicButton = NSButton(title: "I", target: nil, action: nil)
        let underlineButton = NSButton(title: "U", target: nil, action: nil)
        
        buttonsStack.addArrangedSubview(boldButton)
        buttonsStack.addArrangedSubview(italicButton)
        buttonsStack.addArrangedSubview(underlineButton)
        
        groupView.addSubview(titleLabel)
        groupView.addSubview(fontPopUp)
        groupView.addSubview(sizePopUp)
        groupView.addSubview(buttonsStack)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        fontPopUp.translatesAutoresizingMaskIntoConstraints = false
        sizePopUp.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: groupView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            
            fontPopUp.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            fontPopUp.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            fontPopUp.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            
            sizePopUp.topAnchor.constraint(equalTo: fontPopUp.bottomAnchor, constant: 5),
            sizePopUp.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            sizePopUp.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            
            buttonsStack.topAnchor.constraint(equalTo: sizePopUp.bottomAnchor, constant: 5),
            buttonsStack.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        ])
        
        return groupView
    }
    
    private func createNumberFormatGroup() -> NSView {
        let groupView = NSView()
        let titleLabel = NSTextField(labelWithString: "Number")
        let formatPopUp = NSPopUpButton()
        let buttonsStack = NSStackView()
        
        buttonsStack.orientation = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 5
        
        let currencyButton = NSButton(title: "$", target: nil, action: nil)
        let percentButton = NSButton(title: "%", target: nil, action: nil)
        
        buttonsStack.addArrangedSubview(currencyButton)
        buttonsStack.addArrangedSubview(percentButton)
        
        groupView.addSubview(titleLabel)
        groupView.addSubview(formatPopUp)
        groupView.addSubview(buttonsStack)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        formatPopUp.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: groupView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            
            formatPopUp.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            formatPopUp.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            formatPopUp.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            
            buttonsStack.topAnchor.constraint(equalTo: formatPopUp.bottomAnchor, constant: 5),
            buttonsStack.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        ])
        
        return groupView
    }
    
    @objc private func tabSelected(_ sender: NSButton) {
        guard let identifier = sender.identifier?.rawValue else { return }
        viewModel.selectedTab = identifier
        
        for (tabId, contentView) in tabContentViews {
            contentView.isHidden = (tabId != identifier)
        }
    }
}