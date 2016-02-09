
shinyServer(function(input, output, session) {
  
  
  output$b <- renderUI({ 
  if (input$sbMenu=="repo_analysis") { # has to be at menuSubItem if it exists
    inputPanel(
      textInput("userName", "Enter Github User Name"),
      actionButton("getRepos","Get Repos")
    )
  } else if (input$sbMenu=="user_analysis") {
    inputPanel(
    textInput("userName2", "Enter Github User Name"),
    actionButton("getIssues","Get Issues")
    )
  }
  })
  
 
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
 
  req(userData())
  
  repos <- userData()$df$repos
  if (input$sbMenu=="repo_analysis"){
inputPanel(
selectInput("repo","Select repo",repos)
)
  }
})





   source("code/repoData.R", local = TRUE)
   source("code/userData.R", local = TRUE)
  
  
})
