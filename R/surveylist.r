surveylist <- function(
    page = NULL,
    page_size = NULL,
    start_date = NULL,
    end_date = NULL,
    title = NULL,
    recipient_email = NULL,
    order_asc = NULL,
    fields = NULL,
    api_key = getOption('sm_api_key'),
    oauth_token = getOption('sm_oauth_token')
){
    if(!is.null(api_key)) {
        u <- paste('https://api.surveymonkey.net/v2/surveys/get_survey_list?',
                    'api_key=', api_key, sep='')
    } else
        stop("Must specify 'api_key'")
    if(!is.null(oauth_token))
        token <- paste('bearer', oauth_token)
    else
        stop("Must specify 'oauth_token'")
    b <- list(page = page, page_size = page_size,
              start_date = start_date, end_date = end_date,
              title = title, recipient_email = recipient_email,
              order_asc = order_asc, fields = as.list(fields))
    nulls <- sapply(b, is.null)
    if(all(nulls))
        b <- '{}'
    else
        b <- toJSON(b[!nulls])
    #return(b)
    h <- add_headers(Authorization=token,
                     'Content-Type'='application/json')
    out <- POST(u, config = h, body = b)
    stop_for_status(out)
    content <- content(out, as='parsed')
    if(content$status==3){
        warning("An error occurred: ",content$errmsg)
        return(content)
    } else 
        lapply(content$data$surveys, `class<-`, 'sm_survey')
}

print.sm_survey <- function(x, ...){
    cat('Survey Title:', x$title, '\n')
    cat('ID:', x$survey_id, '\n')
    cat('No. of Questions:', x$question_count, '\n')
    cat('Respondents:', x$responses, '\n')
    cat('Analysis URL:', x$analysis_url, '\n')
    cat('Date Created: ', x$date_created, '\n')
    cat('Date Modified:', x$date_modified, '\n')
    # handle `pages` element from `surveydetails()`
    invisible(x)    
}
