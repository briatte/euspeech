# AIM

This set of scripts downloads random [plenary statements][cre] made orally or in writing by [MEPs][dir] from the 5th (1999-2004), 6th (2004-2009) and 7th (2009-2014) terms of the European Parliament. The data are highly structured text in 24 languages and fall into eight broad themes:

|code  |label                                      |
|:-----|:------------------------------------------|
|1     |European citizenship                       |
|2     |Internal market, [SLIM][slim]              |
|3     |Community policies                         |
|4     |Economic, social and territorial cohesion  |
|5     |Economic and monetary system               |
|6     |External relations of the Union            |
|7     |Area of freedom, security and justice      |
|8     |State and evolution of the Union           |

[cre]: http://www.europarl.europa.eu/plenary/en/home.html
[dir]: http://www.europarl.europa.eu/meps/en/directory.html
[slim]: http://ec.europa.eu/internal_market/simplification/index_en.htm

# WHY

This project is not [VoteWatch](http://www.votewatch.eu/):

1. __The data is as longitudinal as possible__, which currently means 15 years from legislature 5 (1999-2004) to today (legislature 7, 2009-2014). This is useful because parliamentary data are fundamentally interval census (some MEPs are present in all three sessions).
2. __The focus is neither presence or roll calls__: the data are full paragraphs of full text sentences, spoken or written by MEPs during plenary sessions ('speech acts'). Around 80% of all speech acts were delivered in English (the second most presented EU language, French, ranks at less than 5%).
3. __The data are aimed at running topic models__, as in [Di Maggio _et al._ 2013](http://www.theculturelab.umd.edu/uploads/1/4/2/2/14225661/exploitingaffinities_dimaggio.pdf) and [Fligstein _et al._ 2014](http://sociology.berkeley.edu/sites/default/files/faculty/fligstein/Why%20the%20Federal%20Reserve%20Failed%20to%20See%20the%20Crisis%20of%202008%20v.2.6.pdf). The grouping variables for spoken/written items are MEPs, party families, procedure codes and Dewey-style thematic classes from the European Parliament Legislative Observatory.

Here's an [introductory blog post](http://politbistro.hypotheses.org/2068), in French.

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

The main entry point is `make.r`. Adjust the `sample` setting to _n_ / 10 where _n_ is the maximum number of random speech acts that you want to download.

# CODEBOOK

Running the makefile returns the following objects to `dtm.rda`:

* The `D` object holds the document-term matrix of all scraped items that were delivered in English (~ 80% of all items).
* The `speeches` object holds the speech full text and (selected) metadata:
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
* The `meps` object holds selected MEP variables:
  * `id`: the MEP unique identifier (integer, taken from the next column)
  * `link`: the URL to the MEP profile (used to get the `nfo` columns)
  * `name`: duh
  * `group`: the party group, simplified (from the MEP's `nfo` file)
  * `sample`: whether the MEP is represented in the data (~ 54% of all MEPs)

The `subjects.csv` file is a manually processed array of official subject codes extracted from [ParlTrack](http://parltrack.euwiki.org/) data.

Please open an issue if you need the proper codebook I did not bother to write.

# TODO

- Write the proper codebook I did not bother to write.
- Deal with parliamentary committee affiliations and metadata.

# THANKS

* [@jnbptst](https://twitter.com/jnbptst) for comments
* [Stef](https://github.com/stef) and [Dimiter Toshkov](http://www.dimiter.eu/) for inspiration
