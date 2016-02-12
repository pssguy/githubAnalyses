issuesData <- eventReactive(input$getIssues,{
  print("enter issuesData")
print(input$userNameB)
  req(input$userNameB)
  
  author <- input$userNameB
  print(author)
  
  is <- "issue" # alts? poss pull
  search_q <- list(author = author, is = is)
  (search_q <- paste(names(search_q), search_q, sep = ":", collapse = " ")) #"author:timelyportfolio is:issue"
  
  res <- gh("/search/issues", q = search_q, .limit = Inf,.token="6487f02eacc8ef5c90506c906c80c94d36a82731") #
  #str(res, max.level = 1)
  

  good_stuff <- res %>% 
    keep(is_list) %>%  
    flatten() 
  
  df <- good_stuff %>%
    map_df(`[`, c("title", "html_url", "repository_url","state","comments","created_at")) 
  
  df$repo <-sub( "^.+/(.+)$", "\\1",  df$repository_url )
 df$created_at <- as.Date(df$created_at)
  
  # print(glimpse(df))
  # 
  # write_csv(df,"df.csv")
  
  info=list(df=df)
  return(info)
})




output$issuesTable <- DT::renderDataTable({
  
 # req(issuesData()$df)
  
  print(names(issuesData()$df))
  
  issuesData()$df %>% 
   # mutate(link=paste0("https://github.com/",opener,"/",input$repo,"/issues/",id)) %>% 
    mutate(issue=paste0("<a href=\"",html_url,"\" target=\"_blank\">",title,"</a>")) %>% 
    select(repo,issue,date=created_at,comments=comments,state) %>% 
    DT::datatable(class="compact stripe hover row-border order-column",
                  rownames=FALSE, ## bu
                  escape=FALSE,
                  #  selection="single",
                  options= list(paging = TRUE, searching = TRUE,info=TRUE))
})

output$issuesChart <- renderPlotly({
  
  
  if(nrow(issuesData()$df)==0) return()
  
  df <- issuesData()$df
  
  df <- df %>%
    # select(-1) %>%
    mutate(reps=ifelse(comments==0,0.1,comments)) %>%
    mutate(numStatus=ifelse(state=="open",1,0.5)) %>%
    mutate(colStatus=ifelse(state=="open","red","green"))
  
  theTitle <- paste0(input$userNameB," Issues ")
  
  # print(names(df))
  
  
  
  plot_ly(df ,
          x=created_at,
          y=reps,
          type="bar",
          group=comments,
          showlegend = FALSE,
          hoverinfo="text",
          text=paste(repo,"<br>",created_at,"<br> ",title),
          marker=list(color=colStatus)) %>%
    
    layout(hovermode = "closest", barmode="stack",
           xaxis=list(title=" "),
           yaxis=list(title="Comments"),
           title=theTitle,
           titlefont=list(size=16)
    ) 
})

output$issuesRepoChart <- renderPlotly({
  
  
  if(nrow(issuesData()$df)==0) return()
  
  df <- issuesData()$df
  
  test <- df %>% 
    group_by(repo) %>% 
    tally() %>% 
    arrange(desc(n))
  
  contributed <- nrow(test)
  
  if (contributed>10) {
  top <- head(test,10)
  
  bottom <- tail(test,contributed-10) %>% 
    tally() %>% 
    mutate(repo="All Others")
  
  all <- rbind(top,bottom) %>% 
    arrange(n)
  } else {
    all <- test %>% 
      arrange(n)
  }
  p <- plot_ly(all,
               x = n,
               y = repo,
               
               type = "bar",
               orientation="h"
  ) %>% 
    layout(hovermode = "closest", barmode="stack",
           xaxis=list(title="Contributions"),
           yaxis=list(title=" "),
           title="Github Issue Contributions", titlefont=list(size=16),
           margin = list(l = 120)
    )
  p
})

## InfoBoxes

output$countBox <- renderInfoBox({
 
  infoBox(
    "Issues Authored",nrow(issuesData()$df), icon = icon("question"),
    color = "light-blue"
  )
})  

  output$repoBox <- renderInfoBox({
    
    df <- issuesData()$df
    
    test <- df %>% 
      group_by(repo) %>% 
      tally() %>% 
      arrange(desc(n))
    
    infoBox(
      "Different Repos",nrow(test), icon = icon("github"),
      color = "light-blue"
    )
})
  
  output$closedBox <- renderInfoBox({
    
    tot <- nrow(issuesData()$df)
    closed <-  issuesData()$df %>% 
               filter(state=="closed") %>% 
               nrow()
    pc <- round(100*closed/tot,0)
    infoBox(
      "% Issues Closed",pc, icon = icon("percent"),
      color = "light-blue"
    )
  })  
  
  output$firstBox <- renderInfoBox({
    
   
    infoBox(
      "First Issue",min(issuesData()$df$created_at), icon = icon("calendar"),
      color = "light-blue"
    )
  })  
