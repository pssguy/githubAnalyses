#separating out into sep file caused issue with replacement has 1 row, data has 0
## even when putting eventReactive in same 

repoData <- eventReactive(input$repo,{
  
  req(input$repo)
  req(input$userName)
  v <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues?q=is%3Aissue+is%3Aclosed")
  ##print(v)
  theDom <- read_html(v)  #open default
  
  issue <- theDom %>%   html_nodes(".issue-title-link") %>% 
    html_text(trim=TRUE) %>% 
    as.character()
  
  replies <- theDom %>%   html_nodes(".issue-comments") %>% 
    html_text(trim=TRUE) %>% 
    as.integer()
  
  author <- theDom %>%   html_nodes(".opened-by .muted-link") %>% 
    html_text(trim=TRUE) %>% 
    as.character()
  
  time <-  theDom %>%   html_nodes("time") %>% 
    html_text(trim=TRUE) %>% 
    as.Date("%b %d, %Y")
  
  id <- theDom %>% html_nodes(".opened-by") %>% 
    html_text(trim=TRUE) %>% 
    str_sub(2,5) %>% 
    extract_numeric()
  
  df_c <- data.frame(issue,replies,author,time,id, stringsAsFactors=FALSE) %>% 
    mutate(status="Closed")
  
  
  
  u <- paste0("https://github.com/",input$userName,"/",input$repo,"/issues?q=is%3Aissue+is%3Aopen")
  #print(u)
  theDom <- read_html(u)  #open default
  
  issue <- theDom %>%   html_nodes(".issue-title-link") %>% 
    html_text(trim=TRUE) %>% 
    as.character()
  ##print(issue)
  
  replies <- theDom %>%   html_nodes(".issue-comments") %>% 
    html_text(trim=TRUE) %>% 
    as.integer()
  ##print(replies)
  
  #author <- theDom %>%   html_nodes("#js-repo-pjax-container .tooltipped-s") %>% .opened-by .muted-link
  author <- theDom %>%   html_nodes(".opened-by .muted-link") %>% 
   html_text(trim=TRUE) %>% 
    as.character()
  ##print(author)
  
  time <-  theDom %>%   html_nodes("time") %>% 
    html_text(trim=TRUE) %>% 
    as.Date("%b %d, %Y")
  #print(time)
  
  id <- theDom %>% html_nodes(".opened-by") %>% 
    html_text(trim=TRUE) %>% 
    str_sub(2,5) %>% 
    extract_numeric()
  #print(id)
  #status <-"Open"
  df_o <- data.frame(issue,replies,author,time,id, stringsAsFactors=FALSE) %>% 
    mutate(status="Open")
  
  
  
  df <- rbind(df_c,df_o) %>% 
    arrange(desc(time))
  #print(glimpse(df))
  
  ## for use in workingdoc
  write.csv(df,"problem.csv") ## inc rownames but not sure that matters as not displaying
  
  info=list(df=df)
  return(info)
})


output$rawData <- DT::renderDataTable({
  
  req(repoData()$df)
  
  repoData()$df %>% 
    mutate(link=paste0("https://github.com/rstudio/",input$repo,"/issues/",id)) %>% 
    mutate(issue=paste0("<a href=\"",link,"\" target=\"_blank\">",issue,"</a>")) %>% 
    select(issue,author,date=time,replies,status) %>% 
    DT::datatable(class='compact stripe hover row-border order-column',
                  rownames=FALSE, ## bu
                  escape=FALSE,
                  #  selection='single',
                  options= list(paging = TRUE, searching = TRUE,info=TRUE))
})

output$rawChart <- renderPlotly({
  # #print("1st enter")
  # #print(repoData()$df)
  # req(repoData()$df)
  # #print("2nd enter")

  if(nrow(repoData()$df)==0) return()
  
  df <- repoData()$df

  df <- df %>%
   # select(-1) %>%
    mutate(reps=ifelse(replies==0,0.1,replies)) %>%
    mutate(numStatus=ifelse(status=="Open",1,0.5)) %>%
    mutate(colStatus=ifelse(status=="Open","red","green"))

  theTitle <- paste0(input$repo," Issues ")

  #print(theTitle)

  plot_ly(df ,
          x=time,
          y=reps,
          type="bar",
          group=replies,
          showlegend = FALSE,
          hoverinfo="text",
          text=paste(time,"<br> ",issue),#"<br>",gameDate, "<br>Game ",gameOrder),
          marker=list(color=colStatus)) %>%

    layout(hovermode = "closest", barmode="stack",
           xaxis=list(title=" "),
           yaxis=list(title="Replies"),
           title=theTitle,
           titlefont=list(size=16)
    )
})

output$authorSummary <- DT::renderDataTable({
  
  if(nrow(repoData()$df)==0) return()
  
 #write_csv(repoData()$df,"problem.csv")
  
  # cater for issue where only closed or open issues
  rightCols <- c("author","Closed","Open")
  #print(glimpse(repoData()$df))
  
  df <- repoData()$df
  
  df <-df %>%
    group_by(author,status) %>%
    tally() %>%
    ungroup() %>%
    arrange(desc(n)) %>%
    spread(key=status,n,fill=0)
  
  
  if(ncol(df)!=3) {
    if (setdiff(rightCols,colnames(df))=="Open") {
      df$Open <- 0 
    }else {
      df$Closed <- 0
    }
  }
  
  df %>%
    mutate(Total=Closed+Open) %>%
    arrange(desc(Total)) %>%
    DT::datatable(class='compact stripe hover row-border order-column',rownames=FALSE,options= list(paging = TRUE, searching = FALSE,info=FALSE))
})