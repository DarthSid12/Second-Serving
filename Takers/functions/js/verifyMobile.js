import { getAuth, signInWithPhoneNumber, RecaptchaVerifier } from "https://www.gstatic.com/firebasejs/11.6.0/firebase-auth.js";
import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.0/firebase-app.js";


// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyD59LE9kzPv0xqlqCGnC5l4xUS7eLShTTs",
  authDomain: "second-srving.firebaseapp.com",
  projectId: "second-srving",
  storageBucket: "second-srving.firebasestorage.app",
  messagingSenderId: "426857757301",
  appId: "1:426857757301:web:0d1161100b2ae7521a963c",
  measurementId: "G-L9F1W4N5FJ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export function verifyMobile(phoneNumber) {

    const auth = getAuth(app);

    window.recaptchaVerifier = new RecaptchaVerifier(auth, 'verifyMobileButton', {
        'size': 'invisible',
        'callback': (response) => {
            console.log("Recaptcha verified")
        },
    });      
    
    const appVerifier = window.recaptchaVerifier;

    signInWithPhoneNumber(auth, phoneNumber, appVerifier)
        .then((confirmationResult) => {

        window.confirmationResult = confirmationResult;
        const code = prompt("Enter OTP")
        confirmationResult.confirm(code).then((value)=>{
            console.log(value)
            document.getElementById('signupForm').style.display = 'flex';
            document.getElementById("incorrectOTPMsg").style.display = "none"
        }).catch((error) => {
            console.log("Incorrect OTP")
            document.getElementById("incorrectOTPMsg").style.display = "flex";
        })
        
        // ...
        }).catch((error) => {
            console.log(error)
            console.log("SMS not sent")
        });
}

document.getElementById("verifyMobileButton").addEventListener("click", ()=>{
    var number = document.getElementById('mobileNumberInputSignup').value

    if (!("+1" == number.substring(0,2))) {
        number = "+1" + number
    } 

    verifyMobile(number);
})