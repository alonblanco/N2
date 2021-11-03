# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Generar un robot para la certificación N2 Robocorp
Library         RPA.Browser.Selenium
Library         RPA.HTTP
Library         RPA.Tables
Library         RPA.PDF
Library         RPA.Archive
Library         RPA.Dialogs
Library         RPA.Robocloud.Secrets



*** Keywords ***
Pedir url fichero Excel y descargarlo
    Add heading     URL Archivo CSV
    Add text input  URL    label=URL CSV  placeholder=Introduzca URL 
    ${urlinsertada} =  Run Dialog
    [Return]     ${urlinsertada.URL}
    Download        ${urlinsertada.URL}      overwrite=True


*** Keywords ***
Abre navegador
    ${urlsecreta}=      Get Secret     enlace
    Open Available Browser           ${urlsecreta}[formulario]
    Sleep       3

*** Keywords ***
Rellenar pedidos
    @{tabla}=       Read table from CSV         orders.csv
    FOR    ${pedido}    IN       @{tabla}
             Generar pedidos        ${pedido}
    END

*** Keywords ***
Generar pedidos
    [Arguments]       ${pedido}
    Click Button When Visible       css:BUTTON.btn.btn-dark
    Select From List By Value      id:head     ${pedido}[Head]
    Select Radio Button      body             ${pedido}[Body]           
    Input Text         xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input            ${pedido}[Legs]
    Input Text    id:address    ${pedido}[Address]
    Generar vista previa
    Captura pantalla          ${pedido}[Order number]
    Wait Until Keyword Succeeds   5x       1s        Procesar pedidos
    Generar pdf        ${pedido}[Order number]           ${OUTPUT_DIR}
    Insertar captura en PDF       ${pedido}[Order number]         ${pedido}[Order number]
    Realizar otro pedido 


*** Keywords ***
Generar vista previa
    Click Button When Visible   id:preview

*** Keywords ***
Procesar pedidos
    Click Button When Visible  id:order
    Wait Until Page Contains Element      id:order-completion


*** Keywords ***
Generar pdf    
    [Arguments]      ${orden}         ${directorio-salida}
    Wait Until Element Is Visible    id:order-completion
    ${recibo_pedido_html}=      Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf         ${recibo_pedido_html}        ${CURDIR}${/}output${/}recibos${/}${orden}.pdf 

*** Keywords ***
Captura pantalla
    [Arguments]       ${orden-imagen}
    Screenshot    id:robot-preview-image        ${CURDIR}${/}output${/}recibos${/}${orden-imagen}.png


*** Keywords ***
Insertar captura en PDF          
    [Arguments]        ${captura}           ${pdf} 
        Open Pdf         ${CURDIR}${/}output${/}recibos${/}${pdf}.pdf
        Add Watermark image To Pdf          ${CURDIR}${/}output${/}recibos${/}${captura}.png      ${CURDIR}${/}output${/}recibos${/}${pdf}.pdf     
        Close Pdf               ${CURDIR}${/}output${/}recibos${/}${pdf}.pdf


*** Keywords ***
Realizar otro pedido
        Click Button When Visible      id:order-another

*** Keywords *** 
Crear archivo ZIP
        Archive Folder With Zip    ${CURDIR}${/}output${/}recibos    C:\\Users\\ablanco\\Downloads\\reciboscom.zip   exclude=*.png

*** Keywords ***
Cerrar navegador
        Close browser

*** Tasks ***
Rellenar pedidos robots  
    Pedir url fichero Excel y descargarlo
    Abre navegador
    Rellenar pedidos
    Crear archivo ZIP
    Cerrar navegador



