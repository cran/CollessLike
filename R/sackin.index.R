#' @title Computes the Sackin balance index of a phylogenetic tree
#' 
#' @description Given a phylogenetic tree, computes the Sackin balance index of that phylogenetic tree.
#' 
#' @param tree a single phylogenetic tree. It can be entered as a string in Newick format, as a 'phylo' object (\code{ape} package) or as an 'igraph' object (\code{igraph} package). 
#' @param norm a logical variable that indicates whether the index should be normalized or not.
#' 
#' @details The Sackin's index is computed as the sum of the number of ancestors for each leave of the tree.
#' 
#' @return numeric value.
#' 
#' @references 
#' M. J. Sackin, "Good" and  "bad" phenograms. \emph{Sys. Zool}, \bold{21} (1972), 225-226.
#' 
#' @examples 
#' # Computation of the Sackin balance index of trees 
#' # entered in newick format:
#' sackin.index("(1,2,3,4,5);")
#' sackin.index("(1,(2,(3,(4,5))));")
#' 
#' # Computation of the Sackin balance index of trees 
#' # entered as a phylo object:
#' require(ape)
#' random.tree = rtree(5,rooted=TRUE)
#' sackin.index(random.tree)
#' 
#' # Computation of the Sackin balance index of a tree
#' # entered as a igraph object. The tree is randomly 
#' # generated from all trees with 5 leaves following
#' # the alpha-gamma model with alpha=0.5 and gamma=0.3.
#' a.g.tree = a.g.model(5,0.5,0.3)
#' sackin.index(a.g.tree)
#' 
#' #All of them can be normalized (values between 0 and 1)
#' sackin.index("(1,2,3,4,5);",norm=TRUE)
#' sackin.index("(1,(2,(3,(4,5))));",norm=TRUE)
#' sackin.index(random.tree,norm=TRUE)
#' sackin.index(a.g.tree,norm=TRUE)
#' 
#' @importFrom ape read.tree
#' @importFrom igraph graph.edgelist
#' @importFrom igraph degree
#' @importFrom igraph delete.vertices
#' @importFrom igraph get.shortest.paths 
#' 
#' @author Lucia Rotger
#' 
#' @export
sackin.index <-
  function(tree,norm=FALSE){  
    if(class(tree)=="character") 
      tree=read.tree(text = tree)
    if (class(tree)=="phylo") 
      tree=graph.edgelist(tree$edge, directed=TRUE)  
    if(class(tree)!="igraph")
      stop("Not an igraph object. Please introduce a newick string, an ape tree or an igraph tree.")
    root.node = which(degree(tree,mode="in")==0) 
    deg.out = degree(tree,mode="out") 
    if(deg.out[root.node]==1){ #exists a root-edge
      tree = delete.vertices(tree,root.node) 
      deg.out = degree(tree,mode="out") 
      root.node = which(degree(tree,mode="in")==0)
    } 
    leaves = which(deg.out==0)
    root.list = get.shortest.paths(tree,root.node)$vpath
    # SACKIN #
    depths = unlist(lapply(root.list,function(xx){length(xx)-1}))
    SACKIN=sum(depths[leaves])  
    if(norm){ 
      N = length(leaves)
      max.s = N*(N-1)/2 + N-1  
      SACKIN = (SACKIN-N)/(max.s-N) 
    }
    return(SACKIN)
  }
