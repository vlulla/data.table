shift = function(x, n=1L, fill, type=c("lag", "lead", "shift", "cyclic"), give.names=FALSE) {
  type = match.arg(type)
  if (type == "cyclic" && !missing(fill)) warningf("Provided argument fill=%s will be ignored since type='cyclic'.", fill)
  if (missing(fill)) fill = NA
  stopifnot(is.numeric(n))
  ans = .Call(Cshift, x, as.integer(n), fill, type)
  if (give.names && is.list(ans)) {
    if (is.null(names(x))) {
      xsub = substitute(x)
      if (is.atomic(x) && is.name(xsub)) nx = deparse(xsub, 500L)
      else nx = paste0("V", if (is.atomic(x)) 1L else seq_along(x))
    }
    else nx = names(x)
    if (!(type %chin% c("shift", "cyclic"))) {
      # flip type for negative n, #3223
      neg = (n<0L)
      if (type=="lead" && length(unique(sign(n))) == 3L) neg[ n==0L ] = TRUE   # lead_0 should be named lag_0 for consistency (if mixing signs of n, #3832)
      if (any(neg)) {
        type = rep(type,length(n))
        type[neg] = if (type[1L]=="lead") "lag" else "lead"
        n[neg] = -n[neg]
      }
    }
    setattr(ans, "names",  paste(rep(nx,each=length(n)), type, n, sep="_"))
  }
  ans
}

nafill = function(x, type=c("const","locf","nocb"), fill=NA, nan=NA) {
  type = match.arg(type)
  .Call(CnafillR, x, type, fill, nan_is_na(nan), FALSE, NULL)
}

setnafill = function(x, type=c("const","locf","nocb"), fill=NA, nan=NA, cols=seq_along(x)) {
  type = match.arg(type)
  invisible(.Call(CnafillR, x, type, fill, nan_is_na(nan), TRUE, cols))
}
