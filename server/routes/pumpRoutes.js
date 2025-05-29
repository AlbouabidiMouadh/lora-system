const express = require('express');
const router = express.Router();
const pumpController = require('../controllers/pumpController');
const { protect } = require('../middlewares/auth');

router.post('/', protect, pumpController.createPump);
router.get('/', protect, pumpController.getPumps);
router.get('/:id', protect, pumpController.getPumpById);
router.put('/:id', protect, pumpController.updatePump);
router.delete('/:id', protect, pumpController.deletePump);
router.get('/user', protect, pumpController.getPumpsByUserId);
router.patch('/:id/status', protect, pumpController.updatePumpStatus);

module.exports = router;
