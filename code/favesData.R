issuesData_faves <- eventReactive(input$getIssues_faves,{
  

  
  authors <- str_split(input$userNameC,",")[[1]]

 
  is <- "issue"
  for (i in 1:length(authors)) {
    search_q <- list(author = authors[i], is = is)
    (search_q <- paste(names(search_q), search_q, sep = ":", collapse = " ")) 
    
    
    res <- gh("/search/issues", q = search_q, .limit = 3) 
    
    good_stuff <- res %>% 
      keep(is_list) %>%  
      flatten() 
    
    df <- good_stuff %>%
      map_df(`[`, c("title", "html_url", "repository_url","state","comments","created_at")) 
    
    df$repo <-sub( "^.+/(.+)$", "\\1",  df$repository_url )
    df$created_at <- as.Date(df$created_at)
    df$author <- authors[i]
    
    if (i!=1) {
      all <- rbind(all,df)
    } else {
      all <- df
    }
  }
 
  
  info=list(all=all)
  return(info)
})

output$issuesTable_faves <- DT::renderDataTable({
  
  
  
  issuesData_faves()$all %>% 
   arrange(desc(created_at)) %>% 
    mutate(issue=paste0("<a href=\"",html_url,"\" target=\"_blank\">",title,"</a>")) %>% 
    select(author,repo,issue,opened=created_at,comments=comments,state) %>% 
    DT::datatable(class="compact stripe hover row-border order-column",
                  rownames=FALSE, ## bu
                  escape=FALSE,
                  #  selection="single",
                  options= list(paging = TRUE, searching = TRUE,info=TRUE))
})


output$issuesChart_faves <- renderPlotly({
  
  
  if(nrow(issuesData_faves()$all)==0) return()
  
  df <- issuesData_faves()$all
  
   df <- df %>%
 
     mutate(reps=ifelse(comments==0,0.1,comments)) 
  
  
  
  plot_ly(df ,
          x=created_at,
          y=reps,
          type="bar",
          group=author,
          showlegend = FALSE,
          hoverinfo="text",
          text=paste(author,"<br>",repo,"<br>",created_at,"<br> ",title)) %>% 
    
         layout(hovermode = "closest", barmode="stack",
           xaxis=list(title=" "),
           yaxis=list(title="Comments"),
           title="30 most recent Issues raised by each User",
           titlefont=list(size=16)
    ) 
})

output$repoSummary_faves <- DT::renderDataTable({
  
  test <- issuesData_faves()$all %>% 
    group_by(repo,author) %>% 
    tally() %>% 
    arrange(desc(n))  %>%
    spread(key=author,n,fill=0)
  
  tot <- data.frame(tot=rowSums(test[,-1])) #str(tot)
  
  test <- cbind(test,tot) %>% 
    arrange(desc(tot))%>%
    DT::datatable(class='compact stripe hover row-border order-column',rownames=FALSE,options= list(paging = TRUE, searching = FALSE,info=FALSE))
  test
})
