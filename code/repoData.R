#separating out into sep file caused issue with replacement has 1 row, data has 0
## even when putting eventReactive in same 

repoData <- eventReactive(input$repo,{
  
  req(input$repo)
  req(input$userName)
  
  issue_list <-
    gh("/repos/:owner/:repo/issues", owner = input$userName, repo = input$repo,
       state = "all",  .limit = Inf,.token="bc1ccbe6243c9b9b86a80963d873f5ac2e515db6")
  (n_iss <- length(issue_list)) 
  
  df <- issue_list %>%
  {
    data_frame(number = map_int(., "number"),
               id = map_int(., "id"),
               title = map_chr(., "title"),
               state = map_chr(., "state"),
               n_comments = map_int(., "comments"),
               opener = map_chr(., c("user", "login")),  ## login is at nested $user$login so helpful
               created_at = map_chr(., "created_at") %>% as.Date())
  }

  info=list(df=df)
  return(info)
})


output$repoData <- DT::renderDataTable({
  
  req(repoData()$df)
  
  repoData()$df %>% 
    mutate(link=paste0("https://github.com/",owner,"/",repo,"/issues/",id)) %>% 
    mutate(issue=paste0("<a href=\"",link,"\" target=\"_blank\">",title,"</a>")) %>% 
    select(issue,opener,date=created_at,comments=n_comments,state) %>% 
    DT::datatable(class="compact stripe hover row-border order-column",
                  rownames=FALSE, ## bu
                  escape=FALSE,
                  #  selection="single",
                  options= list(paging = TRUE, searching = TRUE,info=TRUE))
})

output$repoChart <- renderPlotly({
 

  if(nrow(repoData()$df)==0) return()
  
  df <- repoData()$df

  df <- df %>%
   # select(-1) %>%
    mutate(reps=ifelse(n_comments==0,0.1,n_comments)) %>%
    mutate(numStatus=ifelse(state=="open",1,0.5)) %>%
    mutate(colStatus=ifelse(state=="open","red","green"))

  theTitle <- paste0(input$repo," Issues ")

  print(names(df))
  
  

  plot_ly(df ,
          x=created_at,
          y=reps,
          type="bar",
          group=n_comments,
          showlegend = FALSE,
          hoverinfo="text",
          text=paste(created_at,"<br> ",title),
          marker=list(color=colStatus)) %>%

    layout(hovermode = "closest", barmode="stack",
           xaxis=list(title=" "),
           yaxis=list(title="Comments"),
           title=theTitle,
           titlefont=list(size=16)
    )
})

output$repoAuthorSummary <- DT::renderDataTable({
  
  if(nrow(repoData()$df)==0) return()
  
 #write_csv(repoData()$df,"problem.csv")
  
  # cater for issue where only closed or open issues
  rightCols <- c("opener","closed","open")
  #print(glimpse(repoData()$df))
  
  df <- repoData()$df
  
  df <-df %>%
    group_by(opener,state) %>%
    tally() %>%
    ungroup() %>%
    arrange(desc(n)) %>%
    spread(key=state,n,fill=0)
  
  
  if(ncol(df)!=3) {
    if (setdiff(rightCols,colnames(df))=="open") {
      df$open <- 0 
    }else {
      df$closed <- 0
    }
  }
  
  df %>%
    mutate(total=closed+open) %>%
    arrange(desc(total)) %>%
    DT::datatable(class='compact stripe hover row-border order-column',rownames=FALSE,options= list(paging = TRUE, searching = FALSE,info=FALSE))
})