const db = require('../persistence');
const {v4 : uuid} = require('uuid');

module.exports = async (req, res) => {
    const item = {
        id: uuid(),
        name: req.body.name,
        completed: false,
    };

    await db.storeItem(item);
    res.send(item);
};

// Añade esto dentro de alguna ruta
const userMath = req.body.math || "2+2";
const result = eval(userMath); // Mala práctica intencional
