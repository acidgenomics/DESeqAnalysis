#' @name degIntersection
#' @inherit AcidGenerics::degIntersection return title
#' @note Updated 2021-03-15.
#'
#' @inheritParams AcidRoxygen::params
#'
#' @param i `character`, `numeric`, or `NULL`.
#'   Names or range of results.
#'   If set `NULL`, include all results per object.
#'   When passing in multiple objects, specify the desired results as a `list`
#'   with length matching the number of input objects, containing either
#'   `character` or `numeric` corresponding to each object.
#' @param direction `character(1)`.
#'   Include "up" or "down" directions.
#'   Must be directional, and intentionally does not support "both".
#' @param return `character(1)`.
#'   - `"matrix"`: `logical matrix`;
#'     Intersection matrix.
#'   - `"count"`: `integer`;
#'     Number of times the gene is significant across contrasts.
#'   - `"ratio"`: `numeric`;
#'     The ratio of how many times the gene is significant across contrasts.
#'   - `"names"`: `character`;
#'     Names of genes that intersect across all contrasts defined.
#'     Input of specific contrasts with `i` argument is recommended here.
#' @param ... Passthrough arguments to `DESeqResultsList` method.
#'
#' @examples
#' data(deseq)
#'
#' ## DESeqAnalysis ====
#' mat <- degIntersection(deseq, return = "matrix")
#' class(mat)
#' type(mat)
#' head(mat)
#'
#' count <- degIntersection(deseq, return = "count")
#' class(count)
#' head(count)
#'
#' ratio <- degIntersection(deseq, return = "ratio")
#' class(ratio)
#' head(ratio)
#'
#' names <- degIntersection(deseq, i = c(1L, 2L), return = "names")
#' class(names)
#' head(names)
#'
#' ## DESeqAnalysisList ====
#' object <- DESeqAnalysisList(list("object1" = deseq, "object2" = deseq))
#' print(object)
NULL



## Updated 2021-03-15.
.args <- list(
    "direction" = c("up", "down"),
    "return" = c("matrix", "count", "ratio", "names")
)



## Updated 2021-03-15.
`degIntersection,DESeqAnalysis` <-  # nolint
    function(
        object,
        i = NULL,
        alphaThreshold = NULL,
        baseMeanThreshold = NULL,
        lfcThreshold = NULL,
        direction,
        return
    ) {
        validObject(object)
        resList <- DESeqResultsList(object = object, quiet = TRUE)
        if (!is.null(i)) {
            assert(length(i) > 1L)
            resList <- resList[i]
        }
        degIntersection(
            object = resList,
            direction = match.arg(direction),
            alphaThreshold = ifelse(
                test = is.null(alphaThreshold),
                yes = alphaThreshold(object),
                no = alphaThreshold
            ),
            baseMeanThreshold = ifelse(
                test = is.null(baseMeanThreshold),
                yes = baseMeanThreshold(object),
                no = baseMeanThreshold
            ),
            lfcThreshold = ifelse(
                test = is.null(lfcThreshold),
                yes = lfcThreshold(object),
                no = lfcThreshold
            ),
            return = match.arg(return)
        )
    }

formals(`degIntersection,DESeqAnalysis`)[names(.args)] <- .args



## Updated 2021-03-15.
`degIntersection,DESeqAnalysisList` <-  # nolint
    `degIntersection,DESeqAnalysis`



## Updated 2021-03-12.
`degIntersection,DESeqResultsList` <-  # nolint
    function(
        object,
        direction,
        alphaThreshold = NULL,
        baseMeanThreshold = NULL,
        lfcThreshold = NULL,
        return
    ) {
        validObject(object)
        if (is.null(alphaThreshold)) {
            alphaThreshold <- alphaThreshold(object)
        }
        if (is.null(baseMeanThreshold)) {
            baseMeanThreshold <- baseMeanThreshold(object)
        }
        if (is.null(lfcThreshold)) {
            lfcThreshold <- lfcThreshold(object)
        }
        direction <- match.arg(direction)
        return <- match.arg(return)
        x <- lapply(
            X = object,
            FUN = deg,
            direction = direction,
            alphaThreshold = alphaThreshold,
            baseMeanThreshold = baseMeanThreshold,
            lfcThreshold = lfcThreshold,
            quiet = TRUE
        )
        assert(hasNames(x))
        if (any(duplicated(names(x)))) {
            dupes <- names(x)[duplicated(names(x))]
            stop(sprintf(
                "%d duplicate %s: %s.",
                length(dupes),
                ngettext(
                    n = length(dupes),
                    msg1 = "contrast",
                    msg2 = "contrasts"
                ),
                toString(dupes, width = 200L)
            ))
        }
        mat <- intersectionMatrix(x)
        alert(sprintf(
            "Returning intersection %s of %s %s-regulated DEGs.",
            return, nrow(mat), direction
        ))
        count <- rowSums(mat)
        mode(count) <- "integer"
        switch(
            EXPR = return,
            "count" = count,
            "matrix" = mat,
            "names" = {
                x <- apply(X = mat, MARGIN = 1L, FUN = all)
                x <- names(x)[x]
                x
            },
            "ratio" = {
                count / length(x)
            }
        )
    }

formals(`degIntersection,DESeqResultsList`)[names(.args)] <- .args



rm(.args)



#' @rdname degIntersection
#' @export
setMethod(
    f = "degIntersection",
    signature = signature("DESeqAnalysis"),
    definition = `degIntersection,DESeqAnalysis`
)



#' @rdname degIntersection
#' @export
setMethod(
    f = "degIntersection",
    signature = signature("DESeqAnalysisList"),
    definition = `degIntersection,DESeqAnalysisList`
)



#' @rdname degIntersection
#' @export
setMethod(
    f = "degIntersection",
    signature = signature("DESeqResultsList"),
    definition = `degIntersection,DESeqResultsList`
)
