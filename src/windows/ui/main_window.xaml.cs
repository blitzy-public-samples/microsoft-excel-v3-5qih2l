using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using MicrosoftExcel.Core.Calculation;
using MicrosoftExcel.Core.DataStorage;
using MicrosoftExcel.Core.Collaboration;
using MicrosoftExcel.Windows.Services;
using MicrosoftExcel.Windows.ViewModels;

namespace MicrosoftExcel.Windows.UI
{
    public partial class MainWindow : Window
    {
        public MainWindowViewModel ViewModel { get; private set; }

        public MainWindow()
        {
            InitializeComponent();

            // Create and assign the ViewModel
            ViewModel = new MainWindowViewModel();
            DataContext = ViewModel;

            // Initialize UI components
            InitializeRibbon();
            InitializeWorksheetGrid();

            // Set up event handlers
            worksheetGrid.CellValueChanged += OnCellValueChanged;
            CommandBindings.Add(new CommandBinding(ApplicationCommands.Open, OnFileOpen));
            CommandBindings.Add(new CommandBinding(ApplicationCommands.Save, OnFileSave));
        }

        private void InitializeRibbon()
        {
            // Set up ribbon tabs
            ribbon.Tabs.Add(new RibbonTab() { Header = "Home" });
            ribbon.Tabs.Add(new RibbonTab() { Header = "Insert" });
            ribbon.Tabs.Add(new RibbonTab() { Header = "Page Layout" });

            // Add ribbon groups and controls
            var homeTab = ribbon.Tabs[0] as RibbonTab;
            var clipboardGroup = new RibbonGroup() { Header = "Clipboard" };
            clipboardGroup.Items.Add(new RibbonButton() { Label = "Paste", Command = ViewModel.PasteCommand });
            clipboardGroup.Items.Add(new RibbonButton() { Label = "Cut", Command = ViewModel.CutCommand });
            clipboardGroup.Items.Add(new RibbonButton() { Label = "Copy", Command = ViewModel.CopyCommand });
            homeTab.Groups.Add(clipboardGroup);

            // Add more groups and controls for other tabs...

            // Bind ribbon controls to ViewModel commands
            // This is done implicitly by setting the Command property above
        }

        private void InitializeWorksheetGrid()
        {
            // Set up grid layout
            worksheetGrid.RowCount = ViewModel.RowCount;
            worksheetGrid.ColumnCount = ViewModel.ColumnCount;

            // Initialize cell rendering and editing
            worksheetGrid.CellTemplateSelector = new CellTemplateSelector();
            worksheetGrid.CellEditingTemplateSelector = new CellEditingTemplateSelector();

            // Bind grid data to CellManager
            worksheetGrid.ItemsSource = ViewModel.CellManager.Cells;

            // Set up event handlers
            worksheetGrid.SelectionChanged += (s, e) => ViewModel.SelectedCell = worksheetGrid.SelectedCell;
        }

        private void OnCellValueChanged(object sender, CellValueChangedEventArgs e)
        {
            // Extract cell coordinates and new value
            int row = e.RowIndex;
            int column = e.ColumnIndex;
            object newValue = e.NewValue;

            // Update the ViewModel
            ViewModel.UpdateCellValue(row, column, newValue);

            // Trigger recalculation (this might be handled within the ViewModel)
            ViewModel.RecalculateDependentCells(row, column);
        }

        private void OnFileOpen(object sender, ExecutedRoutedEventArgs e)
        {
            var openFileDialog = new Microsoft.Win32.OpenFileDialog
            {
                Filter = "Excel Files|*.xlsx;*.xls|All Files|*.*"
            };

            if (openFileDialog.ShowDialog() == true)
            {
                try
                {
                    ViewModel.OpenFile(openFileDialog.FileName);
                    // Update UI to reflect the newly opened file
                    Title = $"Microsoft Excel - {System.IO.Path.GetFileName(openFileDialog.FileName)}";
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error opening file: {ex.Message}", "File Open Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private void OnFileSave(object sender, ExecutedRoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(ViewModel.CurrentFilePath))
            {
                var saveFileDialog = new Microsoft.Win32.SaveFileDialog
                {
                    Filter = "Excel Files|*.xlsx|All Files|*.*"
                };

                if (saveFileDialog.ShowDialog() == true)
                {
                    ViewModel.CurrentFilePath = saveFileDialog.FileName;
                }
                else
                {
                    return; // User cancelled the save operation
                }
            }

            try
            {
                ViewModel.SaveFile(ViewModel.CurrentFilePath);
                // Update UI to reflect the saved state
                Title = $"Microsoft Excel - {System.IO.Path.GetFileName(ViewModel.CurrentFilePath)}";
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving file: {ex.Message}", "File Save Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}