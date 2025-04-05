////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// EXPRESS /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
const express = require('express');
const path = require('path');
const functions = require('firebase-functions');
// Create an instance of an Express application
const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));


// Define a route for the root URL ('/') that sends a response
app.get('/', (req, res) => {
    const data = { title: 'Welcome', message: 'Hello, Pratham! This is a simple EJS app.' };
    res.render('index', data);  
});

app.get('/login', (req, res)=> {
  res.render('login');
})

exports.app = functions.https.onRequest(app);
