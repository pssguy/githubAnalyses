
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
   
    req(input$userName)
    
    user <- input$userName
    a <- paste0("/users/",user,"/repos")
    
    repos <- gh(a, .limit = Inf, state="all",.token="bc1ccbe6243c9b9b86a80963d873f5ac2e515db6") %>%
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
})





   source("code/repoData.R", local = TRUE)
   source("code/userData.R", local = TRUE)
  
  
})
