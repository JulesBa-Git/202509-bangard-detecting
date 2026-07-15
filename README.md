# Detecting adverse high-order drug combinations from individual case safety reports using computational statistics on disproportionality measures
Jules Bangard, Einar Holsbø, Kristian Svendsen, Vittorio
Perduca, Étienne Birmelé
2026-07-15

### Citation

{{< cite-as >}}

### Badges

[![build and
publish](https://github.com/computorg/published-202605-bangard-adverse/actions/workflows/build.yml/badge.svg)](https://github.com/computorg/published-202605-bangard-adverse/actions/workflows/build.yml)
[![reviews](https://img.shields.io/badge/review-report-blue)](https://github.com/computorg/published-202605-bangard-adverse/issues?q=is%3Aopen+is%3Aissue+label%3Areview)
[![SWH](https://archive.softwareheritage.org/badge/origin/https://github.com/computorg/published-202605-bangard-adverse)](https://archive.softwareheritage.org/browse/origin/?origin_url=https://github.com/computorg/published-202605-bangard-adverse)
[![DOI:10.57750/7e54-2z98](https://img.shields.io/badge/DOI-{{< shields-encode citation.doi >}}-034E79.svg)](https://doi.org/10.57750/7e54-2z98)
[![Creative Commons
License](https://i.creativecommons.org/l/by/4.0/80x15.png)](http://creativecommons.org/licenses/by/4.0/)

### Authors’ affiliations

{{< author-list >}}

### Abstract

Adverse drug reactions linked to the intake of drug combinations are a
critical concern in pharmacovigilance, particularly as the controlled
environment of clinical trials often lacks the scale and diversity to
detect rare events involving multiple medications. While spontaneous
reporting systems provide the necessary breadth for post-market
surveillance, identifying overrepresented drug cocktails within such
large-scale data remains a significant computational challenge. This
study introduces a computational framework for the detection of drug
cocktails associated with adverse events, leveraging disproportionality
analysis on individual case safety reports. By integrating the
Anatomical Therapeutic Chemical classification, the framework extends
beyond individual drugs to capture hierarchical pharmacological
relationships, enabling exploration of the space of drug combinations
beyond pairwise analysis. To address biases inherent in existing
disproportionality measures, we employ a hypergeometric risk metric,
while a Markov Chain Monte Carlo algorithm provides robust empirical
p-value estimation for the risk associated with cocktails. A genetic
algorithm further facilitates efficient identification of high-risk drug
cocktails. A post-treatment step based on penalized logistic regression
allows distinguishing true pharmacological interactions from combined
individual effects for cocktails of any size. Validation on synthetic
and FDA Adverse Event Reporting System data demonstrates the method’s
efficacy in detecting established drugs and drug combinations associated
with myopathy-related adverse events. Implemented as an R package, this
framework offers a reproducible, scalable tool for post-market drug
safety surveillance.
