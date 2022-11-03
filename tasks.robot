*** Settings ***
Documentation       Robot for Level 2 Certification
...                 Built by Tejus Venkatesh
...                 12-Oct-2022
...                 tasks.robot file has only keywords and the definiations are all written in keywords.resource file
Resource            keywords.resource


*** Tasks ***
Order Robots from RobotSpareBin Industries Inc - Lvl2 - Tejus
    Get user input
    Open the robot orders website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Log To Console    ${row}
        Download and store the reciept    ${row}[Order number]
        Order another Robot
    END
    Archive output PDFs
    [Teardown]    Close RobotSpareBin Browser