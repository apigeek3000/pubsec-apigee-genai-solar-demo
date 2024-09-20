const express = require('express');
const app = express();
const port = 8080;

app.use(express.static('public'));

// Serve index-edu.html for the edu path
app.get('/state', (req, res) => {
  res.sendFile(__dirname + '/public/index-state.html');
});

// Serve index-state.html for the state path
app.get('/edu', (req, res) => {
  res.sendFile(__dirname + '/public/index-edu.html');
});

app.listen(port, () => {
  console.log(`Solar web app listening on port ${port}`);
});