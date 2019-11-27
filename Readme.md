
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rdimensions

R client for interacting with the
[Dimensions](https://www.dimensions.ai/) Analytics API.

# —— This is a work in progress ——

## Prerequisites

Access to the Dimensions Analytics API requires that you have a
Dimensions account with the necessary authorization priviledges.

At the current time, Dimensions offers free access to the Analytics API
for scientometric researchers and research projects. To apply for free
access, visit [this
page](https://www.dimensions.ai/scientometric-research/) and click on
‘request access’. You will be required to fill in an application to
request no-cost use of Dimensions.

Note that Dimensions has an agreement with the [International Society
for Scientometrics and Informetrics](http://issi-society.org/) (ISSI) to
provide no-cost access to all ISSI members directly.

## Installation

Install the development version from Github:

``` r
install.packages("devtools")
devtools::install_github("nicholasmfraser/rdimensions")
```

## Usage

A necessary first step to using `rdimensions` is to ensure that your
Dimensions username (most likely your email address) and password are
stored in your .Renviron file, as follows:

``` r
dimensions_username=your_username
dimensions_password=your_password
```

For interacting with the Dimensions Analytics API, `rdimensions`
currently only supports a single function, `dimensions_raw`. This
function takes two arguments: `query` and `format`.

`query` is a string containing a complete Dimensions Search Language
(DSL) query. Full information on the DSL structure can be found
[here](https://docs.dimensions.ai/dsl/). In general, DSL queries consist
of two parts, a `search` phrase, and a `return` phrase. The `search`
phrase specificies the documents that we would like to know about. The
`return` phrase specifies what we want to know about those documents. A
simple example of a DSL query would be `search publications for
"bibliometrics" return publications [doi + title + year]`. In this
query, we would search all publications for those related to
bibliometrics, and for any publications found, return the doi, title and
year of publication.

`format` specifies the format in which data should be returned,
currently limited to `list` or `json` types.

Some examples of potential queries are shown below. Note that when using
`dimensions_raw`, any quotation marks that are necessary parts of a DSL
query must be escaped by placing a backwards slash before each quotation
mark, e.g. `"bibliometrics"` becomes `\"bibliometrics\"`.

``` r
# A basic query
dimensions_raw("search publications return publications")

# By default Dimensions limits results to a maximum of 20 records
# You can increase this using the 'limit' argument, up to a maximum of 1000 records
dimensions_raw("search publications return publications limit 500")

# Search for other source types
dimensions_raw("search grants return grants")
dimensions_raw("search patents return patents")
dimensions_raw("search policy_documents return policy_documents")
dimensions_raw("search clinical_trials return clinical_trials")
dimensions_raw("search researchers return researchers")

# Apply filters
dimensions_raw("search publications where year in [2010:2015] return publications")

# Search for a specific DOI
dimensions_raw("search publications where doi = \"10.3389/frma.2018.00023\" return publications")

# Search for a keyword
dimensions_raw("search publications for \"bibliometrics\" return publications")
```

## Roadmap

## Collaboration

Collaborators are extremely welcome\! Please contribute here directly,
or contact me at <nicholasmfraser@gmail.com> for more information.
