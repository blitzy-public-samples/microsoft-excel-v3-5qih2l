import { Color, parseColor } from '../utils/colorUtils';

class Style {
    backgroundColor: Color | null = null;
    fontColor: Color | null = null;
    fontFamily: string | null = null;
    fontSize: number | null = null;
    bold: boolean = false;
    italic: boolean = false;
    underline: boolean = false;
    horizontalAlignment: string | null = null;
    verticalAlignment: string | null = null;
    numberFormat: string | null = null;
    borderTop: string | null = null;
    borderRight: string | null = null;
    borderBottom: string | null = null;
    borderLeft: string | null = null;

    constructor() {
        // All properties are initialized to their default values in the property declarations
    }

    setBackgroundColor(color: string | Color): void {
        if (typeof color === 'string') {
            this.backgroundColor = parseColor(color);
        } else {
            this.backgroundColor = color;
        }
    }

    setFontColor(color: string | Color): void {
        if (typeof color === 'string') {
            this.fontColor = parseColor(color);
        } else {
            this.fontColor = color;
        }
    }

    setFont(fontFamily: string, fontSize: number): void {
        this.fontFamily = fontFamily;
        this.fontSize = fontSize;
    }

    toggleBold(): void {
        this.bold = !this.bold;
    }

    toggleItalic(): void {
        this.italic = !this.italic;
    }

    toggleUnderline(): void {
        this.underline = !this.underline;
    }

    setAlignment(horizontal: string, vertical: string): void {
        this.horizontalAlignment = horizontal;
        this.verticalAlignment = vertical;
    }

    setNumberFormat(format: string): void {
        this.numberFormat = format;
    }

    setBorders(borderStyle: string): void {
        this.borderTop = borderStyle;
        this.borderRight = borderStyle;
        this.borderBottom = borderStyle;
        this.borderLeft = borderStyle;
    }

    clone(): Style {
        const newStyle = new Style();
        Object.assign(newStyle, this);
        return newStyle;
    }

    toJSON(): object {
        return {
            backgroundColor: this.backgroundColor ? this.backgroundColor.toString() : null,
            fontColor: this.fontColor ? this.fontColor.toString() : null,
            fontFamily: this.fontFamily,
            fontSize: this.fontSize,
            bold: this.bold,
            italic: this.italic,
            underline: this.underline,
            horizontalAlignment: this.horizontalAlignment,
            verticalAlignment: this.verticalAlignment,
            numberFormat: this.numberFormat,
            borderTop: this.borderTop,
            borderRight: this.borderRight,
            borderBottom: this.borderBottom,
            borderLeft: this.borderLeft
        };
    }

    static fromJSON(json: any): Style {
        const style = new Style();
        Object.keys(json).forEach(key => {
            if (key === 'backgroundColor' || key === 'fontColor') {
                if (json[key]) {
                    (style as any)[key] = parseColor(json[key]);
                }
            } else {
                (style as any)[key] = json[key];
            }
        });
        return style;
    }
}

export default Style;