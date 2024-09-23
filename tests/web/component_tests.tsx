import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import { App } from '../src/web/components/App';
import { Ribbon } from '../src/web/components/Ribbon';
import { WorksheetGrid } from '../src/web/components/WorksheetGrid';
import { FormulaBar } from '../src/web/components/FormulaBar';
import { AppContext } from '../src/web/context/AppContext';
import { useWorkbook } from '../src/web/hooks/useWorkbook';
import { ExcelService } from '../src/web/services/ExcelService';

jest.mock('../src/web/hooks/useWorkbook');
jest.mock('../src/web/services/ExcelService');

describe('App component', () => {
  beforeEach(() => {
    (useWorkbook as jest.Mock).mockReturnValue({
      workbook: { sheets: [{ name: 'Sheet1', cells: [] }] },
      activeSheet: { name: 'Sheet1', cells: [] },
      activeCell: null,
      setActiveCell: jest.fn(),
      updateCell: jest.fn(),
    });

    (ExcelService as jest.Mock).mockImplementation(() => ({
      saveWorkbook: jest.fn(),
      loadWorkbook: jest.fn(),
    }));
  });

  it('renders without crashing', () => {
    render(<App />);
    expect(screen.getByTestId('app-container')).toBeInTheDocument();
  });

  it('renders Ribbon, FormulaBar, and WorksheetGrid components', () => {
    render(<App />);
    expect(screen.getByTestId('ribbon')).toBeInTheDocument();
    expect(screen.getByTestId('formula-bar')).toBeInTheDocument();
    expect(screen.getByTestId('worksheet-grid')).toBeInTheDocument();
  });

  it('updates state and passes props to child components', () => {
    render(<App />);
    const cell = screen.getByTestId('cell-A1');
    fireEvent.click(cell);
    expect(useWorkbook().setActiveCell).toHaveBeenCalledWith({ row: 0, col: 0 });
  });
});

describe('Ribbon component', () => {
  const mockProps = {
    onFormatChange: jest.fn(),
    onInsert: jest.fn(),
    onFormulaInsert: jest.fn(),
  };

  it('renders all expected tabs', () => {
    render(<Ribbon {...mockProps} />);
    expect(screen.getByText('Home')).toBeInTheDocument();
    expect(screen.getByText('Insert')).toBeInTheDocument();
    expect(screen.getByText('Formulas')).toBeInTheDocument();
  });

  it('switches tabs correctly', () => {
    render(<Ribbon {...mockProps} />);
    fireEvent.click(screen.getByText('Insert'));
    expect(screen.getByTestId('insert-tab-content')).toBeVisible();
  });

  it('triggers correct actions when buttons are clicked', () => {
    render(<Ribbon {...mockProps} />);
    fireEvent.click(screen.getByText('Bold'));
    expect(mockProps.onFormatChange).toHaveBeenCalledWith({ bold: true });
  });
});

describe('WorksheetGrid component', () => {
  const mockProps = {
    sheet: { name: 'Sheet1', cells: Array(100).fill(null).map(() => ({ value: '' })) },
    activeCell: null,
    onCellSelect: jest.fn(),
    onCellValueChange: jest.fn(),
  };

  it('renders the correct number of cells', () => {
    render(<WorksheetGrid {...mockProps} />);
    expect(screen.getAllByTestId(/^cell-/)).toHaveLength(100);
  });

  it('handles cell selection', () => {
    render(<WorksheetGrid {...mockProps} />);
    fireEvent.click(screen.getByTestId('cell-A1'));
    expect(mockProps.onCellSelect).toHaveBeenCalledWith({ row: 0, col: 0 });
  });

  it('handles cell editing and value updates', () => {
    render(<WorksheetGrid {...mockProps} />);
    const cell = screen.getByTestId('cell-A1');
    fireEvent.doubleClick(cell);
    userEvent.type(cell, 'New Value');
    fireEvent.blur(cell);
    expect(mockProps.onCellValueChange).toHaveBeenCalledWith({ row: 0, col: 0, value: 'New Value' });
  });

  it('supports navigation using keyboard inputs', () => {
    render(<WorksheetGrid {...mockProps} />);
    const cell = screen.getByTestId('cell-A1');
    fireEvent.click(cell);
    fireEvent.keyDown(cell, { key: 'ArrowRight' });
    expect(mockProps.onCellSelect).toHaveBeenCalledWith({ row: 0, col: 1 });
  });
});

describe('FormulaBar component', () => {
  const mockProps = {
    activeCell: { row: 0, col: 0 },
    cellValue: '',
    onFormulaChange: jest.fn(),
  };

  it('displays the correct cell reference', () => {
    render(<FormulaBar {...mockProps} />);
    expect(screen.getByText('A1')).toBeInTheDocument();
  });

  it('handles entering and submitting a formula', () => {
    render(<FormulaBar {...mockProps} />);
    const input = screen.getByRole('textbox');
    userEvent.type(input, '=SUM(A1:A5)');
    fireEvent.keyDown(input, { key: 'Enter' });
    expect(mockProps.onFormulaChange).toHaveBeenCalledWith('=SUM(A1:A5)');
  });

  it('handles formula validation and error display', () => {
    render(<FormulaBar {...mockProps} />);
    const input = screen.getByRole('textbox');
    userEvent.type(input, '=INVALID(A1)');
    fireEvent.keyDown(input, { key: 'Enter' });
    expect(screen.getByText('Invalid formula')).toBeInTheDocument();
  });
});

test('Component interactions', () => {
  render(
    <AppContext.Provider value={{ workbook: { sheets: [{ name: 'Sheet1', cells: [] }] } }}>
      <App />
    </AppContext.Provider>
  );

  // Simulate entering data
  const cell = screen.getByTestId('cell-A1');
  fireEvent.doubleClick(cell);
  userEvent.type(cell, '42');
  fireEvent.blur(cell);

  // Verify formula bar update
  expect(screen.getByRole('textbox')).toHaveValue('42');

  // Apply formatting
  fireEvent.click(screen.getByText('Bold'));

  // Use a formula
  const formulaInput = screen.getByRole('textbox');
  userEvent.clear(formulaInput);
  userEvent.type(formulaInput, '=SUM(A1:A5)');
  fireEvent.keyDown(formulaInput, { key: 'Enter' });

  // Verify worksheet update
  expect(screen.getByTestId('cell-A1')).toHaveTextContent('42');
  expect(screen.getByTestId('cell-A6')).toHaveTextContent('42'); // Assuming A6 is where the SUM result appears
});

// Human tasks:
// TODO: Implement more comprehensive test cases for complex UI interactions
// TODO: Add tests for error handling and edge cases in each component
// TODO: Implement performance tests for rendering large datasets in WorksheetGrid
// TODO: Add tests for accessibility compliance (e.g., keyboard navigation, screen reader compatibility)
// TODO: Implement tests for responsive design and different screen sizes
// TODO: Add tests for internationalization and localization features
// TODO: Implement tests for real-time collaboration features if applicable