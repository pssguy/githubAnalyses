
shinyServer(function(input, output, session) {
  
  
  output$b <- renderUI({ 
  if (input$sbMenu=="repo_analysis") { # has to be at menuSubItem if it exists
    inputPanel(
      textInput("userName", "Enter exact User Name"),
      actionButton("getRepos","Get Repos")
    )
  } else if (input$sbMenu=="user_analysis") {
    inputPanel(
    textInput("userNameB", "Enter exact User Name"),
    actionButton("getIssues","Get Issues Raised"),
    helpText(id="ht","Currently Heaviest Users may cause error or limit to 
             more recent issues")
    )
  } else if (input$sbMenu=="faves_analysis") {
    inputPanel(
      selectInput("userNameC", "Add or delete Users",choices=defaultAuthors,multiple=TRUE),
      actionButton("getIssues_faves","Get Issues Raised"),
      helpText(id="ht","Calling many Users may cause error")
      )
  }
  })
  
 
  ## try sepearting out ui from reactng to textinput - trying to only get
  ## when actio btton pressed
  
  userData <- eventReactive(input$getRepos,{
   
    req(input$userName)
    
    user <- input$userName
    a <- paste0("/users/",user,"/repos")
    
    repos <- gh(a, .limit = Inf, state="all", .token = "23adfaef2b412cbf7cc09b67223147406eb4a78f") %>%
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
source("code/favesData.R", local = TRUE)
  
  
})
