import React, { useState, useEffect, useContext, useCallback, useMemo } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper } from '@material-ui/core';
import { AppContext } from '../context/AppContext';
import { ExcelService } from '../services/ExcelService';
import { useVirtualization } from '../hooks/useVirtualization';
import { formatCellValue } from '../utils/cellFormatting';
import '../styles/WorksheetGrid.css';

const WorksheetGrid: React.FC = () => {
  const { workbook, updateWorkbook } = useContext(AppContext);
  const [selectedCell, setSelectedCell] = useState<{ row: number; col: number } | null>(null);
  const [editingCell, setEditingCell] = useState<{ row: number; col: number } | null>(null);

  const { visibleRange, containerRef } = useVirtualization({
    totalRows: workbook.activeSheet.rowCount,
    totalColumns: workbook.activeSheet.columnCount,
    rowHeight: 25,
    columnWidth: 100,
  });

  useEffect(() => {
    // Update grid when workbook data changes
    // This could be optimized to only update changed cells
  }, [workbook]);

  const handleCellSelect = useCallback((row: number, col: number) => {
    setSelectedCell({ row, col });
    setEditingCell(null);
  }, []);

  const handleCellEdit = useCallback((row: number, col: number, value: string) => {
    ExcelService.updateCell(workbook.id, workbook.activeSheet.id, row, col, value);
    updateWorkbook(workbook);
    setEditingCell(null);
  }, [workbook, updateWorkbook]);

  const handleKeyDown = useCallback((event: React.KeyboardEvent) => {
    // Implement keyboard navigation logic here
  }, []);

  const visibleCells = useMemo(() => {
    // Calculate visible cells based on visibleRange
    // This is a placeholder and should be implemented based on your data structure
    return [];
  }, [visibleRange, workbook]);

  return (
    <TableContainer component={Paper} ref={containerRef}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell />
            {visibleRange.columns.map(col => (
              <ColumnHeader key={col} column={col} />
            ))}
          </TableRow>
        </TableHead>
        <TableBody>
          {visibleRange.rows.map(row => (
            <TableRow key={row}>
              <RowHeader row={row} />
              {visibleRange.columns.map(col => (
                <Cell
                  key={`${row}-${col}`}
                  cellData={workbook.activeSheet.cells[row][col]}
                  isSelected={selectedCell?.row === row && selectedCell?.col === col}
                  isEditing={editingCell?.row === row && editingCell?.col === col}
                  onSelect={() => handleCellSelect(row, col)}
                  onEdit={(value) => handleCellEdit(row, col, value)}
                />
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
};

const Cell: React.FC<{
  cellData: any;
  isSelected: boolean;
  isEditing: boolean;
  onSelect: () => void;
  onEdit: (value: string) => void;
}> = ({ cellData, isSelected, isEditing, onSelect, onEdit }) => {
  const [editValue, setEditValue] = useState(cellData.value);

  const handleDoubleClick = () => {
    setEditValue(cellData.value);
    onSelect();
  };

  const handleBlur = () => {
    onEdit(editValue);
  };

  if (isEditing) {
    return (
      <TableCell>
        <input
          value={editValue}
          onChange={(e) => setEditValue(e.target.value)}
          onBlur={handleBlur}
          autoFocus
        />
      </TableCell>
    );
  }

  return (
    <TableCell
      onClick={onSelect}
      onDoubleClick={handleDoubleClick}
      style={{ backgroundColor: isSelected ? '#e6f2ff' : 'inherit' }}
    >
      {formatCellValue(cellData)}
    </TableCell>
  );
};

const ColumnHeader: React.FC<{ column: string }> = ({ column }) => {
  return <TableCell>{column}</TableCell>;
};

const RowHeader: React.FC<{ row: number }> = ({ row }) => {
  return <TableCell>{row + 1}</TableCell>;
};

export default WorksheetGrid;