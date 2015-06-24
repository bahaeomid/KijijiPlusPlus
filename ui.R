#for backward compatibility (when shiny upgraded to bootstrap 3, old code needs upgrading too)
withBootstrap2({
  
  shinyUI(fluidPage(
    
    #Display datatable filters on top
    tags$head(tags$style("tfoot {display: table-header-group;}")),        
    
    #Add a title
    img(src="kijiji.gif", height = 100, width = 100),
    img(src="plus.png", height = 20, width = 20),
    img(src="plus.png", height = 20, width = 20),    
    
    #Add required JS libraries
    tagList(
      singleton(tags$head(tags$script(src='//cdn.datatables.net/1.10.4/js/jquery.dataTables.min.js',type='text/javascript'))),
      singleton(tags$head(tags$script(src='//cdn.datatables.net/tabletools/2.2.3/js/dataTables.tableTools.min.js',type='text/javascript'))),
      singleton(tags$head(tags$link(href='//cdn.datatables.net/tabletools/2.2.3/css/dataTables.tableTools.css',rel='stylesheet',type='text/css'))),
      singleton(tags$script(HTML("if (window.innerHeight < 400) alert('Screen too small');")))
    ),
    
    #Use the Sidebar layout
    sidebarLayout(
      sidebarPanel(
        
        #Add fields to search by
        h5('Note: Running the app takes a little while to run at startup.'),
        helpText('Ad Title:'),
        textInput('t',''),
        helpText('Description:'),
        textInput('d',''),
        helpText('Address:'),
        textInput('a',''),
        sliderInput('p','Show Prices up to:',min = 0,max = 5000,step = 50,value = 0),
        actionButton('action1','Search!')         
        
      ),       
      
      mainPanel(
        dataTableOutput('searchresult')
      )
      
    )   
  ))
  
})