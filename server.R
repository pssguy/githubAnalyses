
shinyServer(function(input, output, session) {
 
  ## try sepearting out ui from reactng to textinput - trying to only get
  ## when actio btton pressed
  
  userData <- eventReactive(input$getRepos,{
    input$getRepos
    #if(is.null(input$userName)) return()
  #  req(input$userName)
    
    userName <- input$userName
    
    for(i in 1:10) {
      
      u <- paste0("https://github.com/",userName,"/repositories?page=",i)
      #  u <- paste0("https://github.com/rstudio?page=",i)
      print(u)
      
      dom <-read_html(u)
      
      repos <- dom %>% 
        html_nodes(".repo-list-name a") %>% 
        html_text(trim=T)
      
      if (i !=1) {
        allRepos <- c(allRepos,repos)
      } else {
        allRepos <- repos
      }
    }
    
    info=list(allRepos=allRepos)
    return(info)
    
  })
  
output$a <- renderUI({
  #if(is.null(userData())) return()
  req(userData())

inputPanel(
selectInput("repo","Select repo",userData()$allRepos)
)
})

repoData <- eventReactive(input$repo,{
#  repoData <- reactive({
  #   print(input$repo)
  #   print(input$userName)
  #   if(is.null(input$repo)) return()
  # print("enter repoData")
 # req(input$repo)
  
  #this only shows open
 # v <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues")
  v <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues?q=is%3Aissue+is%3Aclosed")
  print(v)
  theDom <- read_html(v)  #open default
  
  issue <- theDom %>%   html_nodes(".issue-title-link") %>% 
    html_text(trim=TRUE) %>% 
    as.character()
  
  replies <- theDom %>%   html_nodes(".issue-comments") %>% 
    html_text(trim=TRUE) %>% 
    as.integer()
  
  author <- theDom %>%   html_nodes("#js-repo-pjax-container .tooltipped-s") %>% 
    html_text(trim=TRUE) %>% 
    as.character()
  
  time <-  theDom %>%   html_nodes("time") %>% 
    html_text(trim=TRUE) %>% 
    as.Date("%b %d, %Y")
  
  id <- theDom %>% html_nodes(".opened-by") %>% 
    html_text(trim=TRUE) %>% 
    str_sub(2,5) %>% 
    extract_numeric()
 
  df_c <- data.frame(issue,replies,author,time,id, stringsAsFactors=FALSE) %>% 
    mutate(status="Closed")
  
  print(glimpse(df_c))
  
  u <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues?q=is%3Aissue+is%3Aopen")
  print(u)
  theDom <- read_html(u)  #open default
  
  issue <- theDom %>%   html_nodes(".issue-title-link") %>% 
    html_text(trim=TRUE) %>% 
    as.character()
  
  replies <- theDom %>%   html_nodes(".issue-comments") %>% 
    html_text(trim=TRUE) %>% 
    as.integer()
  
  author <- theDom %>%   html_nodes("#js-repo-pjax-container .tooltipped-s") %>% 
    html_text(trim=TRUE) %>% 
    as.character()
  
  time <-  theDom %>%   html_nodes("time") %>% 
    html_text(trim=TRUE) %>% 
    as.Date("%b %d, %Y")
  
  id <- theDom %>% html_nodes(".opened-by") %>% 
    html_text(trim=TRUE) %>% 
    str_sub(2,5) %>% 
    extract_numeric()
  #status <-"Open"
  df_o <- data.frame(issue,replies,author,time,id, stringsAsFactors=FALSE) %>% 
    mutate(status="Open")
  
  print(glimpse(df_o))
  
  df <- rbind(df_c,df_o)
  info=list(df=df)
  return(info)
})

output$rawData <- DT::renderDataTable({
  # print("enter Raw Data")
  # print(repoData()$df)
  # print("that was repoData()$df")
  # if(is.null(repoData()$df)) return ()
  req(repoData()$df)
  
  repoData()$df %>% 
    select(issue,author,date=time,replies,status,id) %>% 
   DT::datatable(class='compact stripe hover row-border order-column',rownames=TRUE,selection='single',options= list(paging = FALSE, searching = FALSE,info=FALSE))
})

#   source("code/playerSummary.R", local = TRUE)
  
  
  
})
