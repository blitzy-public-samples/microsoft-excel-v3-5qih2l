import { Cell } from './Cell';
import { Worksheet } from './Worksheet';
import { cellReferenceToIndices, indicesToCellReference } from '../utils/cellReference';
import { Style } from './Style';

export class Range {
    constructor(
        public worksheet: Worksheet,
        public startRow: number,
        public startColumn: number,
        public endRow: number,
        public endColumn: number
    ) {
        // Ensure that start indices are not greater than end indices
        this.startRow = Math.min(startRow, endRow);
        this.endRow = Math.max(startRow, endRow);
        this.startColumn = Math.min(startColumn, endColumn);
        this.endColumn = Math.max(startColumn, endColumn);
    }

    getCells(): Cell[][] {
        const cells: Cell[][] = [];
        for (let row = this.startRow; row <= this.endRow; row++) {
            const rowCells: Cell[] = [];
            for (let col = this.startColumn; col <= this.endColumn; col++) {
                rowCells.push(this.worksheet.getCell(row, col));
            }
            cells.push(rowCells);
        }
        return cells;
    }

    getCell(relativeRow: number, relativeColumn: number): Cell | undefined {
        const absoluteRow = this.startRow + relativeRow;
        const absoluteColumn = this.startColumn + relativeColumn;

        if (absoluteRow >= this.startRow && absoluteRow <= this.endRow &&
            absoluteColumn >= this.startColumn && absoluteColumn <= this.endColumn) {
            return this.worksheet.getCell(absoluteRow, absoluteColumn);
        }

        return undefined;
    }

    setValues(values: any[][]): void {
        const rangeRows = this.endRow - this.startRow + 1;
        const rangeColumns = this.endColumn - this.startColumn + 1;

        for (let i = 0; i < Math.min(rangeRows, values.length); i++) {
            for (let j = 0; j < Math.min(rangeColumns, values[i].length); j++) {
                const cell = this.worksheet.getCell(this.startRow + i, this.startColumn + j);
                cell.setValue(values[i][j]);
            }
        }
    }

    clear(): void {
        for (let row = this.startRow; row <= this.endRow; row++) {
            for (let col = this.startColumn; col <= this.endColumn; col++) {
                const cell = this.worksheet.getCell(row, col);
                cell.setValue(null);
                cell.setFormula('');
            }
        }
    }

    applyStyle(style: Style): void {
        for (let row = this.startRow; row <= this.endRow; row++) {
            for (let col = this.startColumn; col <= this.endColumn; col++) {
                const cell = this.worksheet.getCell(row, col);
                cell.applyStyle(style);
            }
        }
    }

    toA1Notation(): string {
        const startRef = indicesToCellReference(this.startRow, this.startColumn);
        const endRef = indicesToCellReference(this.endRow, this.endColumn);
        return `${startRef}:${endRef}`;
    }

    static fromA1Notation(worksheet: Worksheet, a1Notation: string): Range {
        const [startRef, endRef] = a1Notation.split(':');
        const [startRow, startColumn] = cellReferenceToIndices(startRef);
        const [endRow, endColumn] = cellReferenceToIndices(endRef);
        return new Range(worksheet, startRow, startColumn, endRow, endColumn);
    }
}