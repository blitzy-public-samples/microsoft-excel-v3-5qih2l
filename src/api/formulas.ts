import { Router, Request, Response } from 'express';
import { FormulaService } from '../services/FormulaService';
import { authMiddleware } from '../middleware/auth';
import { evaluateFormula, getCellDependencies } from '../utils/formula_utils';

const formulasRouter = Router();

// Apply authentication middleware to all routes
formulasRouter.use(authMiddleware);

formulasRouter.post('/evaluate', async (req: Request, res: Response) => {
  try {
    const { formula } = req.body;
    const { workbookId, worksheetId } = req.params;
    const userId = req.user.id; // Assuming user ID is attached to the request by authMiddleware

    const result = await FormulaService.evaluateFormula(formula, workbookId, worksheetId, userId);
    res.json({ result });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

formulasRouter.post('/dependencies', async (req: Request, res: Response) => {
  try {
    const { formula } = req.body;
    const { workbookId, worksheetId } = req.params;
    const userId = req.user.id;

    const dependencies = await FormulaService.getCellDependencies(formula, workbookId, worksheetId, userId);
    res.json({ dependencies });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

formulasRouter.post('/validate', async (req: Request, res: Response) => {
  try {
    const { formula } = req.body;
    const isValid = await FormulaService.validateFormula(formula);
    res.json({ isValid });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

formulasRouter.get('/functions', async (req: Request, res: Response) => {
  try {
    const functions = await FormulaService.getSupportedFunctions();
    res.json({ functions });
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve supported functions' });
  }
});

export default formulasRouter;