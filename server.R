#Install required packages
ListofPackages= c('shiny','ggplot2','scales')
NewPackages= ListofPackages[!(ListofPackages %in% installed.packages()[,'Package'])]
if(length(NewPackages)>0) install.packages(NewPackages)

#Load required packages
lapply(ListofPackages,require,character.only=TRUE)

#Load source code
source('C:/Users/Bahae.Omid/Google Drive/My R Case Studies/Shiny Apps/Kijiji App/adscraper.R',local=TRUE)


shinyServer(function(input,output){
    
    #Create a reactive function to deal with inputs of the user
    search <- reactive({
       
       #Store the inputs
       t <- input$t
       d <- input$d
       a <- input$a
       p <- input$p
       
       #Search based on the inputs provided by the user
       ind.t <- if(t=='') NULL else grep(t,df[,'Title'],ignore.case = T)
       ind.d <- if(d=='') NULL else grep(d,df[,'Full.Description'],ignore.case = T)
       ind.a <- if(a=='') NULL else grep(a,df[,'Address'],ignore.case = T)
       ind.p <- which(df[,'Price']<=p)
       
       #Store all the indices found above in one list
       ind.all <- list(ind.t,ind.d,ind.a,ind.p)
       
       #Apply the intersect function recursively to ind.all to find the common indices in all the sublists of ind.all
       ind <- Reduce(intersect,ind.all[!sapply(ind.all,is.null)])
       
       #Return the search results
       df[ind,] 
    })
    
    #Send the searchresult table to ui.R
    output$searchresult <- renderDataTable({
      input$action1 #triggered only when button is pressed
      if(input$action1==0) return() 
      else{isolate({
        search()
      })
      }
    }, option=list(autoWidth=FALSE,pageLength=100,
                   columnDefs = list(list(targets =c(2,5,7) -1, searchable = FALSE),list(sWidth="75px",aTargets = list(4,5))),
                   "dom" = 'T<"clear">lfrtip',
                   "oTableTools" = list(
                     "sSwfPath" = "//cdnjs.cloudflare.com/ajax/libs/datatables-tabletools/2.1.5/swf/copy_csv_xls.swf",
                     "aButtons" = list("copy","print",list("sExtends" = "csv","sButtonText" = "Export","aButtons" = "csv")))
                   
                  )
     )
    
    
})
