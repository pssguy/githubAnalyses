
shinyServer(function(input, output, session) {
  
  
  output$b <- renderUI({ 
  if (input$sbMenu=="repo_analysis") { # has to be at menuSubItem if it exists
    inputPanel(
      textInput("userName", "Enter Github User Name"),
      actionButton("getRepos","Get Repos")
    )
  } else if (input$sbMenu=="user_analysis") {
    inputPanel(
    textInput("userNameB", "Enter Github User Name"),
    actionButton("getIssues","Get Issues")
    )
  }
  })
  
 
  ## try sepearting out ui from reactng to textinput - trying to only get
  ## when actio btton pressed
  
  userData <- eventReactive(input$getRepos,{
   
    req(input$userName)
    
    user <- input$userName
    a <- paste0("/users/",user,"/repos")
    
    repos <- gh(a, .limit = Inf, state="all",.token="6487f02eacc8ef5c90506c906c80c94d36a82731") %>%
      map_chr(., "name") 
    
    info=list(repos=repos)
    
    return(info)
    
  })
  
output$a <- renderUI({
 
  req(userData())
  
  repos <- userData()
  if (input$sbMenu=="repo_analysis"){
inputPanel(
selectInput("repo","Select repo",repos)
)
  }
  # } else if (input$sbMenu=="user_analysis"){
  #   inputPanel(textInput("userNameB", "Enter Github User NameB"))
  # }
})





   source("code/repoData.R", local = TRUE)
   source("code/userData.R", local = TRUE)
    source("code/issuesData.R", local = TRUE)
  
  
})
