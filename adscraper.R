#Load required libraries
packages <- list('XML','httr','stringr')
lapply(packages, function(x) {if(!(x %in% installed.packages())) install.packages(x) else require(x,character.only = TRUE)})

#Define initial link(s)
kijiji <- list("http://www.kijiji.ca/b-calgary/baby-carrier/k0l1700199")

#Define a function to generate a full list of links to process later
links <- function (linklist=kijiji) {
    
    output <- list()
    counter <- 1:100
    
    for (link in linklist) {
          
          for (num in counter) {output <- c(output,sub('[0-9]+',num,link))}    
    }    
    return (output)
    
}

#A variable to hold the list of links generated from the previous function
listoflinks <- links()

#Initialize a dataframe(s) to store the results of the web scraping
df <- data.frame()
others <- data.frame()

#loop to scrape desired elements from the links generated above recursively
for (link in listoflinks) {
   
    
    url <- GET(link)
    doc <- content(url)
    title <- xpathSApply(doc,"//a[starts-with(@class,'title')]",function(x){str_trim(xmlValue(x))})
    price <- xpathSApply(doc,"//td[@class='price']",function(x){str_trim(xmlValue(x))})
    short.desc <- xpathSApply(doc,"//td[@class='description']/p[1]",function(x){str_trim(xmlValue(x))})
    Link <- xpathSApply(doc,"//a[starts-with(@class,'title')]",function(x){paste0('http://www.kijiji.ca',xmlGetAttr(x,'href'))})
    
    #Bind the first 4 columns to the 1st original data frame initiated just before the loop, i.e. df
    df <- rbind(df,data.frame(title,price,short.desc,Link,stringsAsFactors=FALSE))
    
    #Fetch other attributes from direct links of the ads
    placeholder <- data.frame(t(data.frame(lapply(Link,function(x){     
      url1 <- GET(x)
      doc1 <- content(url1)
      date <- xpathSApply(doc1,"//table[@class='ad-attributes']/tr[1]/td",xmlValue)
      loc <- xpathSApply(doc1,"//table[@class='ad-attributes']/tr[3]/td/text()[1]",function(x){str_trim(xmlValue(x))})
      long.desc <- xpathSApply(doc1,"//span[@itemprop='description']",function(x){str_trim(xmlValue(x))})
      if(length(date)==0) {date <- NA}
      if(length(loc)==0) {loc <- NA}
      if(length(long.desc)==0) {long.desc <- NA}
      return(c(date,loc,long.desc))
      }))))
      
      #Bind the next 3 columns to the 2nd original data frame initiated just before the loop, i.e. others
      others<-rbind(others,placeholder)
  


}

#Bind the two dataframes resulted from the loop above
df <- cbind(df,others)

#Name the columns of the output dataframe 
names(df) <- c('Title','Price','Short.Description','Link','Date','Address','Full.Description')

#Convert the columns of the output dataframe to appropriate classes
df[c(5:7)] <- data.frame(lapply(df[c(5:7)],as.character),stringsAsFactors = F) 

#Remove duplicate entries (only based on the values in the first three columns)
dup <- duplicated(df[,1:3])
df <- df[!dup,]

#Remove NA observations and 'Please Contact' in the Price column
df <- subset(df, !is.na(df$Date))
df <- subset(df,df$Price!='Please Contact')

#Clean up the Price and Date columns
df[,'Price'] <- data.frame(sapply(df[,'Price'],function(x){x<-sub('Free',0,x); x<-gsub('\\$|,|.*[Aa-zZ]','',x);as.numeric(x)}))
df[,'Date'] <- as.Date(df[,'Date'],'%d-%b-%y')

#Rearrange columns and reorder records
df <- df[,c(1,2,3,6,5,7,4)]
df <- df[order(df['Price'],df['Date']),]

#Add a new column to replace the text url with a clickable link and then delete the old url column
df <- transform(df, URL = paste('<a href = ', shQuote(Link), '>', 'Click</a>'))
df <- df[-7]

#Reset rownames
rownames(df) <- NULL
