import { Worksheet } from './Worksheet';
import { Style } from './Style';
import { generateGuid } from '../utils/guid';

export class Workbook {
    id: string;
    name: string;
    worksheets: Worksheet[];
    styles: Map<string, Style>;
    createdAt: Date;
    modifiedAt: Date;
    author: string;

    constructor(name: string, author: string) {
        this.id = generateGuid();
        this.name = name;
        this.author = author;
        this.worksheets = [];
        this.styles = new Map<string, Style>();
        this.createdAt = new Date();
        this.modifiedAt = new Date();
    }

    addWorksheet(worksheet: Worksheet): void {
        this.worksheets.push(worksheet);
        this.modifiedAt = new Date();
    }

    removeWorksheet(worksheetId: string): boolean {
        const index = this.worksheets.findIndex(ws => ws.id === worksheetId);
        if (index !== -1) {
            this.worksheets.splice(index, 1);
            this.modifiedAt = new Date();
            return true;
        }
        return false;
    }

    getWorksheetById(worksheetId: string): Worksheet | undefined {
        return this.worksheets.find(ws => ws.id === worksheetId);
    }

    addStyle(styleId: string, style: Style): void {
        this.styles.set(styleId, style);
        this.modifiedAt = new Date();
    }

    getStyle(styleId: string): Style | undefined {
        return this.styles.get(styleId);
    }

    toJSON(): object {
        return {
            id: this.id,
            name: this.name,
            author: this.author,
            worksheets: this.worksheets.map(ws => ws.toJSON()),
            styles: Array.from(this.styles.entries()).reduce((obj, [key, value]) => {
                obj[key] = value.toJSON();
                return obj;
            }, {}),
            createdAt: this.createdAt.toISOString(),
            modifiedAt: this.modifiedAt.toISOString()
        };
    }

    static fromJSON(json: any): Workbook {
        const workbook = new Workbook(json.name, json.author);
        workbook.id = json.id;
        workbook.worksheets = json.worksheets.map(Worksheet.fromJSON);
        workbook.styles = new Map(Object.entries(json.styles).map(([key, value]) => [key, Style.fromJSON(value)]));
        workbook.createdAt = new Date(json.createdAt);
        workbook.modifiedAt = new Date(json.modifiedAt);
        return workbook;
    }
}