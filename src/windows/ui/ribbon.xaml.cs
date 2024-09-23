using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using Microsoft.Windows.Controls.Ribbon;
using MicrosoftExcel.Windows.ViewModels;

namespace MicrosoftExcel.Windows.UI
{
    public partial class RibbonControl : UserControl
    {
        public RibbonViewModel ViewModel { get; private set; }

        public RibbonControl()
        {
            InitializeComponent();
            ViewModel = new RibbonViewModel();
            DataContext = ViewModel;
            InitializeRibbonTabs();
            SetupEventHandlers();
        }

        private void InitializeRibbonTabs()
        {
            // Create and add the Home tab
            var homeTab = new RibbonTab() { Header = "Home" };
            ribbon.Items.Add(homeTab);
            CreateHomeTabContent(homeTab);

            // Create and add the Insert tab
            var insertTab = new RibbonTab() { Header = "Insert" };
            ribbon.Items.Add(insertTab);
            CreateInsertTabContent(insertTab);

            // Create and add the Formulas tab
            var formulasTab = new RibbonTab() { Header = "Formulas" };
            ribbon.Items.Add(formulasTab);
            CreateFormulasTabContent(formulasTab);

            // Set up data bindings for ribbon controls
            SetupDataBindings();
        }

        private void CreateHomeTabContent(RibbonTab homeTab)
        {
            // Add groups and controls for the Home tab
            // Example:
            var fontGroup = new RibbonGroup() { Header = "Font" };
            var fontFamilyComboBox = new RibbonComboBox() { Label = "Font" };
            fontGroup.Items.Add(fontFamilyComboBox);
            homeTab.Items.Add(fontGroup);

            // Add more groups and controls as needed
        }

        private void CreateInsertTabContent(RibbonTab insertTab)
        {
            // Add groups and controls for the Insert tab
            // Example:
            var chartsGroup = new RibbonGroup() { Header = "Charts" };
            var insertColumnChartButton = new RibbonButton() { Label = "Column Chart" };
            chartsGroup.Items.Add(insertColumnChartButton);
            insertTab.Items.Add(chartsGroup);

            // Add more groups and controls as needed
        }

        private void CreateFormulasTabContent(RibbonTab formulasTab)
        {
            // Add groups and controls for the Formulas tab
            // Example:
            var functionLibraryGroup = new RibbonGroup() { Header = "Function Library" };
            var insertFunctionButton = new RibbonButton() { Label = "Insert Function" };
            functionLibraryGroup.Items.Add(insertFunctionButton);
            formulasTab.Items.Add(functionLibraryGroup);

            // Add more groups and controls as needed
        }

        private void SetupDataBindings()
        {
            // Set up data bindings for ribbon controls
            // Example:
            // fontFamilyComboBox.SetBinding(RibbonComboBox.SelectedItemProperty, new Binding("SelectedFontFamily") { Mode = BindingMode.TwoWay });
        }

        private void SetupEventHandlers()
        {
            // Set up event handlers for ribbon controls
            // Example:
            // fontFamilyComboBox.SelectionChanged += OnFontFamilyChanged;
        }

        private void OnFontFamilyChanged(object sender, SelectionChangedEventArgs e)
        {
            if (sender is RibbonComboBox fontFamilyComboBox && fontFamilyComboBox.SelectedItem is string selectedFontFamily)
            {
                ViewModel.UpdateFontFamily(selectedFontFamily);
                // Update the UI to reflect the new font family
                // This might be handled automatically by data binding, depending on your implementation
            }
        }

        private void OnNumberFormatChanged(object sender, SelectionChangedEventArgs e)
        {
            if (sender is RibbonComboBox numberFormatComboBox && numberFormatComboBox.SelectedItem is string selectedNumberFormat)
            {
                ViewModel.UpdateNumberFormat(selectedNumberFormat);
                // Update the UI to reflect the new number format
                // This might be handled automatically by data binding, depending on your implementation
            }
        }

        private void OnInsertChartClicked(object sender, RoutedEventArgs e)
        {
            if (sender is RibbonButton chartButton)
            {
                string chartType = DetermineChartType(chartButton);
                ViewModel.InsertChart(chartType);
                // The UI update to show the newly inserted chart would typically be handled by the ViewModel
                // and reflected in the main worksheet view, not directly in the Ribbon control
            }
        }

        private string DetermineChartType(RibbonButton chartButton)
        {
            // Logic to determine the chart type based on the clicked button
            // This could be based on the button's name, tag, or other property
            // Example:
            return chartButton.Label switch
            {
                "Column Chart" => "column",
                "Bar Chart" => "bar",
                "Pie Chart" => "pie",
                // Add more cases as needed
                _ => "column" // Default to column chart if type can't be determined
            };
        }
    }
}