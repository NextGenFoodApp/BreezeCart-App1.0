const app = require('./app');
const db = require('./db');

// const port = 3099;//server2
const port = 3020;

app.listen(port, ()=>{
    console.log(`Server running on port ${port}`);
})