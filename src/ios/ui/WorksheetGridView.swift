import UIKit
import MicrosoftExcel.iOS.ViewModels
import MicrosoftExcel.Core.Models
import MicrosoftExcel.Core.DataStorage
import MicrosoftExcel.iOS.Utils

class WorksheetGridView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var viewModel: WorksheetGridViewModel
    var scrollView: UIScrollView
    var collectionView: UICollectionView
    var flowLayout: UICollectionViewFlowLayout
    var rowCount: Int
    var columnCount: Int
    
    init(frame: CGRect, viewModel: WorksheetGridViewModel) {
        self.viewModel = viewModel
        self.scrollView = UIScrollView()
        self.flowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        self.rowCount = 1000 // Default value
        self.columnCount = 26 // Default value
        
        super.init(frame: frame)
        
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        // Configure flowLayout
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        // Configure collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(collectionView)
        
        // Add column headers
        // TODO: Implement column headers
        
        // Add row headers
        // TODO: Implement row headers
        
        // Set up auto layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupBindings() {
        // TODO: Implement bindings between UI elements and view model
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowCount * columnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let row = indexPath.item / columnCount
        let column = indexPath.item % columnCount
        
        if let cellData = viewModel.getCellData(row: row, column: column) {
            CellFormatter.formatCell(cell, with: cellData)
        }
        
        // TODO: Set up gesture recognizers for cell editing
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.item / columnCount
        let column = indexPath.item % columnCount
        
        viewModel.selectCell(row: row, column: column)
        // TODO: Notify delegate about cell selection
        // TODO: Update UI to highlight selected cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let column = indexPath.item % columnCount
        let row = indexPath.item / columnCount
        
        let width = viewModel.getColumnWidth(column: column)
        let height = viewModel.getRowHeight(row: row)
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Public methods
    
    func updateCellValue(newValue: String, at indexPath: IndexPath) {
        let row = indexPath.item / columnCount
        let column = indexPath.item % columnCount
        
        viewModel.updateCellValue(row: row, column: column, newValue: newValue)
        // TODO: Trigger recalculation of dependent cells
        collectionView.reloadItems(at: [indexPath])
    }
}