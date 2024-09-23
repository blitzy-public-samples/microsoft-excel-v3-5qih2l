import { Router, Request, Response } from 'express';
import { CollaborationService } from '../services/CollaborationService';
import { authMiddleware } from '../middleware/auth';
import { websocketMiddleware } from '../middleware/websocket';
import { Change } from '../models/Change';
import { User } from '../models/User';

const collaborationRouter = Router();
collaborationRouter.use(authMiddleware);

collaborationRouter.post('/join', async (req: Request, res: Response) => {
  try {
    const workbookId = req.params.workbookId;
    const userId = req.user.id;
    const userInfo = req.user;

    const sessionInfo = await CollaborationService.joinWorkbook(workbookId, userInfo);
    res.json(sessionInfo);
  } catch (error) {
    res.status(500).json({ error: 'Failed to join workbook session' });
  }
});

collaborationRouter.post('/leave', async (req: Request, res: Response) => {
  try {
    const workbookId = req.params.workbookId;
    const userId = req.user.id;

    await CollaborationService.leaveWorkbook(workbookId, userId);
    res.json({ message: 'Successfully left the workbook session' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to leave workbook session' });
  }
});

collaborationRouter.ws('/sync', websocketMiddleware, (ws: WebSocket, req: Request) => {
  ws.on('message', async (message: string) => {
    try {
      const change: Change = JSON.parse(message);
      const workbookId = req.params.workbookId;
      const userId = req.user.id;

      const processedChange = await CollaborationService.processChange(change, workbookId, userId);
      
      // Broadcast the processed change to other collaborators
      // This is a placeholder - actual implementation will depend on your WebSocket setup
      broadcastChange(processedChange, workbookId, userId);
    } catch (error) {
      ws.send(JSON.stringify({ error: 'Failed to process change' }));
    }
  });
});

collaborationRouter.get('/collaborators', async (req: Request, res: Response) => {
  try {
    const workbookId = req.params.workbookId;
    const collaborators = await CollaborationService.getCollaborators(workbookId);
    res.json(collaborators);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve collaborators' });
  }
});

function broadcastChange(change: Change, workbookId: string, excludeUserId: string) {
  // Implement broadcasting logic here
  // This will depend on your specific WebSocket implementation
}

export default collaborationRouter;