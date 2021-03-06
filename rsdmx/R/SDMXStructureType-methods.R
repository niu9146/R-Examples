#' @name SDMXStructureType
#' @rdname SDMXStructureType
#' @aliases SDMXStructureType,SDMXStructureType-method
#' 
#' @usage
#' SDMXStructureType(xmlObj, namespaces, resource)
#' 
#' @param xmlObj object of class "XMLInternalDocument derived from XML package
#' @param namespaces object of class "data.frame" given the list of namespace URIs
#' @param resource object of class "character" giving the REST resource to be
#'        queried (required to distinguish between dataflows and datastructures in
#'        SDMX 2.0)
#' @return an object of class "SDMXStructureType"
#' 
#' @seealso \link{readSDMX}
#'
SDMXStructureType <- function(xmlObj, namespaces, resource){
	new("SDMXStructureType",
      SDMXType(xmlObj),
      subtype = type.SDMXStructureType(xmlObj, namespaces, resource));
}

type.SDMXStructureType <- function(xmlObj, namespaces, resource){
  
  sdmxVersion <- version.SDMXSchema(xmlObj, namespaces)
  VERSION.21 <- sdmxVersion == "2.1"
  
  messageNsString <- "message"
  if(isRegistryInterfaceEnvelope(xmlObj, FALSE)) messageNsString <- "registry"
  messageNs <- findNamespace(namespaces, messageNsString)
  strNs <- findNamespace(namespaces, "structure")
  
  if(VERSION.21){
    dsXML <- getNodeSet(xmlObj, "//ns:DataStructures", namespaces = strNs)
    ccXML <- getNodeSet(xmlObj, "//ns:Concepts", namespaces = strNs)
    clXML <- getNodeSet(xmlObj, "//ns:Codelists", namespaces = strNs)
    
    if(all(c(length(dsXML)>0,length(ccXML)>0,length(clXML)>0))){
      return("DataStructureDefinitionsType")
    }else{
      #others
      structuresXML <- getNodeSet(xmlObj, "//ns:Structures", namespaces = messageNs)
      strType <- paste(xmlName(xmlChildren(structuresXML[[1]])[[1]]), "Type", sep="") 
      return(strType)
    }
  }else{
    #TODO flowXML
    flowXML <- getNodeSet(xmlObj, "//ns:Dataflows", namespaces = messageNs)
    dsXML <- getNodeSet(xmlObj, "//ns:KeyFamilies", namespaces = messageNs)
    ccXML <- getNodeSet(xmlObj, "//ns:Concepts", namespaces = messageNs)
    clXML <- getNodeSet(xmlObj, "//ns:CodeLists", namespaces = messageNs)
    if(all(c(length(dsXML)>0, length(ccXML)>0, length(clXML)>0))){
      #DSD
      return("DataStructureDefinitionsType")
    }else{
      #others
      if(length(ccXML)>0) return("ConceptsType")
      if(length(clXML)>0) return("CodelistsType")
      if(length(flowXML)>0) return("DataflowsType")
      if(length(dsXML)>0){
        if(is.null(resource)){
          strType <- "DataStructuresType"
        }else{
          strType <- switch(resource,
                            "dataflow" = "DataflowsType",
                            "datastructure" = "DataStructuresType")
        }
        return(strType)
      }
    }
  }
  return(NULL)
}

#generics
if (!isGeneric("getStructureType"))
	setGeneric("getStructureType", function(obj) standardGeneric("getStructureType"));

#methods
setMethod(f = "getStructureType", signature = "SDMXStructureType", function(obj){
            return(obj@subtype)
          })

