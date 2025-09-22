# Detecting adverse high-order drug interactions from individual case
safety reports using computational statistics on disproportionality
measures
Jules Bangard, Einar Holsbø, Kristian Svendsen, Vittorio
Perduca, Étienne Birmelé
2025-09-09

*Template for preparing a submission to Computo, using the [quarto
journal
extension](https://github.com/computorg/computo-quarto-extension), the
knitr kernel (R user) and
[renv](https://rstudio.github.io/renv/articles/renv.html) to set-up the
dependencies.  
For a detailed, step-by-step guide on preparing your article, setting up
the continuous integration and submitting it to Computo, please consult
the [guidelines for
authors](https://computo-journal.org/site/guidelines-authors.html).*

[![build and
publish](https://github.com/JulesBa-Git/202509-bangard-detecting/actions/workflows/build.yml/badge.svg)](https://github.com/JulesBa-Git/202509-bangard-detecting/actions/workflows/build.yml)
[![Creative Commons
License](https://i.creativecommons.org/l/by/4.0/80x15.png)](http://creativecommons.org/licenses/by/4.0/)

### Authors

- [Jules Bangard](https://bangard.xyz) (Institut de Recherche
  Mathématique Avancée, UMR 7501 Université de Strasbourg et CNRS 7 rue
  René-Descartes, 67000 Strasbourg, France)
- [Einar Holsbø](https://einar.sh/) (Faculty of Science and Technology,
  UiT-The Arctic University of Norway, PO, Box 6050 Stakkevollan, N-9037
  Tromsø, Norway)

### Abstract

Adverse drug interactions are a critical concern in pharmacovigilance,
as both clinical trials and spontaneous reporting systems often lack the
breadth to detect complex drug interactions. This study introduces a
computational framework for adverse drug interaction detection,
leveraging disproportionality analysis on individual case safety
reports. By integrating the Anatomical Therapeutic Chemical
classification, the framework extends beyond drug interactions to
capture hierarchical pharmacological relationships. This enables
exploration of the space of drug interactions beyond pairwise
interactions. To address biases inherent in existing disproportionality
measures, we employ a hypergeometric risk metric, while a Markov Chain
Monte Carlo algorithm provides robust empirical p-value estimation for
the risk associated to cocktails. A genetic algorithm further
facilitates efficient identification of high-risk drug cocktails.
Validation on synthetic and FDA Adverse Event Reporting System data
demonstrates the method’s efficacy in detecting established drugs and
drug interactions associated with myopathy-related adverse events.
Implemented as an R package, this framework offers a reproducible,
scalable tool for post-market drug safety surveillance.
