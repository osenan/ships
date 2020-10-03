library(testthat)

source("explore.R")

test_that("gdistance", {
    expect_equal("549.3282", format(gdistance(38.898556, 38.897147, -77.037852, -77.043934), digits = 7))
})

