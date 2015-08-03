



dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "Github Analyses"),
  
  dashboardSidebar(
    includeCSS("custom.css"),
    textInput("userName", "Enter User Name", value="rstudio"),
    uiOutput("a"),
    
    
    
    
    sidebarMenu(
      id = "sbMenu",
      
      
      
      
      menuItem(
        "Analyses", tabName = "analysis",icon = icon("table")
        
        
        
      ))
    ),
    
    dashboardBody(tabItems(
      
      

            
tabItem("analysis"
        
), 
            
            
            tabItem("info",includeMarkdown("info.md"))
            
            
            
            
            
            
            
    ) # tabItems
    ) # body
  ) # page
  