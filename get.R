## gets last HIT run by date
get_LastHit <- function (){
  x<-searchhits()
  return(x$HITs[x$HITs$CreationTime == max(x$HITs$CreationTime),])
}

## returns number of assignments pending from HIT
get_HitPending <- function (hit){
  h = hit
  return(as.numeric(GetHIT(h, response.group = "HITAssignmentSummary",verbose = FALSE)$HITs$NumberOfAssignmentsPending))
}

### returns number of assignments still pending for HIT type / returns a single number 
get_AllPending <- function(hit.type = NULL){
  h = hit.type
  if(is.null(h)){
    message("Error: No HIT type given") 
    return()
  } else {
    ids<-unique(GetAssignments(hit.type = h)$HITId)
    message(paste(length(ids), "HITs found...",sep = " "))
    pending<-lapply(ids, function(x) as.numeric(GetHIT(x, response.group = "HITAssignmentSummary",verbose = FALSE)$HITs$NumberOfAssignmentsPending))
    message(paste(Reduce("+",pending)," assignments still pending.", sep=" "))
    return(Reduce("+",pending))
  }
  
}

### returns number of assignments completed for HIT type / returns a single number 
get_AllCompleted <- function(hit.type = NULL){
  h = hit.type
  if(is.null(h)){
    message("Error: No HIT type given") 
    return()
  } else {
    ids<-unique(GetAssignments(hit.type = h)$HITId)
    message(paste(length(ids), "HITs found...",sep = " "))
    completed<- nrow(GetAssignments(hit.type = h))
    message(paste(Reduce("+",completed)," assignments completed.", sep=" "))
    return(Reduce("+",completed))
  }
  
}