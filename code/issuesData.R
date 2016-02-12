issuesData <- eventReactive(input$getIssues,{
  print("enter issuesData")
print(input$userNameB)
  req(input$userNameB)
  
  author <- input$userNameB
  print(author)
  
  is <- "issue" # alts? poss pull
  search_q <- list(author = author, is = is)
  (search_q <- paste(names(search_q), search_q, sep = ":", collapse = " ")) #"author:timelyportfolio is:issue"
  ## [1] "author:timelyportfolio state:open is:issue"
  res <- gh("/search/issues", q = search_q, .limit = Inf,.token="bc1ccbe6243c9b9b86a80963d873f5ac2e515db6") # 344 looks good
  ## OK this is not ideal but we can work with it
  str(res, max.level = 1)
  
  # Let's dig out what we need. I display the top of a data frame with one row per issue and, for now, issue title and it's browser URL.
  
  good_stuff <- res %>% 
    keep(is_list) %>%  # keep and is_list are from purr
    flatten() # as is flatten - still ends as list
  
  df <- good_stuff %>%
    map_df(`[`, c("title", "html_url", "repository_url","state","comments","created_at")) 
  
  df$repo <-sub( "^.+/(.+)$", "\\1",  df$repository_url )
 df$created_at <- as.Date(df$created_at)
  
  print(glimpse(df))
  
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