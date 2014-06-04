# README

This set of scripts downloads random [plenary statements][cre] made orally or in writing by [MEPs][dir] from the 5th (1999-2004), 6th (2004-2009) and 7th (2009-2014) terms of the European Parliament.

The data are highly structured text in 24 languages. Roughly half of the data (148,191 speeches) were submitted to plenary debates. The other half falls into one or more of eight broad subjects:

|code  |label                                      |      n|
|:-----|:------------------------------------------|------:|
|1     |European citizenship                       |   5308|
|2     |Internal market, [SLIM][slim]              |  34123|
|3     |Community policies                         | 109245|
|4     |Economic, social and territorial cohesion  |  53221|
|5     |Economic and monetary system               |   9610|
|6     |External relations of the Union            |  59411|
|7     |Area of freedom, security and justice      |  13525|
|8     |State and evolution of the Union           |  27712|

[cre]: http://www.europarl.europa.eu/plenary/en/home.html
[dir]: http://www.europarl.europa.eu/meps/en/directory.html
[slim]: http://ec.europa.eu/internal_market/simplification/index_en.htm

Here are counts of speech items grouped by theme and subtheme:

|code |label                                                    |      n|
|:----|:--------------------------------------------------------|------:|
|1    |EUROPEAN CITIZENSHIP                                     |   5308|
|1.10 |Fundamental rights in the Union, Charter                 |   1288|
|1.20 |Citizen's rights                                         |   4020|
|2    |INTERNAL MARKET, SLIM                                    |  34123|
|2.10 |Free movement of goods                                   |   4107|
|2.20 |Free movement of persons                                 |    922|
|2.30 |Free movement of workers                                 |    342|
|2.40 |Free movement of services, freedom to provide            |   1954|
|2.50 |Free movement of capital                                 |  21411|
|2.60 |Competition                                              |   2903|
|2.70 |Taxation                                                 |   1424|
|2.80 |Cooperation between administrations                      |   1060|
|3    |COMMUNITY POLICIES                                       | 109245|
|3.10 |Agricultural policy and economies                        |  16089|
|3.15 |Fisheries policy                                         |   6403|
|3.20 |Transport policy in general                              |  18906|
|3.30 |Information and communications in general                |   4284|
|3.40 |Industrial policy                                        |  10528|
|3.45 |Enterprise policy, inter-company cooperation             |   5526|
|3.50 |Research and technological development RTD               |   6532|
|3.60 |Energy policy                                            |  12670|
|3.70 |Environmental policy                                     |  28307|
|4    |ECONOMIC, SOCIAL AND TERRITORIAL COHESION                |  53221|
|4.10 |Social policy, social charter and protocol               |  12737|
|4.15 |Employment policy, action to combat unemployment         |  10232|
|4.20 |Public health                                            |   8100|
|4.30 |Civil protection                                         |    149|
|4.40 |Education, vocational training and youth                 |   4615|
|4.45 |Common cultural area, cultural diversity                 |   2588|
|4.50 |Tourism                                                  |    738|
|4.60 |Consumers' protection in general                         |  11003|
|4.70 |Regional policy                                          |   3050|
|5    |ECONOMIC AND MONETARY SYSTEM                             |   9610|
|5.03 |World economy and globalisation                          |   1896|
|5.05 |Sustainable development and growth                       |   1659|
|5.10 |Economic union                                           |   2521|
|5.20 |Monetary union                                           |   3470|
|6    |EXTERNAL RELATIONS OF THE UNION                          |  59411|
|6.10 |Common foreign and security policy (CFSP)                |  12372|
|6.20 |Common commercial policy in general                      |  24844|
|6.30 |Development cooperation                                  |   7352|
|6.40 |Relations with third countries                           |  13734|
|6.50 |Emergency, food, humanitarian aid, aid to refugees       |   1109|
|7    |AREA OF FREEDOM, SECURITY AND JUSTICE                    |  13525|
|7.10 |Free movement and integration of third-country nationals |   5794|
|7.30 |Police, judicial and customs cooperation in general      |   5012|
|7.40 |Judicial cooperation                                     |   2663|
|7.90 |Justice and home affairs                                 |     56|
|8    |STATE AND EVOLUTION OF THE UNION                         |  27712|
|8.10 |Revision of the Treaties, intergovernmental conferences  |    943|
|8.20 |Enlargement of the Union                                 |   2842|
|8.30 |Treaties in general                                      |    178|
|8.40 |Institutions of the Union                                |   8861|
|8.50 |EU law                                                   |   2668|
|8.60 |European statistical legislation                         |   2338|
|8.70 |Budget of the Union                                      |   9882|

The [complete list of subjects](subjects.md) contains just over 400 topics, with a few missing labels.

# WHY

The data are aimed at running topic models (see, e.g., [Di Maggio _et al._ 2013](http://www.theculturelab.umd.edu/uploads/1/4/2/2/14225661/exploitingaffinities_dimaggio.pdf) and [Fligstein _et al._ 2014](http://sociology.berkeley.edu/sites/default/files/faculty/fligstein/Why%20the%20Federal%20Reserve%20Failed%20to%20See%20the%20Crisis%20of%202008%20v.2.6.pdf)).

The scraper function is described in [this blog post](http://politbistro.hypotheses.org/2068) (in French).

# HOWTO

You will need R, and the main entry point is `make.r`. Some packages require R 3.0.x, but `scraper.r` can be edited to run on R 2.15.x. Please [open an issue](https://github.com/briatte/euspeech) if version 2.0.0 of `qdap` breaks the text scrubbing.

__Most importantly__, adjust the `sample` setting to _n_, where _n_ is the maximum number of random plenary statements to download. Running with `sample` set to `FALSE` will try to download all speeches, which takes over a week.

# CODEBOOK

The `dtm.rda` file contains the document-term matrix `DTM` and lexicalized terms `D` for all English-language items published until May 17, 2014:

* The `DTM` object holds a reduced document-term matrix of all scraped items that were delivered in (or translated to) English, which is the case of 80% of all items.
* The `D` object contains the lexicalized vocabulary of the speeches, based on the upper half of the document-term matrix, cut around its median term inverse frequency.

The same file also contains the following datasets:

* The `speeches` object holds the speech full text and (selected) metadata:
  * `id`: the MEP unique identifier of the speaker (integer)
  * `leg`: the legislature (integer)
  * `date`: the date of the item (yyyy-mm-dd)
  * `lang`: the language of the item (2-letter code)
  * `corpus`: whether the item is part of the document-term matrix (see below)
  * `title`: the title of the speech (often uninformative)
  * `proc`: the procedure code of the speech (used to get the next three columns)
  * `subj`: the Dewey-style subject codes of the procedure
  * `also`: related preocdure codes
  * `oeil`: theme (if the procedure is part of the Observatory's selection)
  * `titleUrl`: the URL to the full text
  * `referenceList`: the reference number of the speech
  * `text`: the raw full text of the speech
* The `meps` object holds selected MEP variables:
  * `id`: the MEP unique identifier (integer, taken from the next column)
  * `link`: the URL to the MEP profile (used to get the `nfo` columns)
  * `name`: duh
  * `natl`: the nationality of the MEP (two-letter code)
  * `group`: the party group, simplified (from the MEP's `nfo` file)
  * `sample`: whether the MEP is represented in the data, i.e. ~ 55% of all MEPs

The `dtm-proc.rda` and `dtm-deba.rda` files hold `DTM` and `D` objects for subsamples of the corpus:

* the `proc` DTM covers only procedure-specific items;
* the `deba` DTM covers all other items, from unspecified debates.

## Subjects

The `subjects.csv` file is a manually processed array of official subject codes extracted from [ParlTrack][parltrack] data. The `subjects.md` file contains the counts of each subject code in the data.

Please open an issue if you need the proper codebook I did not bother to write.

## Polarity

If you uncomment the right segments in the code, the `speeches` data frame will gain a `polarity` variable measuring the [sentiment score](https://trinker.github.io/qdap/polarity.html) score of the speech, using the [AFINN](http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=6010) dictionary.
 
# TODO

- Write the proper codebook I did not bother to write.
- Deal with parliamentary committee affiliations and metadata.

# THANKS

* [@jnbptst](https://twitter.com/jnbptst) for comments
* [@stef](https://github.com/stef) and [@pudo](https://github.com/pudo) for [ParlTrack][parltrack]
* [Dimiter Toshkov](http://www.dimiter.eu/Eurlex.html) for inspiration

[parltrack]: http://parltrack.euwiki.org/
