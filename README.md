# Hartnett Revised Method for Pubic Age Estimation

This is an RDFBones ontology extension implementing the Hartnett method for estimating age at death from the degree of pubic symphysis deterioration (Hartnett 2010).

Proposed prefix for this ontology: hpa

The ontology extension implements elements defined by Hartnett (2010) in addition to the pubic age estimation method by  Brooks & Suchey (1990).

Dependencies:

* [RDFBones core ontology](https://github.com/RDFBones/RDFBones-O)
* [Suchey-Brooks Method for Pubic Age Determination](https://github.com/RDFBones/SucheyBrooksPubicAge)

The ontology was produced building on version 0.3.1 of the [RDFBones Extension Template](https://github.com/RDFBones/ExtensionTemplate). The code for building the ontology resides on branch robot. It requires the ROBOT tool for ontology manipulation. Run the script Script-Build_OntologyExtension-Robot.sh with appropriate options to obtain an OWL file as output (run ./Script-Build_OntologyExtension-Robot.sh -h for instructions).

## Contributing

Issues concerning this repository are organised through the RDFBones-O issue tracker. Please use the ['HartnettPubicAge' label](https://github.com/RDFBones/RDFBones-O/labels/HartnettPubicAge) there.

## References

* Brooks, S., & Suchey, J. M. (1990). Skeletal age determination based on the os pubis: a comparison of the Acsádi- Nemeskéri and Suchey-Brooks methods. Human Evolution 5(3), 227-238. doi: 10.1007/BF02437238

* Hartnett, K. M. (2010). Analysis of Age-at-Death Estimation Using Data from a New, Modern Autopsy Sample—Part I: Pubic Bone. Journal of Forensic Sciences 55(5), 1145-1151. doi: 10.1111/j.1556-4029.2010.01399.x
