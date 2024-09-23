import { Cell } from './Cell';
import { CellRange } from './CellRange';
import { generateGuid } from '../utils/guid';
import { cellReferenceToIndices, indicesToCellReference } from '../utils/cellReference';

export class Worksheet {
    id: string;
    name: string;
    cells: Cell[][];
    rowCount: number;
    columnCount: number;
    namedRanges: Map<string, CellRange>;

    constructor(name: string, rowCount: number = 1000, columnCount: number = 26) {
        this.id = generateGuid();
        this.name = name;
        this.rowCount = rowCount;
        this.columnCount = columnCount;
        this.cells = Array(rowCount).fill(null).map(() => 
            Array(columnCount).fill(null).map(() => new Cell())
        );
        this.namedRanges = new Map<string, CellRange>();
    }

    getCell(rowIndex: number, columnIndex: number): Cell | undefined {
        if (rowIndex >= 0 && rowIndex < this.rowCount && columnIndex >= 0 && columnIndex < this.columnCount) {
            return this.cells[rowIndex][columnIndex];
        }
        return undefined;
    }

    getCellByReference(cellReference: string): Cell | undefined {
        const [rowIndex, columnIndex] = cellReferenceToIndices(cellReference);
        return this.getCell(rowIndex, columnIndex);
    }

    setCellValue(rowIndex: number, columnIndex: number, value: any): void {
        const cell = this.getCell(rowIndex, columnIndex);
        if (cell) {
            cell.setValue(value);
        }
    }

    addNamedRange(name: string, range: CellRange): void {
        this.namedRanges.set(name, range);
    }

    getNamedRange(name: string): CellRange | undefined {
        return this.namedRanges.get(name);
    }

    toJSON(): object {
        return {
            id: this.id,
            name: this.name,
            rowCount: this.rowCount,
            columnCount: this.columnCount,
            cells: this.cells.map(row => row.map(cell => cell.toJSON())),
            namedRanges: Array.from(this.namedRanges.entries()).reduce((obj, [key, value]) => {
                obj[key] = value.toJSON();
                return obj;
            }, {} as { [key: string]: object })
        };
    }

    static fromJSON(json: any): Worksheet {
        const worksheet = new Worksheet(json.name, json.rowCount, json.columnCount);
        worksheet.id = json.id;
        worksheet.cells = json.cells.map((row: any[]) => row.map(cellData => Cell.fromJSON(cellData)));
        worksheet.namedRanges = new Map(Object.entries(json.namedRanges).map(
            ([key, value]) => [key, CellRange.fromJSON(value as object)]
        ));
        return worksheet;
    }
}

// Human tasks:
// TODO: Implement methods for inserting and deleting rows and columns
// TODO: Add support for worksheet-level formulas or data validation
// TODO: Implement methods for merging and unmerging cells
// TODO: Add functionality for handling worksheet-level styles (e.g., default font, colors)
// TODO: Implement methods for sorting and filtering data within the worksheet
// TODO: Add support for conditional formatting rules
// TODO: Implement undo/redo functionality at the Worksheet level