using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Collections.ObjectModel;
using MicrosoftExcel.Windows.ViewModels;
using MicrosoftExcel.Core.Models;
using MicrosoftExcel.Core.DataStorage;

namespace MicrosoftExcel.Windows.UI
{
    public partial class WorksheetGridControl : UserControl
    {
        public WorksheetGridViewModel ViewModel { get; private set; }
        public int RowCount { get; set; }
        public int ColumnCount { get; set; }

        public WorksheetGridControl()
        {
            InitializeComponent();
            ViewModel = new WorksheetGridViewModel();
            DataContext = ViewModel;

            // Set default values for RowCount and ColumnCount
            RowCount = 1000;
            ColumnCount = 26;

            InitializeGrid();
            SetupEventHandlers();
        }

        private void InitializeGrid()
        {
            CellPanel.RowDefinitions.Clear();
            CellPanel.ColumnDefinitions.Clear();

            for (int i = 0; i < RowCount; i++)
            {
                CellPanel.RowDefinitions.Add(new RowDefinition());
            }

            for (int j = 0; j < ColumnCount; j++)
            {
                CellPanel.ColumnDefinitions.Add(new ColumnDefinition());
            }

            CreateCells();
        }

        private void CreateCells()
        {
            CellGrid.Items.Clear();
            ViewModel.Cells.Clear();

            for (int row = 0; row < RowCount; row++)
            {
                for (int col = 0; col < ColumnCount; col++)
                {
                    var cell = new Cell { Row = row, Column = col };
                    ViewModel.Cells.Add(cell);

                    var cellControl = new CellControl(cell);
                    Grid.SetRow(cellControl, row);
                    Grid.SetColumn(cellControl, col);
                    CellGrid.Items.Add(cellControl);
                }
            }
        }

        private void SetupEventHandlers()
        {
            CellGrid.AddHandler(CellControl.CellSelectedEvent, new RoutedEventHandler(OnCellSelected));
            CellGrid.AddHandler(CellControl.CellValueChangedEvent, new RoutedEventHandler(OnCellValueChanged));
            FormulaBar.TextChanged += OnFormulaBarTextChanged;
        }

        private void OnCellSelected(object sender, RoutedEventArgs e)
        {
            if (e is CellSelectedEventArgs args)
            {
                ViewModel.SelectCell(args.Row, args.Column);
                FormulaBar.Text = ViewModel.ActiveCell?.Formula ?? string.Empty;
                UpdateSelectionVisual(args.Row, args.Column);
            }
        }

        private void OnCellValueChanged(object sender, RoutedEventArgs e)
        {
            if (e is CellValueChangedEventArgs args)
            {
                ViewModel.UpdateCellValue(args.Row, args.Column, args.NewValue);
                ViewModel.RecalculateDependentCells(args.Row, args.Column);
                UpdateCellUI(args.Row, args.Column);
            }
        }

        private void OnFormulaBarTextChanged(object sender, TextChangedEventArgs e)
        {
            if (ViewModel.ActiveCell != null)
            {
                string newFormula = FormulaBar.Text;
                ViewModel.UpdateActiveCell(newFormula);
                ViewModel.RecalculateDependentCells(ViewModel.ActiveCell.Row, ViewModel.ActiveCell.Column);
                UpdateCellUI(ViewModel.ActiveCell.Row, ViewModel.ActiveCell.Column);
            }
        }

        private void UpdateSelectionVisual(int row, int column)
        {
            // Implement logic to visually highlight the selected cell
        }

        private void UpdateCellUI(int row, int column)
        {
            // Implement logic to update the UI for the specified cell
        }
    }
}