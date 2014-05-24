> _Aim_: download random plenary speeches by [MEPs][dir] from the 5th (1999-2004), 6th (2004-2009) and 7th (2009-2014) terms of the European Parliament.

[dir]: http://www.europarl.europa.eu/meps/en/directory.html

# WHY

This project is not [VoteWatch](http://www.votewatch.eu/):

1. __The data is as longitudinal as possible__, which currently means 15 years from legislature 5 (1999-2004) to today (legislature 7, 2009-2014). This is useful because parliamentary data are fundamentally interval census (some MEPs are present in all three sessions).
2. __The focus is neither presence or roll calls__: the data are full paragraphs of _full text sentences_, spoken or written by MEPs during plenary sessions ('speech acts'). Around 80% of all speech acts were delivered in English (the second most presented EU language, French, ranks at less than 5%).
3. __The data are aimed at running topic models__, as in [Di Maggio _et al._ 2013](http://www.theculturelab.umd.edu/uploads/1/4/2/2/14225661/exploitingaffinities_dimaggio.pdf) and [Fligstein _et al._ 2014](http://sociology.berkeley.edu/sites/default/files/faculty/fligstein/Why%20the%20Federal%20Reserve%20Failed%20to%20See%20the%20Crisis%20of%202008%20v.2.6.pdf). The grouping variables for spoken/written items are MEPs, party families, procedure codes and Dewey-style thematic classes from the European Parliament Legislative Observatory.

# DEPENDENCIES

The scripts require the following packages:

```{S}
library(XML)       # parser for HTML web pages
library(jsonlite)  # parser for JSON results
library(plyr)      # data manipulation
library(dplyr)     # fast data manipulation
library(slam)      # simple triplet matrix representation
library(tm)        # document-term matrix representation
library(SnowballC) # stemmer
library(qdap)      # polarity
```

Some packages require R 3.0.x, but `scraper.r` can be edited to run on R 2.15.x.

# HOWTO

The main entry point is `make.r`. Adjust the `sample` setting to _n_ / 5 where _n_ is the maximum number of random speech acts that you want to download.

There were roughly 270,000 speech acts as of May 2014, so setting `sample` to `75000` should get you almost all available speech acts for legislatures 5–7.

The default setting gets 5,000 items by iterating 5 times over 1,000 items, to fix network errors. Please let me know if you need a more workable version.

# CODEBOOK

The makefile returns the following objects to `dtm.rda`:

* The `D` object holds the document-term matrix of all scraped items that were delivered in English (~ 80% of all items).
* The `speeches` object holds the speech full text and metadata:
  * `id`: the MEP unique identifier of the speaker (integer)
  * `leg`: the legislature (integer)
  * `date`: the date of the item (yyyy-mm-dd)
  * `lang`: the language of the item (2-letter code)
  * `corpus`: whether the item is part of the document-term matrix (see note)
  * `title`: the title of the speech (often uninformative)
  * `proc`: the procedure code of the speech (used to get the next three columns)
  * `subj`: the Dewey-style subject codes of the procedure
  * `also`: related preocdure codes
  * `oeil`: theme (if the procedure is part of the Observatory's selection)
  * `polarity`: the [polarity](https://trinker.github.io/qdap/polarity.html) score of the item, using the [AFINN](http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=6010) dictionary
  * `titleUrl`: the URL to the full text
  * `referenceList`: the reference number of the speech
  * `text`: the raw full text of the speech
* The `meps` object holds a few MEP variables:
  * `id`: the MEP unique identifier (integer, taken from the next column)
  * `link`: the URL to the MEP profile (used to get the `nfo` columns)
  * `name`: duh
  * `group`: the party group, simplified (from the MEP's `nfo` file)
  * `sample`: whether the MEP is represented in the data (~ 54% of all MEPs)

The `subjects.csv` file is a manually processed array of official subject codes extracted from [ParlTrack](http://parltrack.euwiki.org/) data.

The codes look like this (the `n` column are counts from an ongoing scrape):

|id   |code     |label                                                                          |     n|
|:----|:--------|:------------------------------------------------------------------------------|-----:|
|177  |3.70.02  |Atmospheric pollution, motor vehicle pollution                                 |  1122|
|26   |2.50.10  |Financial supervision                                                          |   971|
|25   |2.50.08  |Financial services, financial reporting and auditing                           |   950|
|280  |6.10.08  |Fundamental freedoms, human rights, democracy in general                       |   898|
|283  |6.20.01  |Agreements and relations in the context of the World Trade Organization (WTO)  |   884|
|21   |2.50.03  |Securities and financial markets, stock exchange, CIUTS, investments           |   786|
|285  |6.20.03  |Bilateral economic and trade agreements and relations                          |   785|
|284  |6.20.02  |Export/import control, trade defence                                           |   694|
|178  |3.70.03  |Climate change, ozone                                                          |   587|
|286  |6.20.04  |Union Customs Code, tariffs, preferential arrangements, rules of origin        |   581|
|128  |3.40.03  |Motor industry, cycle and motorcycle, commercial and agricultural vehicles     |   573|
|290  |6.30     |Development cooperation                                                        |   558|
|193  |3.70.20  |Sustainable development                                                        |   523|
|188  |3.70.13  |Dangerous substances, toxic and radioactive wastes (storage, transport)        |   498|
|282  |6.20     |Common commercial policy in general                                            |   479|

Please open an issue if you need the proper codebook I did not bother to write.

# TODO

- Write the proper codebook I did not bother to write.
- Deal with parliamentary committee affiliations and metadata.

# THANKS

* [@jnbptst](https://twitter.com/jnbptst) for comments
* [Stef](https://github.com/stef) and [Dimiter Toshkov](http://www.dimiter.eu/) for inspiration
