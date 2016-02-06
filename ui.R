



dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "Github Analyses"),
  
  dashboardSidebar(
    includeCSS("custom.css"),
inputPanel(
    textInput("userName", "Enter User Name",value="Rstudio"),
    actionButton("getRepos","Get Repos")
),
    uiOutput("a"),
    
    
    
    
    sidebarMenu(
      id = "sbMenu",
      
      
      
      
      menuItem(
        "Analyses", tabName = "analysis",icon = icon("table")
        
        
        
      ))
    ),
    
    dashboardBody(tabItems(
      
      

            
tabItem("analysis",
        DT::dataTableOutput("rawData"),
        plotlyOutput("rawChart")
        
), 
            
            
            tabItem("info",includeMarkdown("info.md"))
            
            
            
            
            
            
            
    ) # tabItems
    ) # body
  ) # page
  