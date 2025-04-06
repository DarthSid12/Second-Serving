    loginDiv = document.getElementById("loginDiv")
signupDiv = document.getElementById("signupDiv")
loginOptions = document.getElementById("loginOptions")

function revealLogin() {
    loginDiv.style.display = "flex"
    loginOptions.style.display = "none"
}

function revealSignUp() {
    loginOptions.style.display = "none"
    signupDiv.style.display = "flex"
}

passwordInputSignup = document.getElementById('passwordInputSignup');
confirmPasswordInputSignup = document.getElementById('confirmPasswordInputSignup');
submitInputSignup = document.getElementById('submitInputSignup');

passwordInputSignup.addEventListener("keyup", ()=>{
    if (passwordInputSignup.value != "" && passwordInputSignup.value == confirmPasswordInputSignup.value) {
        submitInputSignup.disabled = false;
        confirmPasswordInputSignup.style.borderBottom = "2px solid #42D42D";
    } else {
        submitInputSignup.disabled = true;
        confirmPasswordInputSignup.style.borderBottom = "2px solid #FF0000";
    }
})

confirmPasswordInputSignup.addEventListener("keyup", ()=>{
    if (passwordInputSignup.value != "" && passwordInputSignup.value == confirmPasswordInputSignup.value) {
        submitInputSignup.disabled = false;
        confirmPasswordInputSignup.style.borderBottom = "2px solid #42D42D";
    } else {
        submitInputSignup.disabled = true;
        confirmPasswordInputSignup.style.borderBottom = "2px solid #FF0000";
    }
})

mobileNumberInputSignup = document.getElementById("mobileNumberInputSignup")
verifyMobileButton = document.getElementById("verifyMobileButton")
mobileNumberInputSignup.addEventListener("keyup", ()=>{
    const number = mobileNumberInputSignup.value;
    if ("+1" == number.substring(0,2)) {
        if (mobileNumberInputSignup.value.length != 12) {
            mobileNumberInputSignup.style.borderBottom = "2px solid #FF0000";
            verifyMobileButton.disabled = true;
        } else {
            mobileNumberInputSignup.style.borderBottom = "2px solid #42D42D";
            verifyMobileButton.disabled = false;
        }
    } else {
        if (mobileNumberInputSignup.value.length != 10) {
            mobileNumberInputSignup.style.borderBottom = "2px solid #FF0000";
            verifyMobileButton.disabled = true;
        } else {
            mobileNumberInputSignup.style.borderBottom = "2px solid #42D42D";
            verifyMobileButton.disabled = false;
        }
    }
})