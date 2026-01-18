*** Settings ***
Library    SeleniumLibrary
Suite Setup    Setup Browser
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}       http://localhost:80

*** Keywords ***
Setup Browser

    ${options}=    Evaluate    selenium.webdriver.ChromeOptions()    selenium.webdriver
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --headless
    Open Browser    ${BASE_URL}    chrome    options=${options}

*** Test Cases ***
Text Testing
    Page Should Contain     CRUD
