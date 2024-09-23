import request from 'supertest';
import express, { Express } from 'express';
import { workbooksRouter } from '../src/api/workbooks';
import { worksheetsRouter } from '../src/api/worksheets';
import { cellsRouter } from '../src/api/cells';
import { collaborationRouter } from '../src/api/collaboration';
import { formulasRouter } from '../src/api/formulas';
import { WorkbookService } from '../src/services/WorkbookService';
import { WorksheetService } from '../src/services/WorksheetService';
import { CellService } from '../src/services/CellService';
import { CollaborationService } from '../src/services/CollaborationService';
import { FormulaService } from '../src/services/FormulaService';
import { Workbook } from '../src/models/Workbook';
import { Worksheet } from '../src/models/Worksheet';
import { Cell } from '../src/models/Cell';

jest.mock('../src/services/WorkbookService');
jest.mock('../src/services/WorksheetService');
jest.mock('../src/services/CellService');
jest.mock('../src/services/CollaborationService');
jest.mock('../src/services/FormulaService');

describe('Workbooks API', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use('/api/workbooks', workbooksRouter);
  });

  it('should get all workbooks', async () => {
    const mockWorkbooks = [new Workbook(), new Workbook()];
    (WorkbookService.getWorkbooks as jest.Mock).mockResolvedValue(mockWorkbooks);

    const response = await request(app).get('/api/workbooks');
    expect(response.status).toBe(200);
    expect(response.body).toHaveLength(2);
  });

  it('should create a new workbook', async () => {
    const mockWorkbook = new Workbook();
    (WorkbookService.createWorkbook as jest.Mock).mockResolvedValue(mockWorkbook);

    const response = await request(app)
      .post('/api/workbooks')
      .send({ name: 'New Workbook' });
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
  });

  it('should get a specific workbook', async () => {
    const mockWorkbook = new Workbook();
    (WorkbookService.getWorkbook as jest.Mock).mockResolvedValue(mockWorkbook);

    const response = await request(app).get('/api/workbooks/1');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('id');
  });

  it('should update a workbook', async () => {
    const mockWorkbook = new Workbook();
    (WorkbookService.updateWorkbook as jest.Mock).mockResolvedValue(mockWorkbook);

    const response = await request(app)
      .put('/api/workbooks/1')
      .send({ name: 'Updated Workbook' });
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('name', 'Updated Workbook');
  });

  it('should delete a workbook', async () => {
    (WorkbookService.deleteWorkbook as jest.Mock).mockResolvedValue(true);

    const response = await request(app).delete('/api/workbooks/1');
    expect(response.status).toBe(204);
  });
});

describe('Worksheets API', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use('/api/workbooks/:workbookId/worksheets', worksheetsRouter);
  });

  it('should get all worksheets for a workbook', async () => {
    const mockWorksheets = [new Worksheet(), new Worksheet()];
    (WorksheetService.getWorksheets as jest.Mock).mockResolvedValue(mockWorksheets);

    const response = await request(app).get('/api/workbooks/1/worksheets');
    expect(response.status).toBe(200);
    expect(response.body).toHaveLength(2);
  });

  it('should create a new worksheet', async () => {
    const mockWorksheet = new Worksheet();
    (WorksheetService.createWorksheet as jest.Mock).mockResolvedValue(mockWorksheet);

    const response = await request(app)
      .post('/api/workbooks/1/worksheets')
      .send({ name: 'New Sheet' });
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
  });

  it('should get a specific worksheet', async () => {
    const mockWorksheet = new Worksheet();
    (WorksheetService.getWorksheet as jest.Mock).mockResolvedValue(mockWorksheet);

    const response = await request(app).get('/api/workbooks/1/worksheets/1');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('id');
  });

  it('should update a worksheet', async () => {
    const mockWorksheet = new Worksheet();
    (WorksheetService.updateWorksheet as jest.Mock).mockResolvedValue(mockWorksheet);

    const response = await request(app)
      .put('/api/workbooks/1/worksheets/1')
      .send({ name: 'Updated Sheet' });
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('name', 'Updated Sheet');
  });

  it('should delete a worksheet', async () => {
    (WorksheetService.deleteWorksheet as jest.Mock).mockResolvedValue(true);

    const response = await request(app).delete('/api/workbooks/1/worksheets/1');
    expect(response.status).toBe(204);
  });
});

describe('Cells API', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use('/api/workbooks/:workbookId/worksheets/:worksheetId/cells', cellsRouter);
  });

  it('should get a specific cell', async () => {
    const mockCell = new Cell();
    (CellService.getCell as jest.Mock).mockResolvedValue(mockCell);

    const response = await request(app).get('/api/workbooks/1/worksheets/1/cells/A1');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('value');
  });

  it('should update a cell', async () => {
    const mockCell = new Cell();
    (CellService.updateCell as jest.Mock).mockResolvedValue(mockCell);

    const response = await request(app)
      .put('/api/workbooks/1/worksheets/1/cells/A1')
      .send({ value: 'New Value' });
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('value', 'New Value');
  });

  it('should get a range of cells', async () => {
    const mockCells = [new Cell(), new Cell()];
    (CellService.getCellRange as jest.Mock).mockResolvedValue(mockCells);

    const response = await request(app).get('/api/workbooks/1/worksheets/1/cells?range=A1:B2');
    expect(response.status).toBe(200);
    expect(response.body).toHaveLength(2);
  });

  it('should update a range of cells', async () => {
    const mockCells = [new Cell(), new Cell()];
    (CellService.updateCellRange as jest.Mock).mockResolvedValue(mockCells);

    const response = await request(app)
      .put('/api/workbooks/1/worksheets/1/cells')
      .send({ range: 'A1:B2', values: [['Value1', 'Value2'], ['Value3', 'Value4']] });
    expect(response.status).toBe(200);
    expect(response.body).toHaveLength(2);
  });
});

describe('Collaboration API', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use('/api/collaboration', collaborationRouter);
  });

  it('should join a collaboration session', async () => {
    const mockSession = { id: '123', users: ['user1'] };
    (CollaborationService.joinWorkbook as jest.Mock).mockResolvedValue(mockSession);

    const response = await request(app)
      .post('/api/collaboration/join')
      .send({ workbookId: '1', userId: 'user1' });
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('id', '123');
  });

  it('should leave a collaboration session', async () => {
    (CollaborationService.leaveWorkbook as jest.Mock).mockResolvedValue(true);

    const response = await request(app)
      .post('/api/collaboration/leave')
      .send({ workbookId: '1', userId: 'user1' });
    expect(response.status).toBe(200);
  });

  // Note: WebSocket tests would typically be done in a separate test file
  // using a library like 'ws' for WebSocket client simulation
});

describe('Formulas API', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use('/api/formulas', formulasRouter);
  });

  it('should evaluate a formula', async () => {
    (FormulaService.evaluateFormula as jest.Mock).mockResolvedValue(10);

    const response = await request(app)
      .post('/api/formulas/evaluate')
      .send({ formula: '=SUM(1,2,3,4)' });
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('result', 10);
  });

  it('should get all supported functions', async () => {
    const mockFunctions = ['SUM', 'AVERAGE', 'COUNT'];
    (FormulaService.getSupportedFunctions as jest.Mock).mockResolvedValue(mockFunctions);

    const response = await request(app).get('/api/formulas/functions');
    expect(response.status).toBe(200);
    expect(response.body).toHaveLength(3);
  });

  it('should validate a formula', async () => {
    (FormulaService.validateFormula as jest.Mock).mockResolvedValue(true);

    const response = await request(app)
      .post('/api/formulas/validate')
      .send({ formula: '=SUM(A1:A10)' });
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('isValid', true);
  });
});