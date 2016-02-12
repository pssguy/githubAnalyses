
dashboardPage(
  title = "Github",
  skin = "yellow",
  dashboardHeader(title = "Github Analyses"),
  
  dashboardSidebar(
    includeCSS("custom.css"),
# inputPanel(
#     textInput("userName", "Enter Github User Name"),
#     actionButton("getRepos","Get Repos")
# ),
    uiOutput("b"),
    uiOutput("a"),
    
    
    
    
    sidebarMenu(
      id = "sbMenu",
      
            menuItem(
        "By Repo", tabName = "repo_analysis",icon = icon("github-alt")
        ),
      menuItem(
        "By User", tabName = "user_analysis",icon = icon("male"), selected=T
      ),
      menuItem("Info", tabName = "info",icon = icon("table")),
        
        tags$hr(),
        menuItem(
          text = "",href = "https://mytinyshinys.shinyapps.io/dashboard",badgeLabel = "All Dashboards and Trelliscopes (14)"
        ),
        tags$hr(),
        
        tags$body(
          a(
            class = "addpad",href = "https://twitter.com/pssGuy", target = "_blank",img(src =
                                                                                          "images/twitterImage25pc.jpg")
          ),
          a(
            class = "addpad2",href = "mailto:agcur@rogers.com", img(src = "images/email25pc.jpg")
          ),
          a(
            class = "addpad2",href = "https://github.com/pssguy",target = "_blank",img(src =
                                                                                         "images/GitHub-Mark30px.png")
          ),
          a(
            href = "https://rpubs.com/pssguy",target = "_blank",img(src = "images/RPubs25px.png")
          )
        )
      )
    ),
        
      
  
    
    dashboardBody(tabItems(
      
      

            
tabItem("repo_analysis",
        fluidRow(
          column(
            width = 6,
        box(width=12,title="Repo Issues - Click on Issue to access conversation",
            status = "success",
        DT::dataTableOutput("repoData"))
        ),
        
        column(
          width = 3,
          box(width=12, footer="Hover for Title, Zoom as required",
        plotlyOutput("repoChart"))),
        column(
          width = 3,
        box(width=12,title="Summary by User",status = "success",
       DT::dataTableOutput("repoAuthorSummary")))
        
)
),


tabItem("user_analysis",
        
        
        infoBoxOutput("countBox",width=3),
        infoBoxOutput("repoBox",width=3),
        infoBoxOutput("closedBox",width=3),
        infoBoxOutput("firstBox",width=3),
            
            box(width=6,title="User Issues - Click on Issue to access conversation",
                status = "success",
                DT::dataTableOutput("issuesTable")
                ),
       

          
            box(width=6, footer="Hover for Repo and, Zoom as required",
                plotlyOutput("issuesChart")
                ),
        
      box(width=6, footer="Hover for Repo and, Zoom as required",
    plotlyOutput("issuesRepoChart"))
    
    
        

), 
tabItem("info",includeMarkdown("about.md"))     
            
           
            
            
            
            
            
            
            
    ) # tabItems
    ) # body
  ) # page
  