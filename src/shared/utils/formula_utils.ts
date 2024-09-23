import { Cell } from '../models/Cell';
import { Worksheet } from '../models/Worksheet';
import { Workbook } from '../models/Workbook';
import { cellReferenceToIndices } from './cell_reference';

export function tokenizeFormula(formula: string): string[] {
    const tokens: string[] = [];
    let currentToken = '';
    let inStringLiteral = false;

    for (let i = 0; i < formula.length; i++) {
        const char = formula[i];

        if (inStringLiteral) {
            if (char === '"') {
                inStringLiteral = false;
                tokens.push(currentToken + char);
                currentToken = '';
            } else {
                currentToken += char;
            }
        } else if (char === '"') {
            inStringLiteral = true;
            currentToken += char;
        } else if ('+-*/^()=><&|,'.includes(char)) {
            if (currentToken) {
                tokens.push(currentToken);
                currentToken = '';
            }
            tokens.push(char);
        } else if (char === ' ') {
            if (currentToken) {
                tokens.push(currentToken);
                currentToken = '';
            }
        } else {
            currentToken += char;
        }
    }

    if (currentToken) {
        tokens.push(currentToken);
    }

    return tokens;
}

export function parseFormula(tokens: string[]): object {
    // This is a simplified implementation. A full parser would be more complex.
    const root = { type: 'root', children: [] };
    let current = root;
    const stack = [root];

    for (const token of tokens) {
        if (token === '(') {
            const newNode = { type: 'group', children: [] };
            current.children.push(newNode);
            stack.push(newNode);
            current = newNode;
        } else if (token === ')') {
            stack.pop();
            current = stack[stack.length - 1];
        } else if ('+-*/^'.includes(token)) {
            const newNode = { type: 'operator', value: token, children: [] };
            current.children.push(newNode);
        } else if (token.match(/^[A-Z]+[0-9]+$/)) {
            current.children.push({ type: 'cell_reference', value: token });
        } else if (token.match(/^[A-Z]+[0-9]+:[A-Z]+[0-9]+$/)) {
            current.children.push({ type: 'cell_range', value: token });
        } else if (token.match(/^[A-Z]+$/)) {
            const newNode = { type: 'function', value: token, children: [] };
            current.children.push(newNode);
            stack.push(newNode);
            current = newNode;
        } else {
            current.children.push({ type: 'literal', value: token });
        }
    }

    return root;
}

export function evaluateFormula(syntaxTree: object, worksheet: Worksheet, workbook: Workbook): any {
    function evaluate(node: any): any {
        switch (node.type) {
            case 'root':
            case 'group':
                return evaluate(node.children[0]);
            case 'operator':
                const left = evaluate(node.children[0]);
                const right = evaluate(node.children[1]);
                switch (node.value) {
                    case '+': return left + right;
                    case '-': return left - right;
                    case '*': return left * right;
                    case '/': return right !== 0 ? left / right : '#DIV/0!';
                    case '^': return Math.pow(left, right);
                    default: throw new Error(`Unknown operator: ${node.value}`);
                }
            case 'cell_reference':
                const [row, col] = cellReferenceToIndices(node.value);
                return worksheet.getCellValue(row, col);
            case 'cell_range':
                // Simplified implementation, doesn't handle multi-dimensional ranges
                const [startRef, endRef] = node.value.split(':');
                const [startRow, startCol] = cellReferenceToIndices(startRef);
                const [endRow, endCol] = cellReferenceToIndices(endRef);
                const range = [];
                for (let r = startRow; r <= endRow; r++) {
                    for (let c = startCol; c <= endCol; c++) {
                        range.push(worksheet.getCellValue(r, c));
                    }
                }
                return range;
            case 'function':
                const args = node.children.map(evaluate);
                switch (node.value) {
                    case 'SUM': return args.flat().reduce((a: number, b: number) => a + b, 0);
                    case 'AVERAGE': {
                        const flatArgs = args.flat();
                        return flatArgs.reduce((a: number, b: number) => a + b, 0) / flatArgs.length;
                    }
                    // Add more functions as needed
                    default: throw new Error(`Unknown function: ${node.value}`);
                }
            case 'literal':
                return isNaN(Number(node.value)) ? node.value : Number(node.value);
            default:
                throw new Error(`Unknown node type: ${node.type}`);
        }
    }

    return evaluate(syntaxTree);
}

export function getCellDependencies(formula: string): string[] {
    const tokens = tokenizeFormula(formula);
    const dependencies: Set<string> = new Set();

    for (const token of tokens) {
        if (token.match(/^[A-Z]+[0-9]+$/)) {
            dependencies.add(token);
        } else if (token.match(/^[A-Z]+[0-9]+:[A-Z]+[0-9]+$/)) {
            const [start, end] = token.split(':');
            const [startRow, startCol] = cellReferenceToIndices(start);
            const [endRow, endCol] = cellReferenceToIndices(end);
            for (let r = startRow; r <= endRow; r++) {
                for (let c = startCol; c <= endCol; c++) {
                    dependencies.add(`${String.fromCharCode(65 + c)}${r + 1}`);
                }
            }
        }
    }

    return Array.from(dependencies);
}

export function updateFormula(formula: string, operation: string, row: number, column: number, count: number): string {
    const tokens = tokenizeFormula(formula);
    const updatedTokens = tokens.map(token => {
        if (token.match(/^[A-Z]+[0-9]+$/)) {
            const [r, c] = cellReferenceToIndices(token);
            let newR = r, newC = c;
            if (operation === 'insertRow' && r >= row) newR += count;
            if (operation === 'deleteRow' && r >= row) newR = Math.max(row, r - count);
            if (operation === 'insertColumn' && c >= column) newC += count;
            if (operation === 'deleteColumn' && c >= column) newC = Math.max(column, c - count);
            return `${String.fromCharCode(65 + newC)}${newR + 1}`;
        } else if (token.match(/^[A-Z]+[0-9]+:[A-Z]+[0-9]+$/)) {
            const [start, end] = token.split(':');
            const updatedStart = updateFormula(start, operation, row, column, count);
            const updatedEnd = updateFormula(end, operation, row, column, count);
            return `${updatedStart}:${updatedEnd}`;
        }
        return token;
    });

    return updatedTokens.join('');
}