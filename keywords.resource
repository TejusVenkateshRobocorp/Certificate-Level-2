*** Settings ***

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Dialogs
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Robocorp.Vault

Variables           variables.py


*** Keywords ***
Open the robot orders website
    Open Available Browser    ${webURL} 
    Click Link    alias:Btn_OrderYourRobot

Get input from user
    Add heading    Please suggest a file name for your orders
    Add text input    fileName    label=File Name:
    ${result}=    Run dialog
    RETURN    ${result.fileName}

Download Orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True    target_file=orders.csv

Get orders
    Download Orders file
    ${orderList}=    Read table from CSV    orders.csv
    RETURN     ${orderList}

Close the annoying modal
    TRY
        Click Element    alias:Btn_AnnoyingOk
    EXCEPT  
        No Operation
    END
    
Fill the form 
    [Arguments]    ${row}
    Select From List By Value    alias:Drop_Head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    alias:Txt_Legs    ${row}[Legs]
    Input Text    alias:Txt_Address    ${row}[Address]
    Click Element    alias:Btn_Preview
    Wait Until Page Contains Element   alias:Div_PreviewImage
    Wait Until Keyword Succeeds    5x    100ms    Submit the form


Submit the form 
    Click Element   alias:XPath_Btn_Order   
    Wait Until Element Is Visible    alias:Div_Reciept  

Download and store the reciept
    [Arguments]    ${orderNumber}
    
    ${reciept_html}=     Get Element Attribute  alias:Div_Reciept    outerHTML
    Html To Pdf    ${reciept_html}    ${CURDIR}/outputPDFs/${orderNumber}reciept.pdf
    ${screenshot}=    Capture Element Screenshot    alias:Div_PreviewImage    ${CURDIR}/output/${orderNumber}screenshot.png

    ${reciept_pdf}=    Open Pdf    ${CURDIR}/outputPDFs/${orderNumber}reciept.pdf
    ${files}=    Create List
    ...    ${CURDIR}/output/${orderNumber}screenshot.png
    Add Files To PDF    ${files}    ${CURDIR}/outputPDFs/${orderNumber}reciept.pdf    ${True}
    Close Pdf    ${recieptPdf}


Order another Robot
    Click Element    alias:Btn_AnotherRobot

Archive output PDFs 
    Archive Folder With Zip    ${CURDIR}/outputPDFs    ${CURDIR}/outputPDFs.zip

Close RobotSpareBin Browser
    Close Browser

Get user input
    Add heading    Do you want to pull the URL from secret vault?
    Add submit buttons    buttons=No,Yes    default=Yes
    ${userInput}=  Run dialog
    # Msgbox    ${userInput}[submit]

    IF    "${userInput}[submit]" == "Yes"
        
        ${secret}=    Get Secret    Certification_Lvl2 
        # Msgbox    ${secret}[URL]
        # ${webURL} =    Set  Variable    ${secret}[URL]
        Set Global Variable    ${webURL}    ${secret}[URL]
        # Msgbox    ${webURL}
        Log    User selected Yes
        # Pull vault information 
    ELSE 
        Set Global Variable    ${webURL}    https://robotsparebinindustries.com/#/
    END

Msgbox
    # I have used this keyword for ease of testing and Debugging... It mimics the funcationality of VB MSGBOX function
    [Arguments]     ${text}
    Add heading    ${text}
    Run dialog  
