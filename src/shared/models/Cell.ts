import { Style } from './Style';
import { evaluateFormula } from '../utils/formulaEvaluator';

export class Cell {
    private value: any;
    private formula: string;
    private style: Style;
    private isLocked: boolean;

    constructor(value: any = null, style: Style = new Style(), isLocked: boolean = false) {
        this.value = value;
        this.formula = '';
        this.style = style;
        this.isLocked = isLocked;
    }

    setValue(newValue: any): void {
        this.value = newValue;
        this.formula = '';
    }

    setFormula(newFormula: string): void {
        this.formula = newFormula;
        this.value = evaluateFormula(newFormula);
    }

    evaluate(): any {
        if (this.formula) {
            this.value = evaluateFormula(this.formula);
        }
        return this.value;
    }

    applyStyle(newStyle: Style): void {
        this.style = { ...this.style, ...newStyle };
    }

    lock(): void {
        this.isLocked = true;
    }

    unlock(): void {
        this.isLocked = false;
    }

    toJSON(): object {
        return {
            value: this.value,
            formula: this.formula,
            style: this.style.toJSON(),
            isLocked: this.isLocked
        };
    }

    static fromJSON(json: object): Cell {
        const cell = new Cell();
        cell.value = json['value'];
        cell.formula = json['formula'];
        cell.style = Style.fromJSON(json['style']);
        cell.isLocked = json['isLocked'];
        return cell;
    }
}

// Human tasks:
// TODO: Implement data validation for cell values
// TODO: Add support for cell comments
// TODO: Implement cell formatting options (e.g., number formats, date formats)
// TODO: Add support for hyperlinks within cells
// TODO: Implement cell history tracking for undo/redo functionality
// TODO: Add support for conditional formatting at the cell level
// TODO: Implement error handling for formula evaluation failures