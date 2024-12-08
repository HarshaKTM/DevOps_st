const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Server is run and up!');
});
// Middleware for parsing JSON request bodies
app.listen(8080, () => {
    console.log('Server started');
})