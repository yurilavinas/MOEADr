% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_stop_criteria.R
\name{check_stop_criteria}
\alias{check_stop_criteria}
\title{Stop criteria for MOEA/D}
\usage{
check_stop_criteria(stopcrit, call.env)
}
\arguments{
\item{stopcrit}{list containing the parameters defining the stop
handling method. See Section \verb{Stop Criteria} of the \code{\link[=moead]{moead()}}
documentation for details.}

\item{call.env}{List vector containing the stop criteria to be used.
See \code{\link[=moead]{moead()}} for details.}
}
\value{
Flag \code{keep.running}, indicating whether the algorithm should continue
(\code{TRUE}) or terminate (\code{FALSE}).
}
\description{
Verifies stop criteria for the MOEADr package.
}
\details{
This routine is intended to be used internally by \code{\link[=moead]{moead()}},
and should not be called directly by the user.
}
\section{References}{

F. Campelo, L.S. Batista, C. Aranha (2020): The {MOEADr} Package: A
Component-Based Framework for Multiobjective Evolutionary Algorithms Based on
Decomposition. Journal of Statistical Software \doi{10.18637/jss.v092.i06}\cr
}

