shinyUI(fluidPage(
    
    #Display datatable filters on top
    tags$head(tags$style("tfoot {display: table-header-group;}")),        
    
    #Add a title
    img(src="kijiji.gif", height = 100, width = 100),
    img(src="plus.png", height = 20, width = 20),
    img(src="plus.png", height = 20, width = 20),    
    
    #Use the Sidebar layout
    sidebarLayout(
        sidebarPanel(
            
                        
            #Add fields to search by and download button to allow exporting search results to csv.
             h5('Note: Running the app takes a little while to run at startup.'),
             helpText('Ad Title:'),
             textInput('t',''),
             helpText('Description:'),
             textInput('d',''),
             helpText('Address:'),
             textInput('a',''),
             sliderInput('p','Show Prices up to:',min = 0,max = 5000,step = 50,value = 0),
             actionButton('action1','Search!'), 
             br(),
             br(),
             helpText('Click below to download the results of your search:'),
             downloadButton('down','Download')
                                                                    
        ),
        
        
        mainPanel(
        dataTableOutput('searchresult')
        )
                        
    )   
))
