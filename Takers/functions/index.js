////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// FIREBASE ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
const functions = require('firebase-functions');
const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');

initializeApp();

// const firebaseConfig = {
//   apiKey: "AIzaSyD59LE9kzPv0xqlqCGnC5l4xUS7eLShTTs",
//   authDomain: "second-srving.firebaseapp.com",
//   projectId: "second-srving",
//   storageBucket: "second-srving.firebasestorage.app",
//   messagingSenderId: "426857757301",
//   appId: "1:426857757301:web:0d1161100b2ae7521a963c",
//   measurementId: "G-L9F1W4N5FJ"
// };

// Initialize Firebase
const db = getFirestore();
const takerscollection = db.collection('takers');


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// EXPRESS /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser')

// Create an instance of an Express application
const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'images')));
app.use(express.static(path.join(__dirname, 'css')));
app.use(express.static(path.join(__dirname, 'js')));
app.use(cookieParser())

const urlencodedParser = bodyParser.urlencoded()

app.get('/login', (req, res)=> {
  var cookies = req.cookies;
  if (cookies && cookies.__session) {
    res.render("home");
  } else {
    res.render('login');
  }
})

app.get('/home', (req, res)=>{
  var cookies = req.cookies;
  if (cookies && cookies.__session) {
    res.render("home");
  } else {
    res.redirect('/login')
  }
})

app.get('/settings', (req, res)=>{
  var cookies = req.cookies;
  if (cookies && cookies.__session) {
    const user = JSON.parse(cookies.__session)  
    res.render("settings", {firstName: user.firstName, lastName: user.lastName, mobileNumber: user.mobileNumber});
  } else {
    res.redirect('/login')
  }
})

app.post('/login', urlencodedParser, async (req, res) => {
  
  let number = req.body.mobileNumber;
  if (number.substring(0,2) != "+1") {
    number = "+1" + number;
  }

  let found = false;
  const takersSnap = await db.collection('takers').get();
  takersSnap.forEach((doc) => {
    console.log(doc.data().mobileNumber)
    if (doc.data().mobileNumber == number) {
      console.log(req.body.password);
      console.log(doc.data().password);
        if (doc.data().password == req.body.password) {
          res.setHeader('Cache-Control', 'private')
          res.cookie('__session', JSON.stringify(doc.data()))
          found = true;
        } else if (!found) {
          console.log("Incorrect Password")
          return
          // res.redirect('/login')
        }
    }
  });

  if (!found) {
    console.log("User not found")
    res.redirect('/login')
    // res.send("Incorrect password")
  }

  if (found) {
    res.redirect('/home');
  }
})

app.post('/signup', urlencodedParser, async (req, res) => {

  let number = req.body.mobileNumber;
  if (number.substring(0,2) != "+1") {
    number = "+1" + number;
  }

  taker = {
    firstName: req.body.firstName,
    lastName: req.body.lastName,
    mobileNumber: number,
    password: req.body.password
  }

  await takerscollection.add(taker)
  console.log(taker)
  res.redirect('/login')
})

app.listen(3000, ()=>{
  console.log("HAHAAHAH");
})

exports.app = functions.https.onRequest(app);