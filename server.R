
shinyServer(function(input, output, session) {
 
  ## try sepearting out ui from reactng to textinput - trying to only get
  ## when actio btton pressed
  
  userData <- eventReactive(input$getRepos,{
    input$getRepos
    if(is.null(input$userName)) return()
    
    userName <- input$userName
    
    for(i in 1:10) {
      
      u <- paste0("https://github.com/",userName,"/repositories?page=",i)
      #  u <- paste0("https://github.com/rstudio?page=",i)
      print(u)
      
      dom <-html(u)
      
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
  if(is.null(userData())) return()

inputPanel(
selectInput("repo","Select repo",userData()$allRepos)
)
})

repoData <- eventReactive(input$repo,{
#  repoData <- reactive({
    print(input$repo)
    print(input$userName)
    if(is.null(input$repo)) return()
  print("enter repoData")
  
  v <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues")
  print(v)
  theDom <- html(v)  #open default
  
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
  
  df <- data.frame(issue,replies,author,time,id, stringsAsFactors=FALSE)
  info=list(df=df)
  return(info)
})

output$rawData <- DT::renderDataTable({
  print("enter Raw Data")
  print(repoData()$df)
  print("that was repoData()$df")
  if(is.null(repoData()$df)) return ()
  
  repoData()$df %>% 
    DT::datatable()
  
})

#   source("code/playerSummary.R", local = TRUE)
  
  
  
})
