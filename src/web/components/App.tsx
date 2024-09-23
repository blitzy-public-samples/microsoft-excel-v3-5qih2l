import React, { useState, useEffect } from 'react';
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import { Utilities } from '@microsoft/office-js-helpers';
import { Ribbon } from '../components/Ribbon';
import { WorksheetGrid } from '../components/WorksheetGrid';
import { FormulaBar } from '../components/FormulaBar';
import { StatusBar } from '../components/StatusBar';
import { useWorkbook } from '../hooks/useWorkbook';
import { ExcelService } from '../services/ExcelService';
import { AppContext } from '../context/AppContext';
import '../styles/App.css';

const App: React.FC = () => {
  const [isLoading, setIsLoading] = useState(true);
  const { workbook, setWorkbook, selectedCell, setSelectedCell } = useWorkbook();

  useEffect(() => {
    const initializeApp = async () => {
      try {
        const excelService = new ExcelService();
        const initialWorkbook = await excelService.loadInitialWorkbook();
        setWorkbook(initialWorkbook);
        setIsLoading(false);
      } catch (error) {
        console.error('Failed to initialize app:', error);
        setIsLoading(false);
      }
    };

    initializeApp();
  }, [setWorkbook]);

  const handleCellSelection = (cell: { row: number; col: number }) => {
    setSelectedCell(cell);
  };

  const handleFormulaChange = (formula: string) => {
    if (selectedCell && workbook) {
      const updatedWorkbook = ExcelService.updateCellFormula(workbook, selectedCell, formula);
      setWorkbook(updatedWorkbook);
    }
  };

  const handleWorkbookOperation = async (operation: string) => {
    setIsLoading(true);
    try {
      let updatedWorkbook;
      switch (operation) {
        case 'new':
          updatedWorkbook = await ExcelService.createNewWorkbook();
          break;
        case 'save':
          await ExcelService.saveWorkbook(workbook);
          updatedWorkbook = workbook;
          break;
        // Add more operations as needed
        default:
          throw new Error(`Unsupported operation: ${operation}`);
      }
      setWorkbook(updatedWorkbook);
    } catch (error) {
      console.error(`Failed to perform operation ${operation}:`, error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return <div>Loading...</div>;
  }

  return (
    <BrowserRouter>
      <AppContext.Provider value={{ workbook, selectedCell }}>
        <div className="excel-app">
          <Ribbon onOperation={handleWorkbookOperation} />
          <FormulaBar
            formula={selectedCell ? ExcelService.getCellFormula(workbook, selectedCell) : ''}
            onChange={handleFormulaChange}
          />
          <Switch>
            <Route path="/" exact>
              <WorksheetGrid onCellSelect={handleCellSelection} />
            </Route>
            {/* Add more routes as needed */}
          </Switch>
          <StatusBar />
        </div>
      </AppContext.Provider>
    </BrowserRouter>
  );
};

export default App;