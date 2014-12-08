#Install required packages
ListofPackages= c('shiny','ggplot2','scales')
NewPackages= ListofPackages[!(ListofPackages %in% installed.packages()[,'Package'])]
if(length(NewPackages)>0) install.packages(NewPackages)

#Load required packages
lapply(ListofPackages,require,character.only=TRUE)

#Load source code
source('C:/Users/Bahae Omid/Google Drive/My R Case Studies/Shiny Apps/Kijiji App/adscraper.R',local=TRUE)


shinyServer(function(input,output){
    
    #Create a reactive function to deal with inputs of the user
    search <- reactive({
       if(length(input$t)>0) {ind <- grep(input$t,df[,'Title'],ignore.case = T); df <- df[ind,] }
       if(length(input$d)>0) {ind <- grep(input$d,df[,'Full.Description'],ignore.case = T); df <- df[ind,]}
       if(length(input$a)>0) {ind <- grep(input$a,df[,'Address'],ignore.case = T); df <- df[ind,]}
       if(input$p >=0) {ind <- df[,'Price']<=input$p ; df <- df[ind,]}
    })
    
    #Send the searchresult table to ui.R
    output$searchresult <- renderDataTable({
      input$action1 #triggered only when button is pressed
      if(input$action1==0) return() 
      else{isolate({
        transformed <- transform(search(), URL = paste('<a href = ', shQuote(Link), '>', 'Click</a>'))
        transformed[-7] #Remove the old Link column
      })
      }
    }, option=list(autoWidth=FALSE,pageLength=100,
                   columnDefs = list(list(targets =c(2,5,7) -1, searchable = FALSE),list(sWidth="75px",aTargets = list(4,5)))))
    
    #Allow user to download the data via downloadhandler
    output$down <- downloadHandler(
        filename='filtered.csv',
        content=function(file){write.csv(search(),file,row.names=FALSE)}
    )
    
    
    
})
