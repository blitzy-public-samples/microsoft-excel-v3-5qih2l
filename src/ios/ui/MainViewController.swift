import UIKit
import SwiftUI
import MicrosoftExcel.Core.Calculation
import MicrosoftExcel.Core.DataStorage
import MicrosoftExcel.Core.Collaboration
import MicrosoftExcel.iOS.Services
import MicrosoftExcel.iOS.ViewModels

class MainViewController: UIViewController {
    
    var viewModel: MainViewModel
    var contentView: UIView
    var ribbonView: RibbonView
    var worksheetGridView: WorksheetGridView
    var formulaBar: UITextField
    
    init() {
        self.viewModel = MainViewModel()
        self.contentView = UIView()
        self.ribbonView = RibbonView()
        self.worksheetGridView = WorksheetGridView()
        self.formulaBar = UITextField()
        
        super.init(nibName: nil, bundle: nil)
        
        setupNavigationBar()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        setupRibbonView()
        setupWorksheetGridView()
        setupFormulaBar()
        configureLayoutConstraints()
        bindViewModelToUI()
    }
    
    private func setupUI() {
        contentView = UIView()
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        
        ribbonView = RibbonView()
        contentView.addSubview(ribbonView)
        
        worksheetGridView = WorksheetGridView()
        contentView.addSubview(worksheetGridView)
        
        formulaBar = UITextField()
        formulaBar.borderStyle = .roundedRect
        formulaBar.placeholder = "Enter formula"
        contentView.addSubview(formulaBar)
        
        setupAutoLayoutConstraints()
    }
    
    private func setupNavigationBar() {
        title = "Microsoft Excel"
        
        let newButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newWorkbook))
        let openButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(openWorkbook))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveWorkbook))
        
        navigationItem.leftBarButtonItems = [newButton, openButton]
        navigationItem.rightBarButtonItem = saveButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupAutoLayoutConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        ribbonView.translatesAutoresizingMaskIntoConstraints = false
        worksheetGridView.translatesAutoresizingMaskIntoConstraints = false
        formulaBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            ribbonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ribbonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ribbonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ribbonView.heightAnchor.constraint(equalToConstant: 100),
            
            formulaBar.topAnchor.constraint(equalTo: ribbonView.bottomAnchor, constant: 8),
            formulaBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            formulaBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            formulaBar.heightAnchor.constraint(equalToConstant: 40),
            
            worksheetGridView.topAnchor.constraint(equalTo: formulaBar.bottomAnchor, constant: 8),
            worksheetGridView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            worksheetGridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            worksheetGridView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func bindViewModelToUI() {
        viewModel.selectedCellChanged = { [weak self] cell in
            self?.formulaBar.text = cell.formula
            self?.ribbonView.updateFormatting(with: cell.formatting)
        }
        
        formulaBar.addTarget(self, action: #selector(handleFormulaBarEdit), for: .editingChanged)
    }
    
    func handleCellSelection(position: CellPosition) {
        viewModel.selectCell(at: position)
        formulaBar.text = viewModel.selectedCell?.formula
        ribbonView.updateFormatting(with: viewModel.selectedCell?.formatting)
    }
    
    @objc func handleFormulaBarEdit() {
        guard let newFormula = formulaBar.text else { return }
        viewModel.updateCellFormula(newFormula)
        worksheetGridView.refreshActiveCell()
    }
    
    @objc func newWorkbook() {
        // Implement new workbook creation
    }
    
    @objc func openWorkbook() {
        // Implement workbook opening
    }
    
    @objc func saveWorkbook() {
        // Implement workbook saving
    }
}