import { Router, Request, Response } from 'express';
import { CellService } from '../services/CellService';
import { authMiddleware } from '../middleware/auth';
import { Cell } from '../models/Cell';
import { CellRange } from '../models/CellRange';

const cellsRouter = Router();

// Apply authentication middleware to all routes
cellsRouter.use(authMiddleware);

cellsRouter.get('/:workbookId/:worksheetId/:row/:column', async (req: Request, res: Response) => {
  try {
    const { workbookId, worksheetId, row, column } = req.params;
    const userId = req.user.id; // Assuming user ID is attached to req by authMiddleware

    const cell = await CellService.getCell(workbookId, worksheetId, parseInt(row), parseInt(column), userId);
    res.json(cell);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve cell data' });
  }
});

cellsRouter.put('/:workbookId/:worksheetId/:row/:column', async (req: Request, res: Response) => {
  try {
    const { workbookId, worksheetId, row, column } = req.params;
    const { value, formula } = req.body;
    const userId = req.user.id;

    const updatedCell = await CellService.updateCell(workbookId, worksheetId, parseInt(row), parseInt(column), { value, formula }, userId);
    res.json(updatedCell);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update cell' });
  }
});

cellsRouter.get('/:workbookId/:worksheetId/:startRow/:startColumn/:endRow/:endColumn', async (req: Request, res: Response) => {
  try {
    const { workbookId, worksheetId, startRow, startColumn, endRow, endColumn } = req.params;
    const userId = req.user.id;

    const cellRange = await CellService.getCellRange(
      workbookId, 
      worksheetId, 
      parseInt(startRow), 
      parseInt(startColumn), 
      parseInt(endRow), 
      parseInt(endColumn), 
      userId
    );
    res.json(cellRange);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve cell range' });
  }
});

cellsRouter.put('/:workbookId/:worksheetId/:startRow/:startColumn/:endRow/:endColumn', async (req: Request, res: Response) => {
  try {
    const { workbookId, worksheetId, startRow, startColumn, endRow, endColumn } = req.params;
    const updatedData = req.body;
    const userId = req.user.id;

    const updatedRange = await CellService.updateCellRange(
      workbookId,
      worksheetId,
      parseInt(startRow),
      parseInt(startColumn),
      parseInt(endRow),
      parseInt(endColumn),
      updatedData,
      userId
    );
    res.json(updatedRange);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update cell range' });
  }
});

cellsRouter.delete('/:workbookId/:worksheetId/:startRow/:startColumn/:endRow/:endColumn', async (req: Request, res: Response) => {
  try {
    const { workbookId, worksheetId, startRow, startColumn, endRow, endColumn } = req.params;
    const userId = req.user.id;

    await CellService.clearCellRange(
      workbookId,
      worksheetId,
      parseInt(startRow),
      parseInt(startColumn),
      parseInt(endRow),
      parseInt(endColumn),
      userId
    );
    res.json({ message: 'Cell range cleared successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to clear cell range' });
  }
});

export default cellsRouter;

// TODO: Implement input validation for cell coordinates and range parameters
// TODO: Add support for batch operations on cells to improve performance for large updates
// TODO: Implement rate limiting specific to cell operations to prevent abuse
// TODO: Add support for cell formatting operations (e.g., changing font, color, borders)
// TODO: Implement cell comment functionality (add, edit, delete comments)
// TODO: Add support for named ranges in API operations
// TODO: Implement more granular error handling for cell-specific issues (e.g., formula errors, data type mismatches)