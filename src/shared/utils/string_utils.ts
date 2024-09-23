/**
 * Utility functions for string manipulation and formatting in Excel formulas and cell operations.
 */

/**
 * Trims whitespace from the beginning and end of a string
 * @param input The input string to trim
 * @returns The trimmed string
 */
export function trimString(input: string): string {
  return input.trim();
}

/**
 * Pads a string to a specified length with a given character
 * @param input The input string to pad
 * @param length The desired length of the padded string
 * @param padChar The character to use for padding (default: space)
 * @returns The padded string
 */
export function padString(input: string, length: number, padChar: string = ' '): string {
  if (input.length >= length) {
    return input;
  }
  const paddingLength = length - input.length;
  const padding = padChar.repeat(paddingLength);
  return padding + input;
}

/**
 * Converts a string to uppercase
 * @param input The input string to convert
 * @returns The uppercase string
 */
export function toUpperCase(input: string): string {
  return input.toUpperCase();
}

/**
 * Converts a string to lowercase
 * @param input The input string to convert
 * @returns The lowercase string
 */
export function toLowerCase(input: string): string {
  return input.toLowerCase();
}

/**
 * Concatenates an array of strings with an optional delimiter
 * @param strings The array of strings to concatenate
 * @param delimiter The delimiter to use between strings (default: empty string)
 * @returns The concatenated string
 */
export function concatenateStrings(strings: string[], delimiter: string = ''): string {
  return strings.join(delimiter);
}

/**
 * Extracts a substring from a given string
 * @param input The input string
 * @param startIndex The starting index of the substring
 * @param length The length of the substring (optional)
 * @returns The extracted substring
 */
export function extractSubstring(input: string, startIndex: number, length?: number): string {
  if (length === undefined) {
    return input.substring(startIndex);
  }
  return input.substring(startIndex, startIndex + length);
}

/**
 * Replaces all occurrences of a substring in a string
 * @param input The input string
 * @param search The substring to search for
 * @param replace The string to replace the search substring with
 * @returns The string with replacements
 */
export function replaceSubstring(input: string, search: string, replace: string): string {
  const regex = new RegExp(search, 'g');
  return input.replace(regex, replace);
}