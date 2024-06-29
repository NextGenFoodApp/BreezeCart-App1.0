const express = require('express');
const router = express.Router();

const BulkController = require('../controllers/bulkController');

// Get all bulks in the database.
router.get('/', async (req,res)=>{
    const bulks = await BulkController.getAllBulks();
    res.send(bulks);
})

// Get one bulk
router.get('/:id', async (req,res)=>{
    const bulk = await BulkController.getSpecificBulk(req.params.id);
    res.send(bulk);
})

// Add new bulk
router.post('/', async (req,res)=>{
    const bulks = await BulkController.getAllBulks();
    const new_bulk_id = bulks.length + 1;
    const new_bulk = {
        bulk_id : new_bulk_id,
        items : [],
        frequency: req.body.frequency,
        delivery_starting_date: req.body.delivery_starting_date,
        status: req.body.status
    }
    await BulkController.addNewBulk(new_bulk);
})

module.exports = router;