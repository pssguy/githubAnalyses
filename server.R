
shinyServer(function(input, output, session) {
 
  ## try sepearting out ui from reactng to textinput - trying to only get
  ## when actio btton pressed
  
  userData <- eventReactive(input$getRepos,{
    # input$getRepos
    # #if(is.null(input$userName)) return()
    req(input$userName)
    # 
    # userName <- input$userName
    
    # first test if user name exists on github
    v <- paste0("https://github.com/",input$userName,"/repositories?page=1")
    
    
    
    if(http_error(v)==TRUE) {
      allRepos <- character()
      df <-data.frame(repos=allRepos, stringsAsFactors = F)
        
      } else {
    
    
    repoLength <- 1
    i <- 1
    while (repoLength>0) {
      print("a")
      print(repoLength)
      repoLength <- 0
      print(i)
      u <- paste0("https://github.com/",input$userName,"/repositories?page=",i)
      
      
      dom <-read_html(u)
      
      
      
      repos <- dom %>% 
        html_nodes(".repo-list-name a") %>% 
        html_text(trim=T)
      
      
      if (i !=1) {
        allRepos <- c(allRepos,repos)
      } else {
        allRepos <- repos
      }
      
      
      repoLength <- length(repos)
      print("b")
      i <- i+1
      print(paste0("rep",repoLength))
      print(i)
      print(allRepos)
    }
    df <- data.frame(repos=allRepos, stringsAsFactors = F)
    }
    
   
   
      
    info=list(df=df)
    
    return(info)
    
  })
  
output$a <- renderUI({
  #if(is.null(userData())) return()
  req(userData())
  # print("in select")
  # print(glimpse(userData()$df))
  # 
  repos <- userData()$df$repos
  #print(repos)
  
inputPanel(
selectInput("repo","Select repo",repos)
)
})

# repoData <- eventReactive(input$repo,{
#   
# 
#   v <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues?q=is%3Aissue+is%3Aclosed")
#   print(v)
#   theDom <- read_html(v)  #open default
#   
#   issue <- theDom %>%   html_nodes(".issue-title-link") %>% 
#     html_text(trim=TRUE) %>% 
#     as.character()
#   
#   replies <- theDom %>%   html_nodes(".issue-comments") %>% 
#     html_text(trim=TRUE) %>% 
#     as.integer()
#   
#   author <- theDom %>%   html_nodes("#js-repo-pjax-container .tooltipped-s") %>% 
#     html_text(trim=TRUE) %>% 
#     as.character()
#   
#   time <-  theDom %>%   html_nodes("time") %>% 
#     html_text(trim=TRUE) %>% 
#     as.Date("%b %d, %Y")
#   
#   id <- theDom %>% html_nodes(".opened-by") %>% 
#     html_text(trim=TRUE) %>% 
#     str_sub(2,5) %>% 
#     extract_numeric()
#  
#   df_c <- data.frame(issue,replies,author,time,id, stringsAsFactors=FALSE) %>% 
#     mutate(status="Closed")
#   
#  
#   
#   u <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues?q=is%3Aissue+is%3Aopen")
#   print(u)
#   theDom <- read_html(u)  #open default
#   
#   issue <- theDom %>%   html_nodes(".issue-title-link") %>% 
#     html_text(trim=TRUE) %>% 
#     as.character()
#   
#   replies <- theDom %>%   html_nodes(".issue-comments") %>% 
#     html_text(trim=TRUE) %>% 
#     as.integer()
#   
#   author <- theDom %>%   html_nodes("#js-repo-pjax-container .tooltipped-s") %>% 
#     html_text(trim=TRUE) %>% 
#     as.character()
#   
#   time <-  theDom %>%   html_nodes("time") %>% 
#     html_text(trim=TRUE) %>% 
#     as.Date("%b %d, %Y")
#   
#   id <- theDom %>% html_nodes(".opened-by") %>% 
#     html_text(trim=TRUE) %>% 
#     str_sub(2,5) %>% 
#     extract_numeric()
#   #status <-"Open"
#   df_o <- data.frame(issue,replies,author,time,id, stringsAsFactors=FALSE) %>% 
#     mutate(status="Open")
#   
#   
#   
#   df <- rbind(df_c,df_o)
#   
#   ## for use in workingdoc
#   write.csv(df,"problem.csv") ## inc rownames but not sure that matters as not displaying
#   
#   info=list(df=df)
#   return(info)
# })

# output$rawData <- DT::renderDataTable({
#  
#   req(repoData()$df)
#   
#   repoData()$df %>% 
#     mutate(link=paste0("https://github.com/rstudio/addinexamples/issues/",id)) %>% 
#     mutate(issue=paste0("<a href=\"",link,"\" target=\"_blank\">",issue,"</a>")) %>% 
#     select(issue,author,date=time,replies,status) %>% 
#    DT::datatable(class='compact stripe hover row-border order-column',
#                  rownames=FALSE, ## bu
#                  escape=FALSE,
#                #  selection='single',
#                  options= list(paging = FALSE, searching = FALSE,info=FALSE))
# })




   source("code/rawData.R", local = TRUE)
  
  
  
})
