import { Router, Request, Response } from 'express';
import { WorksheetService } from '../services/WorksheetService';
import { authMiddleware } from '../middleware/auth';
import { Worksheet } from '../models/Worksheet';

export const worksheetsRouter = (): Router => {
  const router = Router();

  // Apply authMiddleware to all routes
  router.use(authMiddleware);

  // Define routes for worksheet operations
  router.get('/workbooks/:workbookId/worksheets', getWorksheets);
  router.get('/workbooks/:workbookId/worksheets/:worksheetId', getWorksheet);
  router.post('/workbooks/:workbookId/worksheets', createWorksheet);
  router.put('/workbooks/:workbookId/worksheets/:worksheetId', updateWorksheet);
  router.delete('/workbooks/:workbookId/worksheets/:worksheetId', deleteWorksheet);

  return router;
};

export const getWorksheets = async (req: Request, res: Response): Promise<void> => {
  try {
    const workbookId = req.params.workbookId;
    const userId = req.user.id; // Assuming authMiddleware adds user to request

    const worksheets = await WorksheetService.getWorksheets(workbookId, userId);
    res.json(worksheets);
  } catch (error) {
    console.error('Error getting worksheets:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getWorksheet = async (req: Request, res: Response): Promise<void> => {
  try {
    const { workbookId, worksheetId } = req.params;
    const userId = req.user.id;

    const worksheet = await WorksheetService.getWorksheet(workbookId, worksheetId, userId);
    if (worksheet) {
      res.json(worksheet);
    } else {
      res.status(404).json({ error: 'Worksheet not found' });
    }
  } catch (error) {
    console.error('Error getting worksheet:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const createWorksheet = async (req: Request, res: Response): Promise<void> => {
  try {
    const workbookId = req.params.workbookId;
    const worksheetDetails = req.body;
    const userId = req.user.id;

    const createdWorksheet = await WorksheetService.createWorksheet(workbookId, worksheetDetails, userId);
    res.status(201).json(createdWorksheet);
  } catch (error) {
    console.error('Error creating worksheet:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const updateWorksheet = async (req: Request, res: Response): Promise<void> => {
  try {
    const { workbookId, worksheetId } = req.params;
    const updatedDetails = req.body;
    const userId = req.user.id;

    const updatedWorksheet = await WorksheetService.updateWorksheet(workbookId, worksheetId, updatedDetails, userId);
    if (updatedWorksheet) {
      res.json(updatedWorksheet);
    } else {
      res.status(404).json({ error: 'Worksheet not found' });
    }
  } catch (error) {
    console.error('Error updating worksheet:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const deleteWorksheet = async (req: Request, res: Response): Promise<void> => {
  try {
    const { workbookId, worksheetId } = req.params;
    const userId = req.user.id;

    const deleted = await WorksheetService.deleteWorksheet(workbookId, worksheetId, userId);
    if (deleted) {
      res.status(204).send();
    } else {
      res.status(404).json({ error: 'Worksheet not found' });
    }
  } catch (error) {
    console.error('Error deleting worksheet:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// TODO: Implement input validation for request parameters and body
// TODO: Add support for bulk operations on worksheets (e.g., bulk create, update, delete)
// TODO: Implement pagination for getWorksheets endpoint if dealing with large numbers of worksheets
// TODO: Add filtering and sorting options for getWorksheets endpoint
// TODO: Implement rate limiting to prevent abuse of worksheet-related endpoints
// TODO: Add logging for worksheet operations
// TODO: Implement more granular error handling and custom error messages for worksheet-specific issues