import { DateTime, Duration } from 'luxon';

const EXCEL_EPOCH = DateTime.fromObject({ year: 1899, month: 12, day: 30 });
const EXCEL_LEAP_YEAR_BUG_THRESHOLD = DateTime.fromObject({ year: 1900, month: 3, day: 1 });

export function excelDateToDateTime(serialNumber: number): DateTime {
    let dateTime = EXCEL_EPOCH.plus({ days: serialNumber });

    // Handle Excel's leap year bug
    if (dateTime < EXCEL_LEAP_YEAR_BUG_THRESHOLD) {
        dateTime = dateTime.plus({ days: 1 });
    }

    return dateTime;
}

export function dateTimeToExcelDate(dateTime: DateTime): number {
    let diff = dateTime.diff(EXCEL_EPOCH, 'days').days;

    // Handle Excel's leap year bug
    if (dateTime < EXCEL_LEAP_YEAR_BUG_THRESHOLD) {
        diff -= 1;
    }

    return Math.round(diff);
}

const excelToLuxonFormatMap: { [key: string]: string } = {
    'd': 'dd',
    'dd': 'dd',
    'm': 'MM',
    'mm': 'MM',
    'mmm': 'MMM',
    'mmmm': 'MMMM',
    'yy': 'yy',
    'yyyy': 'yyyy',
    'h': 'h',
    'hh': 'hh',
    'm': 'm',
    'mm': 'mm',
    's': 's',
    'ss': 'ss',
    'AM/PM': 'a'
};

export function formatDate(dateTime: DateTime, format: string): string {
    let luxonFormat = format;
    for (const [excelCode, luxonCode] of Object.entries(excelToLuxonFormatMap)) {
        luxonFormat = luxonFormat.replace(new RegExp(excelCode, 'g'), luxonCode);
    }
    return dateTime.toFormat(luxonFormat);
}

export function addDuration(dateTime: DateTime, duration: Duration): DateTime {
    return dateTime.plus(duration);
}

export function dateDiff(startDate: DateTime, endDate: DateTime, unit: string): number {
    const diff = endDate.diff(startDate);

    switch (unit.toLowerCase()) {
        case 'y':
        case 'years':
            return diff.years;
        case 'm':
        case 'months':
            return diff.months;
        case 'd':
        case 'days':
            return diff.days;
        case 'ym':
            return diff.months % 12;
        case 'yd':
            return diff.days % 365;
        default:
            throw new Error(`Unsupported unit: ${unit}`);
    }
}