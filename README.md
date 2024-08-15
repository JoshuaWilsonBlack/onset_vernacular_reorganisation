![](images/NZILBB2.png)

# In search of the onset of vernacular reorganisation

Joshua Wilson Black (a) and Lynn Clark (a, b)

a: New Zealand Institute of Language, Brain and Behaviour, University of Canterbury.

b: Department of Linguistics, University of Canterbury.

_Under review_

---

### Abstract

In existing literature on the acquisition of sociolinguistic variation among children, there is a widespread – almost axiomatic – assumption that children will pass through two stages in their journey to acquiring an adult vernacular. First, they will acquire variation that mirrors their adult female caregiver's speech (in both frequency and constraints) in a process known as transmission. Then, at around age five, they will depart from this model and accelerate ongoing sound changes in their community by incrementally using more innovative variants as they age (incrementation), before the stabilisation of their phonological system in late adolescence. These changes are collectively known as ‘vernacular reorganisation’ (Labov 2001). The tipping point that is thought to trigger the switch from transmission to incrementation is the shift a child makes from “the caregiver-dominated norms of the home to the peer-dominated norms of the wider world” when they enter the school system (Smith & Holmes-Elliott 2022: 98). However, it is an open question whether the traditional model of vernacular reorganisation accurately describes the early phases of accent acquisition. 

In this study, we use acoustic phonetic methods to explore vocalic variation and change in a corpus of 131 children from Christchurch, New Zealand, recorded at several time points between the ages of 3;11 years and 5;5 years. We explore the children’s acquisition of a well-established on-going sound change: the New Zealand English short front vowel shift (Langstrof 2006; Hay et al. 2015; Brand et al. 2021). We fit distinct generalised additive mixed models on normalised midpoint readings from the first and second formant of the DRESS, KIT, FLEECE, NURSE and TRAP vowels within a Bayesian framework using the R package ‘brms’ (Bürkner 2017). We apply a similar analysis to an adult sample of 251 talkers from the same city with 29 speakers representative of the caregiver level as assumed in the standard account of vernacular re-organisation (female speakers, 18–35 in 2011).

We find that our preschool children have more conservative productions than would be expected given transmission from caregivers and in some cases seem to become more conservative as they age. We consider various explanations for this finding, including developmental and priming effects from storyteller speech, both of which might result in signs of hyperarticulation.

### How to use the GitHub repository

The main entry point to this project is the OSF.io page at <https://osf.io/cz3jt/>.

The simplest way to use this material is to view the supplementary files using your web browser. The benefit of this is that you can easily see the commentary and the code and do not have to run it yourself (which takes a long time). The disadvantage is, correspondingly, that you cannot step through each step in your own R session or see what happens if you modify the code. The web versions of the supplementary materials are available at:

1. [Filtering and Formant Tracking](https://nzilbb.github.io/onset_vernacular_reorganisation/markdown/SM1_formants.html)
2. [Modelling](https://nzilbb.github.io/onset_vernacular_reorganisation/markdown/SM2_modelling.html)

This repository (the GitHub repository) provides access to the majority of the
code and data for the project. To fully retrace our steps, you will also need:

1. **Acquire prefit models from the OSF repository.** Models are stored here at OSF as a '.rds' file, which is openable by R using the base R `readRDS` function or `readr::read_rds`. The models reported in the paper and supplementary material are also available in OSF storage. Place models in a directory called 'models' in the project directory (i.e. the base directory of the git repository, if you cloned the repository from GitHub, or the directory which was generated when you unzipped the ZIP file you downloaded from GitHub.

2. **Acquire `praat.zip` from the OSF repository and unzip it in the project directory.** `SM1_formants.html`, linked above, describes a process for validating formant tracking settings. The file `praat.zip` contains the files produced in this process and is necessary for `SM1_formants.html` to be produced from the `qmd` file. 

