import UIKit
import SwiftUI
import MicrosoftExcel.iOS.ViewModels
import MicrosoftExcel.Core.Models
import MicrosoftExcel.iOS.Utils

class RibbonView: UIView {
    
    // MARK: - Properties
    
    var viewModel: RibbonViewModel
    var tabSelector: UISegmentedControl
    var contentStackView: UIStackView
    var tabContentViews: [String: UIView] = [:]
    
    // MARK: - Initialization
    
    init(frame: CGRect, viewModel: RibbonViewModel) {
        self.viewModel = viewModel
        self.tabSelector = UISegmentedControl()
        self.contentStackView = UIStackView()
        
        super.init(frame: frame)
        
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Configure tabSelector
        tabSelector.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabSelector)
        
        // Configure contentStackView
        contentStackView.axis = .vertical
        contentStackView.distribution = .fillEqually
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStackView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            tabSelector.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tabSelector.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            tabSelector.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            contentStackView.topAnchor.constraint(equalTo: tabSelector.bottomAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        createTabContents()
    }
    
    private func createTabContents() {
        for (index, tab) in viewModel.tabs.enumerated() {
            tabSelector.insertSegment(withTitle: tab, at: index, animated: false)
            let contentView = createTabContent(for: tab)
            tabContentViews[tab] = contentView
            contentStackView.addArrangedSubview(contentView)
            contentView.isHidden = index != 0
        }
        tabSelector.selectedSegmentIndex = 0
    }
    
    private func createTabContent(for tabIdentifier: String) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        switch tabIdentifier {
        case "Home":
            return createHomeTabContent()
        case "Insert":
            return createInsertTabContent()
        case "Formulas":
            return createFormulaTabContent()
        default:
            return UIView()
        }
    }
    
    private func createHomeTabContent() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
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
        let numberFormatGroup = createButtonGroup(title: "Number", buttons: ["General", "Currency", "Percent"])
        stackView.addArrangedSubview(numberFormatGroup)
        
        return stackView
    }
    
    private func createInsertTabContent() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
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
    
    private func createFormulaTabContent() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
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
    
    private func createButtonGroup(title: String, buttons: [String]) -> UIView {
        let groupView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 4
        
        for buttonTitle in buttons {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
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
            
            buttonsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            buttonsStack.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        ])
        
        return groupView
    }
    
    private func createFontGroup() -> UIView {
        let groupView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "Font"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        let fontSelector = UIButton(type: .system)
        fontSelector.setTitle("Arial", for: .normal)
        
        let sizeSelector = UIButton(type: .system)
        sizeSelector.setTitle("11", for: .normal)
        
        let boldButton = UIButton(type: .system)
        boldButton.setTitle("B", for: .normal)
        boldButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        let italicButton = UIButton(type: .system)
        italicButton.setTitle("I", for: .normal)
        italicButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 14)
        
        let underlineButton = UIButton(type: .system)
        underlineButton.setTitle("U", for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [fontSelector, sizeSelector, boldButton, italicButton, underlineButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        
        groupView.addSubview(titleLabel)
        groupView.addSubview(stackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: groupView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: groupView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: groupView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        ])
        
        return groupView
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        tabSelector.addTarget(self, action: #selector(tabSelected(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc func tabSelected(_ sender: UISegmentedControl) {
        let selectedTab = viewModel.tabs[sender.selectedSegmentIndex]
        viewModel.selectedTab = selectedTab
        
        for (tab, contentView) in tabContentViews {
            contentView.isHidden = tab != selectedTab
        }
    }
}