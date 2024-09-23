import { Router, Request, Response } from 'express';
import { WorkbookService } from '../services/WorkbookService';
import { authMiddleware } from '../middleware/auth';
import { Workbook } from '../models/Workbook';

const workbooksRouter = (): Router => {
  const router = Router();

  // Apply authMiddleware to all routes
  router.use(authMiddleware);

  // Define routes
  router.get('/', getWorkbooks);
  router.get('/:id', getWorkbook);
  router.post('/', createWorkbook);
  router.put('/:id', updateWorkbook);
  router.delete('/:id', deleteWorkbook);

  return router;
};

const getWorkbooks = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user.id; // Assuming user ID is attached to req by authMiddleware
    const workbooks = await WorkbookService.getWorkbooks(userId);
    res.json(workbooks);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve workbooks' });
  }
};

const getWorkbook = async (req: Request, res: Response): Promise<void> => {
  try {
    const workbookId = req.params.id;
    const userId = req.user.id;
    const workbook = await WorkbookService.getWorkbook(workbookId, userId);
    if (workbook) {
      res.json(workbook);
    } else {
      res.status(404).json({ error: 'Workbook not found' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve workbook' });
  }
};

const createWorkbook = async (req: Request, res: Response): Promise<void> => {
  try {
    const workbookDetails = req.body;
    const userId = req.user.id;
    const newWorkbook = await WorkbookService.createWorkbook(workbookDetails, userId);
    res.status(201).json(newWorkbook);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create workbook' });
  }
};

const updateWorkbook = async (req: Request, res: Response): Promise<void> => {
  try {
    const workbookId = req.params.id;
    const updatedDetails = req.body;
    const userId = req.user.id;
    const updatedWorkbook = await WorkbookService.updateWorkbook(workbookId, updatedDetails, userId);
    if (updatedWorkbook) {
      res.json(updatedWorkbook);
    } else {
      res.status(404).json({ error: 'Workbook not found' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to update workbook' });
  }
};

const deleteWorkbook = async (req: Request, res: Response): Promise<void> => {
  try {
    const workbookId = req.params.id;
    const userId = req.user.id;
    const result = await WorkbookService.deleteWorkbook(workbookId, userId);
    if (result) {
      res.json({ message: 'Workbook deleted successfully' });
    } else {
      res.status(404).json({ error: 'Workbook not found' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete workbook' });
  }
};

export { workbooksRouter };