import { test, expect, Page } from '@playwright/test';
import { ExcelService } from '../src/services/ExcelService';
import { Workbook } from '../src/models/Workbook';
import { Worksheet } from '../src/models/Worksheet';
import { Cell } from '../src/models/Cell';
import { setupTestEnvironment, teardownTestEnvironment } from '../src/utils/test_helpers';

test.describe('Excel Web App E2E Tests', () => {
  let page: Page;

  test.beforeAll(async () => {
    await setupTestEnvironment();
  });

  test.afterAll(async () => {
    await teardownTestEnvironment();
  });

  test.beforeEach(async ({ browser }) => {
    page = await browser.newPage();
    await page.goto('https://excel.example.com');
  });

  test.afterEach(async () => {
    await page.close();
  });

  test('Create new workbook and add data', async () => {
    await page.click('button:has-text("New Workbook")');
    await expect(page).toHaveTitle(/Untitled Workbook/);

    await page.click('[data-cell="A1"]');
    await page.keyboard.type('Hello');
    await page.click('[data-cell="B1"]');
    await page.keyboard.type('World');

    const cellA1Text = await page.textContent('[data-cell="A1"]');
    const cellB1Text = await page.textContent('[data-cell="B1"]');
    expect(cellA1Text).toBe('Hello');
    expect(cellB1Text).toBe('World');
  });

  test('Formula calculation', async () => {
    await page.click('button:has-text("New Workbook")');

    await page.click('[data-cell="A1"]');
    await page.keyboard.type('10');
    await page.click('[data-cell="A2"]');
    await page.keyboard.type('20');
    await page.click('[data-cell="A3"]');
    await page.keyboard.type('30');

    await page.click('[data-cell="A4"]');
    await page.keyboard.type('=SUM(A1:A3)');
    await page.keyboard.press('Enter');

    const cellA4Text = await page.textContent('[data-cell="A4"]');
    expect(cellA4Text).toBe('60');

    await page.click('[data-cell="A1"]');
    await page.keyboard.type('15');
    await page.keyboard.press('Enter');

    const updatedCellA4Text = await page.textContent('[data-cell="A4"]');
    expect(updatedCellA4Text).toBe('65');
  });

  test('Save and load workbook', async () => {
    await page.click('button:has-text("New Workbook")');

    await page.click('[data-cell="A1"]');
    await page.keyboard.type('Test Data');

    await page.click('button:has-text("Save")');
    await expect(page.locator('.save-confirmation')).toBeVisible();

    await page.click('button:has-text("Close")');
    await page.click('button:has-text("Open")');
    await page.click('text=Test Data.xlsx');

    const cellA1Text = await page.textContent('[data-cell="A1"]');
    expect(cellA1Text).toBe('Test Data');
  });

  test('Cell formatting', async () => {
    await page.click('button:has-text("New Workbook")');

    await page.click('[data-cell="A1"]');
    await page.click('button:has-text("Bold")');

    await page.click('[data-cell="B1"]');
    await page.click('[data-cell="B2"]');
    await page.keyboard.down('Shift');
    await page.click('[data-cell="C3"]');
    await page.keyboard.up('Shift');
    await page.click('button:has-text("Fill Color")');
    await page.click('.color-yellow');

    await page.click('[data-row-header="2"]');
    await page.click('button:has-text("Font Size")');
    await page.click('text=14');

    const cellA1Style = await page.$eval('[data-cell="A1"]', el => window.getComputedStyle(el).fontWeight);
    expect(cellA1Style).toBe('700');

    const cellB2Style = await page.$eval('[data-cell="B2"]', el => window.getComputedStyle(el).backgroundColor);
    expect(cellB2Style).toBe('rgb(255, 255, 0)');

    const row2Style = await page.$eval('[data-row="2"]', el => window.getComputedStyle(el).fontSize);
    expect(row2Style).toBe('14px');
  });

  test('Collaboration features', async ({ browser }) => {
    const user1Page = await browser.newPage();
    const user2Page = await browser.newPage();

    await user1Page.goto('https://excel.example.com');
    await user1Page.click('button:has-text("New Workbook")');
    const workbookUrl = user1Page.url();

    await user2Page.goto(workbookUrl);

    await user1Page.click('[data-cell="A1"]');
    await user1Page.keyboard.type('User 1');

    await user2Page.click('[data-cell="B1"]');
    await user2Page.keyboard.type('User 2');

    await expect(user1Page.locator('[data-cell="B1"]')).toHaveText('User 2');
    await expect(user2Page.locator('[data-cell="A1"]')).toHaveText('User 1');

    await user1Page.click('[data-cell="C1"]');
    await user2Page.click('[data-cell="C1"]');

    await user1Page.keyboard.type('Conflict');
    await user2Page.keyboard.type('Resolution');

    // Assuming the last edit wins in conflict resolution
    await expect(user1Page.locator('[data-cell="C1"]')).toHaveText('Resolution');
    await expect(user2Page.locator('[data-cell="C1"]')).toHaveText('Resolution');

    await user1Page.close();
    await user2Page.close();
  });
});