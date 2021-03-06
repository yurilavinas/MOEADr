#' summary.moeadps
#'
#' S3 method for summarizing _moead_ objects (the output of [moead()]).
#'
#' @param object list object of class _moead_
#'                     (generated by [moead()])
#' @param useArchive logical flag to use information from `object$Archive`.
#'                   Only used if object$Archive is not `NULL`.
#' @param viol.threshold threshold of tolerated constraint violation, used to
#'                       determine feasibility of points in `object`.
#' @param ndigits number of decimal places to use for the ideal and nadir estimates
#' @param ref.point reference point for calculating the dominated hypervolume
#'                  (only if package `emoa` is available). If `NULL` the estimated nadir
#'                  point is used instead.
#' @param ref.front `Np x Nobj` matrix containing a sample of the true Pareto-optimal
#'                  front, for calculating IGD.
#' @param ... other parameters to be passed down to specific summary functions (currently unused)
#'
#' @examples
#' problem.1 <- list(name = "example_problem",
#'                   xmin = rep(-1,30),
#'                   xmax = rep(1,30),
#'                   m    = 2)
#' out <- moead(preset    = preset_moead("original2"),
#'              problem   = problem.1,
#'              stopcrit  = list(list(name = "maxiter",
#'                                    maxiter = 100)),
#'              showpars  = list(show.iters = "dots",
#'                               showevery  = 10))
#' summary(out)
#'
#' @export
#'
#' @section References:
#' F. Campelo, L.S. Batista, C. Aranha (2020): The {MOEADr} Package: A
#' Component-Based Framework for Multiobjective Evolutionary Algorithms Based on
#' Decomposition. Journal of Statistical Software \doi{10.18637/jss.v092.i06}\cr
#'
summary.moeadps <- function(object,
                          ...,
                          scaling.reference = NULL,
                          useArchive      = FALSE,
                          viol.threshold  = 1e-6,
                          ndigits         = 3,
                          ref.point       = NULL,
                          ref.front       = NULL,
                          show.output     = NULL)
{
  # Error checking
  nullRP <- is.null(ref.point)
  nullRF <- is.null(ref.front)
  nullShowOutput <- is.null(show.output)
  assertthat::assert_that(
    "moead" %in% class(object),
    is.logical(useArchive),
    is.numeric(viol.threshold) && viol.threshold >= 0,
    assertthat::is.count(ndigits),
    nullRP || is.numeric(ref.point),
    nullRP || length(ref.point) == ncol(object$Y),
    nullRF || is.numeric(ref.front),
    nullRF || ncol(ref.front) == ncol(object$Y))

  # ===========================================================================
  # Calculate information for summary

  if(useArchive && !is.null(object$Archive)){
    Y <- object$Archive$Y
    V <- object$Archive$V
  } else {
    Y <- object$Y
    V <- object$V
  }
  hv.scaled <- 0
  igd <- 0

  feas.idx <- rep(TRUE, nrow(Y))
  if(!is.null(V)) feas.idx <- (rowSums(V$Vmatrix > viol.threshold) == 0)

  npts  <- nrow(Y)
  nfeas <- sum(feas.idx)
  nndom.idx <- ecr::nondominated(t(Y[feas.idx, ]))
  nndom <- sum(nndom.idx)


  ideal.est <- apply(Y[feas.idx, ], 2, min)
  nadir.est <- apply(Y[feas.idx, ], 2, max)

  if (!nullRF) igd <- calcIGD(Y, Yref = ref.front)

  if("emoa" %in% rownames(utils::installed.packages())){
    if(nullRP) {
      cat("Warning: reference point not provided:\n
          using the maximum in each dimension instead.")
      ref.point <- nadir.est
    }
    Y <- Y[which(nndom.idx==T),]

    if (!is.null(scaling.reference)) hv <- emoa::dominated_hypervolume(points = t(scaling_Y(Y, scaling.reference)), ref = ref.point)
    else hv <- emoa::dominated_hypervolume(points = t(Y), ref = ref.point)

    # hv.front <- NULL

    # if (!nullRF) hv.front <- emoa::dominated_hypervolume(points = t(scaling_Y(Yref, scaling.reference)), ref = ref.point)
    # if (!nullRF) hv.scaled <- hv/hv.front
  }


  # ===========================================================================
  # Plot summary list
  if (!nullShowOutput){
    cat("\nSummary of MOEA/D run")
    cat("\n#====================================")
    cat("\nTotal function evaluations: ", object$nfe)
    cat("\nTotal iterations: ", object$n.iter)
    cat("\nPopulation size: ", npts)
    cat("\nFeasible points found: ", nfeas,
        paste0("(", signif(100 * nfeas / npts, 3), "%"),
        "of total)")
    cat("\nNondominated points found: ", nndom,
        paste0("(", signif(100 * nndom / npts, 3), "%"),
        "of total)")
    cat("\nEstimated ideal point: ", round(ideal.est, ndigits))
    cat("\nEstimated nadir point: ", round(nadir.est, ndigits))
    if(!nullRF) cat("\nEstimated IGD: ", igd)
    if("emoa" %in% rownames(utils::installed.packages())) {
      cat("\nEstimated HV: ", hv)
      # cat("\nEstimated HV (HV(Y)/HV(ref.front): ", hv.scaled)
      cat("\nRef point used for HV: ", ref.point)
    } else cat("\n\nPlease install package 'emoa' to calculate hypervolume.")
    cat("\n#====================================")
  }

  out <- list(hv = hv, igd = igd, nndom = nndom, nfeas = nfeas)
  return(out)
}
